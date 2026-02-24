const {onDocumentUpdated} = require("firebase-functions/v2/firestore");
const {onDocumentCreated} = require("firebase-functions/v2/firestore");
const {getFirestore} = require("firebase-admin/firestore");
const {getMessaging} = require("firebase-admin/messaging");
const logger = require("firebase-functions/logger");
const functions = require("firebase-functions");
const nodemailer = require("nodemailer");
const admin = require("firebase-admin");

// Initialize Firebase Admin SDK
admin.initializeApp();

const db = getFirestore();

exports.sendMessageNotification = onDocumentCreated(
  "chats/{chatRoomId}/messages/{messageId}",
  async (event) => {
    const doc = event.data;
    if (!doc) {
      logger.error("No document snapshot available.");
      return;
    }

    const messageData = doc.data();
    const senderId = messageData.senderId;
    const messageText = messageData.message;

    if (!senderId || !messageText) {
      logger.error("Missing senderId or message in the message document.");
      return;
    }

    const chatRoomId = event.params.chatRoomId;

    try {
      // 🧑‍🤝‍🧑 Get chat room participants
      const chatRoomDoc = await db.collection("chats").doc(chatRoomId).get();
      if (!chatRoomDoc.exists) {
        logger.error(`Chat room ${chatRoomId} does not exist.`);
        return;
      }

      const chatRoomData = chatRoomDoc.data();
      const participants = chatRoomData.participants || [];

      // 🧑‍💻 Find the receiver (the one who is NOT the sender)
      const receiverId = participants.find((id) => id !== senderId);
      if (!receiverId) {
        logger.warn("No receiver found in participants array.");
        return;
      }

      // 👤 Get sender's username
      const senderDoc = await db.collection("users").doc(senderId).get();
      const senderData = senderDoc.data();
      const senderName = senderData.username;

      // 📱 Get receiver's FCM token
      const receiverDoc = await db.collection("users").doc(receiverId).get();
      if (!receiverDoc.exists) {
        logger.error(`Receiver ${receiverId} does not exist.`);
        return;
      }

      const receiverData = receiverDoc.data();
      const fcmToken = receiverData.fcmToken;

      if (!fcmToken) {
        logger.warn(`No FCM token found for user ${receiverId}`);
        return;
      }

      // ✉️ Notification payload
      const message = {
        token: fcmToken,
        notification: {
          title: `${senderName} sent you a message`,
          body: messageText.length > 50 ?
            messageText.slice(0, 50) + "..." :
            messageText,
        },
        data: {
          senderId: senderId,
          receiverId: receiverId,
          chatRoomId: chatRoomId,
          type: "new_message",
        },
      };

      // 🚀 Send push notification
      await getMessaging().send(message);
      logger.info(`📨 Message notification sent to user ${receiverId}`);
    } catch (error) {
      logger.error("Error sending message notification:", error);
    }
  });


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

exports.updateRankings = onDocumentUpdated("gameHistory/{gameId}",
                                           async (event) => {
    try {
        const before = event.data.before.data();
        const after = event.data.after.data();
        console.log("Before gameHistory:", before);
        console.log("After gameHistory:", after);
        // sanity check
        if (!before || !after) {
            logger.info("No before/after payload — skipping.");
            return;
        }
        // Only run when gamePoints actually changed
        // (prevents recursion when we only write 'ranking')
        if (after.gameCompleted === true) {
            logger.info("Game completed — recalculating user rankings...");

            // Fetch all users with gamePoints > 0
            // ordered by gamePoints descending
            const snapshot = await db.collection("users")
            .where("gamePoints", ">", 0)
            .orderBy("gamePoints", "desc")
            .get();

            const docs = snapshot.docs;
            const updates = [];

            docs.forEach((doc, idx) => {
                const desiredRank = idx + 1;
                const data = doc.data();
                if (data.ranking !== desiredRank) {
                    updates.push({ref: doc.ref, ranking: desiredRank});
                }
            });

            if (updates.length === 0) {
                logger.info("Rankings are already up-to-date.");
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
        } else {
            logger.info("gameCompleted not changed to true — skipping.");
        }
    } catch (err) {
        logger.error("Error while updating rankings:", err);
    }
});

exports.sendEmailOtp = functions.https.onCall(async (request) => {
    logger.log("request.data found:", request.data);
    const email = request.data.email;
    if (!email) {
        throw new functions.https.HttpsError(
                                             "invalid-argument",
                                             "Email must be provided",
                                             );
    }
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const nowUtc = new Date().toISOString()
    .replace("T", " ").substring(0, 19);
    const usersRef = admin.firestore().collection("users");
    const querySnapshot = await usersRef
    .where("emailAddress", "==", email).limit(1).get();
    let userRef;
    if (!querySnapshot.empty) {
        // Email already exists
        const existingUserDoc = querySnapshot.docs[0];
        const userData = existingUserDoc.data();
        if (userData.isRegistrationCompleted === true) {
            // Already fully registered → stop here
            return {success: false, message: "Email already registered."};
        } else {
            // Registration not completed
            // update OTP and reset email verification
            userRef = existingUserDoc.ref;
            await userRef.update({
                emailVerificationCode: otp,
                isEmailVerified: false,
                isPhoneNumberVerified: false,
                updatedAt: nowUtc,
            });
        }
    } else {
        // Create new user doc with Firebase auto-ID in "users"
        userRef = usersRef.doc();
        await userRef.set({
            emailAddress: email,
            createdAt: nowUtc,
            emailVerificationCode: otp,
            isEmailVerified: false,
            isPhoneNumberVerified: false,
            isRegistrationCompleted: false,
        });
    }
    // Send email via Nodemailer (Gmail SMTP in this example)
    await sendEmail(
                    email,
                    "BlvckVenom - Email Verification",
                    `Your OTP is: ${otp}`,
                    );
    /**
     * Sends an email using nodemailer
     * @param {string} to - Recipient email address
     * @param {string} subject - Subject of the email
     * @param {string} text - Body text of the email
     * @return {Promise<void>}
     */
    async function sendEmail(to, subject, text) {
        logger.log("sending email");
        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: "mampuya1335@gmail.com", // replace
                pass: "qvnsmhohpbujfhsp",
                // replace (app password, not raw Gmail pass)
            },
        });
        await transporter.sendMail({
            from: "mampuya1335@gmail.com", // replace
            to,
            subject,
            text,
        });
    }
    return {success: true, userId: userRef.id,
        message: "OTP sent successfully"};
});


// forgot password email otp
exports.sendForgotPasswordEmailOtp = functions.https.onCall(async (request) => {
    logger.log("request.data found:", request.data);
    const email = request.data.email;
    if (!email) {
        throw new functions.https.HttpsError(
                                             "invalid-argument",
                                             "Email must be provided",
                                             );
    }
    // Generate 6-digit OTP
    const otp = Math.floor(100000 + Math.random() * 900000).toString();
    const nowUtc = new Date().toISOString()
    .replace("T", " ").substring(0, 19);
    const usersRef = admin.firestore().collection("users");
    const querySnapshot = await usersRef
    .where("emailAddress", "==", email).limit(1).get();
    let userRef;
    if (!querySnapshot.empty) {
        // Email already exists
        const existingUserDoc = querySnapshot.docs[0];
        const userData = existingUserDoc.data();
        if (userData.isRegistrationCompleted === true) {
            // Already fully registered → Go for otp
            userRef = existingUserDoc.ref;
            await userRef.update({
                emailVerificationCode: otp,
                isEmailVerified: false,
                updatedAt: nowUtc,
            });
        } else {
            // Registration not completed
            // update OTP and reset email verification
            return {success: false, message: "Email not registered."};
        }
    } else {
        // Create new user doc with Firebase auto-ID in "users"
        return {success: false, message: "Email not registered."};
    }
    // Send email via Nodemailer (Gmail SMTP in this example)
    await sendEmail(
                    email,
                    "BlvckVenom - Email Verification",
                    `Your OTP for forgot password is: ${otp}`,
                    );
    /**
     * Sends an email using nodemailer
     * @param {string} to - Recipient email address
     * @param {string} subject - Subject of the email
     * @param {string} text - Body text of the email
     * @return {Promise<void>}
     */
    async function sendEmail(to, subject, text) {
        logger.log("sending email");
        const transporter = nodemailer.createTransport({
            service: "gmail",
            auth: {
                user: "mampuya1335@gmail.com", // replace
                pass: "qvnsmhohpbujfhsp",
                // replace (app password, not raw Gmail pass)
            },
        });
        await transporter.sendMail({
            from: "mampuya1335@gmail.com", // replace
            to,
            subject,
            text,
        });
    }
    return {success: true, userId: userRef.id,
        message: "OTP sent successfully"};
});

exports.verifyEmailOtp = functions.https.onCall(async (request) => {
    const {email, otp} = request.data;
    if (!email || !otp) {
        const errorMessage = "OTP must be provided";
        throw new functions.https.HttpsError("invalid-argument", errorMessage);
    }
    // Find user document by email
    const userQuery = await admin.firestore()
    .collection("users")
    .where("emailAddress", "==", email)
    .limit(1)
    .get();
    if (userQuery.empty) {
        const errorMessage = "No user found with this email";
        throw new functions.https.HttpsError("not-found", errorMessage);
    }
    const userDoc = userQuery.docs[0];
    const userData = userDoc.data();
    // Compare OTP
    if (userData.emailVerificationCode === otp) {
     // Update verification status
        const nowUtc = new Date().toISOString()
        .replace("T", " ").substring(0, 19);
        await userDoc.ref.update({
            isEmailVerified: true,
            emailVerifiedAt: nowUtc,
        });
        return {verified: true, recordId: userDoc.id};
    } else {
        throw new functions.https.HttpsError("invalid-argument", "Invalid OTP");
    }
});

// exports.updateRankingsOnRegistration = onDocumentUpdated("users/{userId}",
//                                                         async (event) => {
//    try {
//        const beforeData = event.data.before.data();
//        const afterData = event.data.after.data();
//
//        // Only run when isRegistrationCompleted changes from false -> true
//        if (!beforeData.isRegistrationCompleted &&
//            afterData.isRegistrationCompleted) {
//                const usersSnapshot = await db.collection("users").get();
//
//                const users = [];
//                usersSnapshot.forEach((doc) => {
//                    const data = doc.data();
//                    users.push({
//                        id: doc.id,
//                        gamePoints: data.gamePoints || 0,
//                    });
//                });
//
//                // Sort users by gamePoints descending
//                users.sort((a, b) => b.gamePoints - a.gamePoints);
//
//                // Assign rankings
//                let rank = 1;
//                const batch = db.batch();
//                users.forEach((user) => {
//                    const userRef = db.collection("users").doc(user.id);
//                    batch.update(userRef, {ranking: rank});
//                    rank++;
//                });
//
//                await batch.commit();
//
//                console.log("✅ Rankings updated.");
//          } else {
//              console.log("⚡ No ranking update needed.");
//          }
//    } catch (error) {
//        console.error("❌ Failed to update rankings:", error);
//    }
// });
