import { NextRequest, NextResponse } from 'next/server';
import { initializeApp, cert, getApps } from 'firebase-admin/app';
import { getAuth } from 'firebase-admin/auth';

function getServiceAccount() {
  const serviceAccountKey = process.env.FIREBASE_SERVICE_ACCOUNT_KEY;
  if (serviceAccountKey) {
    const decoded = Buffer.from(serviceAccountKey, 'base64').toString('utf-8');
    return JSON.parse(decoded);
  }

  const projectId = process.env.FIREBASE_PROJECT_ID;
  const clientEmail = process.env.FIREBASE_CLIENT_EMAIL;
  const privateKey = process.env.FIREBASE_PRIVATE_KEY?.replace(/\\n/g, '\n');

  if (projectId && clientEmail && privateKey) {
    return { projectId, clientEmail, privateKey };
  }

  return null;
}

const adminApp = getApps().length === 0
  ? initializeApp({ credential: cert(getServiceAccount()!) })
  : getApps()[0];

export async function middleware(request: NextRequest) {
  const sessionCookie = request.cookies.get('__session')?.value;

  if (!sessionCookie) {
    return NextResponse.redirect(new URL('/login', request.url));
  }

  try {
    const decodedToken = await getAuth(adminApp).verifyIdToken(sessionCookie);
    const userRecord = await getAuth(adminApp).getUser(decodedToken.uid);

    if (!userRecord.customClaims?.isAdmin) {
      return NextResponse.redirect(new URL('/', request.url));
    }

    const response = NextResponse.next();
    response.headers.set('x-admin-uid', decodedToken.uid);
    return response;
  } catch (error) {
    console.error('Auth middleware error:', error);
    const response = NextResponse.redirect(new URL('/login', request.url));
    response.cookies.delete('__session');
    return response;
  }
}

export const config = {
  matcher: ['/admin/:path*'],
};
