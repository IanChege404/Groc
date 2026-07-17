import * as admin from "firebase-admin";
import {onDocumentUpdated} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";

const db = admin.firestore();

export const onReturnStatusUpdate = onDocumentUpdated(
  "return_requests/{returnId}",
  async (event) => {
    try {
      const returnBefore = event.data?.before.data();
      const returnAfter = event.data?.after.data();

      if (!returnBefore || !returnAfter) {
        logger.log("Return data not found");
        return;
      }

      // Only proceed if status changed
      if (returnBefore.status === returnAfter.status) {
        return;
      }

      const userId = returnAfter.userId;
      const status = returnAfter.status;
      const productName = returnAfter.productName;
      const refundAmount = returnAfter.refundAmount;
      const returnId = event.params.returnId;

      // Get user email from users collection
      const userDoc = await db.collection("users").doc(userId).get();
      const userEmail = userDoc.data()?.email;
      const userName = userDoc.data()?.displayName || "Valued Customer";

      if (!userEmail) {
        logger.log(`No email found for user ${userId}`);
        return;
      }

      // Prepare email content based on status
      let subject = "";
      let htmlContent = "";

      switch (status) {
        case "approved":
          subject = "Your Return Request Has Been Approved!";
          htmlContent = generateApprovedEmail(
            userName,
            productName,
            refundAmount,
            returnId
          );
          break;
        case "rejected":
          subject = "Update on Your Return Request";
          htmlContent = generateRejectedEmail(
            userName,
            productName,
            returnAfter.adminNotes || "No additional details provided"
          );
          break;
        case "completed":
          subject = "Your Refund Has Been Processed";
          htmlContent = generateCompletedEmail(userName, refundAmount, returnId);
          break;
        default:
          return;
      }

      // Log email for now (in production, use SendGrid, Mailgun, etc.)
      logger.log(`Email to ${userEmail}: ${subject}`);
      logger.log(`HTML: ${htmlContent}`);

      // TODO: Integrate with actual email service
      // await sendEmail(userEmail, subject, htmlContent);

      // Store notification record
      await db.collection("notifications").add({
        userId,
        type: "return_status",
        returnId,
        status,
        subject,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
        read: false,
      });
    } catch (error) {
      logger.error("Error processing return status update:", error);
    }
  }
);

function generateApprovedEmail(
  userName: string,
  productName: string,
  refundAmount: number,
  returnId: string
): string {
  return `
    <html>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <h2>Return Request Approved</h2>
        <p>Dear ${userName},</p>
        <p>We're happy to inform you that your return request has been <strong>approved</strong>!</p>

        <div style="background: #f0f0f0; padding: 15px; border-radius: 5px; margin: 20px 0;">
          <p><strong>Return ID:</strong> ${returnId}</p>
          <p><strong>Product:</strong> ${productName}</p>
          <p><strong>Refund Amount:</strong> KES ${refundAmount.toFixed(2)}</p>
        </div>

        <p><strong>Next Steps:</strong></p>
        <ol>
          <li>Prepare the product for shipment</li>
          <li>Package it securely</li>
          <li>You will receive a shipping label via email</li>
          <li>Ship the package back to us</li>
          <li>We will process your refund upon receipt</li>
        </ol>

        <p>Thank you for shopping with us!</p>
        <p>Best regards,<br>The Groc Team</p>
      </body>
    </html>
  `;
}

function generateRejectedEmail(
  userName: string,
  productName: string,
  adminNotes: string
): string {
  return `
    <html>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <h2>Return Request Status</h2>
        <p>Dear ${userName},</p>
        <p>We regret to inform you that your return request for <strong>${productName}</strong> has been <strong>rejected</strong>.</p>

        <div style="background: #fff3cd; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #ffc107;">
          <p><strong>Reason:</strong></p>
          <p>${adminNotes}</p>
        </div>

        <p>If you believe this is an error or would like to discuss further, please contact our support team.</p>
        <p>Thank you for your understanding.</p>
        <p>Best regards,<br>The Groc Team</p>
      </body>
    </html>
  `;
}

function generateCompletedEmail(
  userName: string,
  refundAmount: number,
  returnId: string
): string {
  return `
    <html>
      <body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
        <h2>Refund Processed Successfully</h2>
        <p>Dear ${userName},</p>
        <p>Great news! Your return has been received and your refund has been processed.</p>

        <div style="background: #d4edda; padding: 15px; border-radius: 5px; margin: 20px 0; border-left: 4px solid #28a745;">
          <p><strong>Refund Amount:</strong> KES ${refundAmount.toFixed(2)}</p>
          <p><strong>Return ID:</strong> ${returnId}</p>
          <p><strong>Status:</strong> Completed</p>
        </div>

        <p>The refund should appear in your account within 3-5 business days, depending on your bank.</p>
        <p>Thank you for shopping with us and for your patience!</p>
        <p>Best regards,<br>The Groc Team</p>
      </body>
    </html>
  `;
}
