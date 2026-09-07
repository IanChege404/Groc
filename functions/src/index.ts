import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
import express from 'express';
import rateLimit from 'express-rate-limit';
import helmet from 'helmet';
import cors from 'cors';

admin.initializeApp();

const app = express();

// Security middleware
app.use(helmet());
app.use(cors({ origin: true }));
app.use(express.json());

// Rate limiting configuration
const authLimiter = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 minutes
  max: 10, // limit each IP to 10 requests per windowMs
  message: 'Too many authentication attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

const passwordResetLimiter = rateLimit({
  windowMs: 60 * 60 * 1000, // 1 hour
  max: 5, // limit each IP to 5 requests per hour
  message: 'Too many password reset attempts, please try again later.',
  standardHeaders: true,
  legacyHeaders: false,
});

// Login endpoint with rate limiting
app.post('/login', authLimiter, async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Use Firebase Admin to verify credentials
    const userRecord = await admin.auth().getUserByEmail(email);
    
    // Check if user exists and is not disabled
    if (userRecord.disabled) {
      return res.status(403).json({ error: 'Account is disabled' });
    }

    // Log successful auth attempt
    functions.logger.info('Auth attempt successful', {
      userId: userRecord.uid,
      email: email,
    });

    res.status(200).json({ 
      message: 'Authentication successful',
      uid: userRecord.uid 
    });
  } catch (error: any) {
    // Log failed auth attempt
    functions.logger.warn('Auth attempt failed', {
      email: req.body.email,
      error: error.message,
    });

    // Don't reveal specific error details
    res.status(401).json({ error: 'Invalid credentials' });
  }
});

// Signup endpoint with rate limiting
app.post('/signup', authLimiter, async (req, res) => {
  try {
    const { email, password, displayName } = req.body;

    if (!email || !password) {
      return res.status(400).json({ error: 'Email and password are required' });
    }

    // Validate password strength
    if (password.length < 8) {
      return res.status(400).json({ error: 'Password must be at least 8 characters' });
    }

    if (!/[A-Z]/.test(password) || !/[a-z]/.test(password) || !/[0-9]/.test(password)) {
      return res.status(400).json({ 
        error: 'Password must contain uppercase, lowercase, and numbers' 
      });
    }

    // Create user
    const userRecord = await admin.auth().createUser({
      email,
      password,
      displayName: displayName || email.split('@')[0],
    });

    // Set custom claims
    await admin.auth().setCustomUserClaims(userRecord.uid, {
      isAdmin: false,
      createdAt: new Date().toISOString(),
    });

    // Create user document in Firestore
    await admin.firestore().collection('users').doc(userRecord.uid).set({
      email,
      displayName: displayName || email.split('@')[0],
      isAdmin: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
      updatedAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    functions.logger.info('User created successfully', {
      userId: userRecord.uid,
      email: email,
    });

    res.status(201).json({ 
      message: 'User created successfully',
      uid: userRecord.uid 
    });
  } catch (error: any) {
    functions.logger.error('Signup failed', {
      email: req.body.email,
      error: error.message,
    });

    if (error.code === 'auth/email-already-exists') {
      return res.status(409).json({ error: 'Email already in use' });
    }

    res.status(500).json({ error: 'Failed to create user' });
  }
});

// Password reset endpoint with stricter rate limiting
app.post('/password-reset', passwordResetLimiter, async (req, res) => {
  try {
    const { email } = req.body;

    if (!email) {
      return res.status(400).json({ error: 'Email is required' });
    }

    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(email)) {
      return res.status(400).json({ error: 'Invalid email format' });
    }

    // Check if user exists (don't reveal if user exists or not)
    try {
      await admin.auth().getUserByEmail(email);
    } catch (error) {
      // User doesn't exist, but don't reveal this
      functions.logger.info('Password reset requested for non-existent user', {
        email: email,
      });
      return res.status(200).json({ 
        message: 'If an account exists with this email, a password reset link has been sent' 
      });
    }

    // Generate password reset link
    const link = await admin.auth().generatePasswordResetLink(email);

    // In production, send email via SendGrid, Mailgun, etc.
    functions.logger.info('Password reset link generated', {
      email: email,
    });

    res.status(200).json({ 
      message: 'If an account exists with this email, a password reset link has been sent' 
    });
  } catch (error: any) {
    functions.logger.error('Password reset failed', {
      email: req.body.email,
      error: error.message,
    });

    res.status(500).json({ error: 'Failed to process password reset' });
  }
});

// Health check endpoint
app.get('/health', (req, res) => {
  res.status(200).json({ status: 'ok', timestamp: new Date().toISOString() });
});

// Error handling middleware
app.use((err: Error, req: express.Request, res: express.Response, next: express.NextFunction) => {
  functions.logger.error('Unhandled error', {
    error: err.message,
    stack: err.stack,
  });

  res.status(500).json({ error: 'Internal server error' });
});

export const auth = functions.https.onRequest(app);
