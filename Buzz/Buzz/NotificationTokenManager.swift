import Foundation

class NotificationTokenManager: NSObject {
    public static var shared = NotificationTokenManager()
    
    var notificationToken = ""
    var isNotificationTokenChanged = false
    
    func setNotificationToken(token: String) {
        notificationToken = token
        guard UserDefaults.standard.string(forKey: "FCM_TOKEN") != notificationToken else { return }
        isNotificationTokenChanged = true
        
        Task {
            await sendNotificationTokenAPICall()
        }
    }
    
    func sendNotificationTokenAPICall() async {
        guard isNotificationTokenChanged else { return }
        guard let loginData = UserLoginCache.get() else { return }
        
        if let uid = Auth.auth().currentUser?.uid {
            do {
                let db = Firestore.firestore()
                try await db.collection("users").document(uid).setData(["fcmToken": notificationToken], merge: true)
            } catch let error {
                print("error sendNotificationTokenAPICall: \(error.localizedDescription)")
            }
        }
    }
}
