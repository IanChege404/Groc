import * as admin from "firebase-admin";
import {onDocumentWritten} from "firebase-functions/v2/firestore";
import {logger} from "firebase-functions";

const db = admin.firestore();

/**
 * Keeps the denormalized `rating` / `reviewCount` fields on a product
 * document in sync with its `reviews` subcollection. Runs on every
 * review create/update/delete so listing and detail pages can read
 * live ratings via a single product doc fetch instead of an extra
 * per-product reviews query.
 */
export const onReviewWrite = onDocumentWritten(
  "products/{productId}/reviews/{reviewId}",
  async (event) => {
    const {productId} = event.params;

    const reviewsSnapshot = await db
      .collection("products")
      .doc(productId)
      .collection("reviews")
      .get();

    const reviewCount = reviewsSnapshot.size;
    let averageRating = 0;

    if (reviewCount > 0) {
      const totalRating = reviewsSnapshot.docs.reduce((sum, doc) => {
        const rating = doc.get("rating");
        return sum + (typeof rating === "number" ? rating : 0);
      }, 0);
      averageRating = Math.round((totalRating / reviewCount) * 10) / 10;
    }

    const productRef = db.collection("products").doc(productId);
    const productDoc = await productRef.get();
    if (!productDoc.exists) {
      logger.warn(`Review write for missing product: ${productId}`);
      return;
    }

    await productRef.update({
      rating: averageRating,
      reviewCount: reviewCount,
      updatedAt: admin.firestore.Timestamp.now(),
    });

    logger.info(
      `Updated ${productId}: rating=${averageRating}, reviewCount=${reviewCount}`,
    );
  },
);
