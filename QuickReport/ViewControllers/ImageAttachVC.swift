//
//  ImageAttachVC.swift
//  QuickReport
//
//  Created by Atikur Rahman on 19/4/18.
//  Copyright © 2018 Atikur Rahman. All rights reserved.
//

import UIKit
import MessageUI

class ImageAttachVC: UIViewController {
    
    // MARK: - Properties
    
    @IBOutlet weak var cameraButton: UIButton!
    
    var projectName: String?
    var projectAddr: String?
    var projectBg: String?
    var customerName: String?
    var customerPhone: String?
    var customerEmail: String?
    var projectCompletionDate: String?
    
    var builder: String?
    var applicator: String?
    var painter: String?
    var substrate: String?
    var system: String?
    var jobSize: String?
    var costOfBuild: String?
    var extraInfo: String?
    
    var images = [UIImage]()
    
    // MARK: - Actions
    
    @IBAction func cameraButtonPressed(_ sender: Any) {
        let picker = UIImagePickerController()
        picker.allowsEditing = true
        picker.delegate = self
        
        let alert = UIAlertController(title: "Upload Photo", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Use Camera", style: .default, handler: { _ in
            picker.sourceType = .camera
            self.present(picker, animated: true)
        }))
        alert.addAction(UIAlertAction(title: "Use Camera Roll", style: .default, handler: { _ in
            picker.sourceType = .photoLibrary
            self.present(picker, animated: true)
        }))
        present(alert, animated: true)
    }
    
    private func addImageToUploadCollection(image: UIImage) {
        images.append(image)
    }
    
    @IBAction func uploadButtonPressed(_ sender: Any) {
        let alertMsg = "Your email app will now open. Please click ‘send’ in the email for the case study to be submitted to the Marketing department"
        
        let alert = UIAlertController(title: nil, message: alertMsg, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default, handler: { _ in
            self.startEmailSendingProcess()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func startEmailSendingProcess() {
        let defaults = UserDefaults.standard
        let username = defaults.string(forKey: "uname") ?? "unknown"
        
        guard let projectName = projectName,
            let projectAddr = projectAddr,
            let projectBg = projectBg,
            let customerName = customerName,
            let customerPhone = customerPhone,
            let customerEmail = customerEmail,
            let projectCompletionDate = projectCompletionDate,
            let builder = builder,
            let applictor = applicator,
            let painter = painter,
            let substrate = substrate,
            let system = system,
            let jobSize = jobSize,
            let costOfBuild = costOfBuild,
            let extraInfo = extraInfo else {
                return
        }
        var messageText = """
        <p><b>Project Name: </b>\(projectName)</p>
        <p><b>Project address: </b>\(projectAddr)</p>
        <p><b>Project background: </b>\(projectBg)</p>
        <p><b>Customer name (Asset Owner): </b>\(customerName)</p>
        <p><b>Customer phone: </b>\(customerPhone)</p>
        <p><b>Customer email: </b>\(customerEmail)</p>
        <p><b>Project completion date: </b>\(projectCompletionDate)</p>
        <p><b>Builder: </b>\(builder)</p>
        <p><b>Applictor: </b>\(applictor)</p>
        <p><b>Painter: </b>\(painter)</p>
        <p><b>Substrate: </b>\(substrate)</p>
        <p><b>System: </b>\(system)</p>
        <p><b>Job Size (sqm): </b>\(jobSize)</p>
        <p><b>$ value of total project (cost of build): </b>\(costOfBuild)</p>
        <p><b>Extra Info: </b>\(extraInfo)</p>
        """
        
        messageText += "<p>Report By: \(username)</p>"
        
        sendEmail(messageText: messageText, images: images)
    }
    
    // MARK: -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        subscribeKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeKeyboardNotifications()
    }
    
    // MARK: - Send email
    
    private func sendEmail(messageText: String, images: [UIImage]) {
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(recipients)
            
            var image_count = 1
            for image in images {
                mail.addAttachmentData(UIImageJPEGRepresentation(image, CGFloat(1.0))!, mimeType: "image/jpeg", fileName: "image\(image_count).jpeg")
                image_count += 1
            }
            
            mail.setSubject("Report")
            mail.setMessageBody(messageText, isHTML: true)
            
            present(mail, animated: true)
        } else {
            // show failure alert
            print("Email send failed.")
        }
    }
    
    // MARK: - Subscribe/unsubscribe keyboard notifications
    
    private func subscribeKeyboardNotifications() {
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillShow(notification:)),
            name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
            selector: #selector(keyboardWillHide(notification:)),
            name: .UIKeyboardWillHide, object: nil)
    }
    
    private func unsubscribeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self,
            name: .UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self,
            name: .UIKeyboardWillHide, object: nil)
    }
    
    // MARK: - Handle keyboard notifications
    
    @objc func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= keyboardSize.height
            }
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}

extension ImageAttachVC: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if result == .sent {
            performSegue(withIdentifier: "EmailSent", sender: nil)
        }
        
        controller.dismiss(animated: true)
    }
}

extension ImageAttachVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerEditedImage] as? UIImage else { return }
        
        addImageToUploadCollection(image: image)
        
        dismiss(animated: true)
        performSegue(withIdentifier: "ImageAdded", sender: nil)
    }
}

extension ImageAttachVC: UITextViewDelegate {
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
