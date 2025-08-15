const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {initializeApp} = require("firebase-admin/app");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");

// Initialize Firebase Admin SDK
initializeApp();

const db = getFirestore();

exports.sendRequestNotification = onDocumentCreated("gameRequests/{requestId}",
    async (event) => {
      const doc = event.data;

      if (!doc) {
        logger.error("No document snapshot available.");
        return;
      }

      const data = doc.data();
      const senderId = data.userId;
      const receiverId = data.opponentId;
      const gameType = data.gameType;

      if (!senderId || !receiverId) {
        logger.error("Missing senderId or receiverId in the document.");
        return;
      }

      try {
        // Fetch sender's name from users collection
        const senderDoc = await db.collection("users").doc(senderId).get();
        const senderData = senderDoc.data();
        const senderName =
          (senderData && senderData.username) ? senderData.username : "Someone";

        // Get FCM token of the receiver
        const receiverDoc = await db.collection("users").doc(receiverId).get();
        const receiverData = receiverDoc.data();

        if (!receiverDoc.exists || !receiverData.fcmToken) {
          logger.warn(`No FCM token found for user ${receiverId}`);
          return;
        }

        const fcmToken = receiverData.fcmToken;

        // Notification payload
        const message = {
          token: fcmToken,
          notification: {
            title: "New Request",
            body: `${senderName} has sent you a ${gameType} request.`,
          },
          data: {
            senderId: senderId,
            requestId: event.params.requestId,
            type: "new_request",
          },
        };

        // Send push notification
        await getMessaging().send(message);

        logger.info(`Notification sent to user ${receiverId}`);
      } catch (error) {
        logger.error("Error sending notification:", error);
      }
    });

exports.updateRankings = onDocumentUpdated("users/{userId}", async (event) => {
  try {
    const before = event.data.before.data();
    const after = event.data.after.data();

    console.log("Before:", before);
    console.log("After:", after);

    // sanity check
    if (!before || !after) {
      logger.info("No before/after payload — skipping.");
      return;
    }

    // Only run when gamePoints actually changed
    // (prevents recursion when we only write 'ranking')
    if (before.gamePoints === after.gamePoints) {
      logger.info("gamePoints unchanged — skipping ranking recalculation.");
      return;
    }

    logger.info("gamePoints changed — recalculating rankings...");

    // Fetch all users ordered by gamePoints desc (highest first)
    const snapshot = await db.collection("users")
        .orderBy("gamePoints", "desc")
        .get();

    const docs = snapshot.docs;
    const updates = [];

    // collect only the docs that need ranking update
    docs.forEach((doc, idx) => {
      const desiredRank = idx + 1;
      const data = doc.data();
      if (data.ranking !== desiredRank) {
        updates.push({ref: doc.ref, ranking: desiredRank});
      }
    });

    if (updates.length === 0) {
      logger.info("Rankings already up-to-date. No writes needed.");
      return;
    }

    // Firestore batch limit is 500 writes — chunk if needed
    let updatedCount = 0;
    while (updates.length) {
      const chunk = updates.splice(0, 500);
      const batch = db.batch();
      chunk.forEach((u) => batch.update(u.ref, {ranking: u.ranking}));
      await batch.commit();
      updatedCount += chunk.length;
    }

    logger.info(`Rankings updated. Documents updated: ${updatedCount}`);
  } catch (err) {
    logger.error("Error while updating rankings:", err);
  }
});
