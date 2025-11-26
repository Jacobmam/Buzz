//
//  mail.swift
//  HandyBros
//
//  Created by Jay Borania on 25/12/24.
//

import SwiftUI
import MessageUI



struct MailComposer: UIViewControllerRepresentable {
    @Binding var isShowing: Bool
    var recipients: [String]
    var subject: String
    var body: String
    
    func makeUIViewController(context: Context) -> MFMailComposeViewController {
        let mailComposeVC = MFMailComposeViewController()
        mailComposeVC.setToRecipients(recipients)
        mailComposeVC.setSubject(subject)
        mailComposeVC.setMessageBody(body, isHTML: false)
        mailComposeVC.mailComposeDelegate = context.coordinator
        return mailComposeVC
    }
    
    func updateUIViewController(_ uiViewController: MFMailComposeViewController, context: Context) {
        // No need to update for this case.
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MFMailComposeViewControllerDelegate {
        var parent: MailComposer
        
        init(_ parent: MailComposer) {
            self.parent = parent
        }
        
        func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
            parent.isShowing = false
            controller.dismiss(animated: true)
        }
    }
}

