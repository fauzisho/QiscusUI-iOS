//
//  ChatViewController.swift
//  QiscusUI
//
//  Created by Qiscus on 31/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusUI
import QiscusCore
import ContactsUI

class ChatViewController: UIChatViewController {
    var roomID : String?
    var picker : UIImagePickerController?
    let imageCache = NSCache<NSString, UIImage>()
    
    override func viewDidLoad() {
        self.chatDelegate = self
        // Set delegate before super
        super.viewDidLoad()
        // right button
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonSystemItem.add, target: self, action: #selector(self.addMember))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // customize chat list
        customizeChatList()
        
        // alternative load ui then set room data, but you need to handle loading
        guard let roomid = roomID else { return }
        QiscusCore.shared.getRoom(withID: roomid, onSuccess: { [weak self] (result,_) in
            if let chatVc = self {
                chatVc.room = result
            }
        }) { (error) in
            print("error load room \(String(describing: error.message))")
        }
    }
    
    func customizeChatList() {
        self.registerClass(nib: UINib(nibName: "ImageViewCell", bundle: nil), forMessageCellWithReuseIdentifier: "image")
        self.registerClass(nib: UINib(nibName: "TextLeftCell", bundle: nil), forMessageCellWithReuseIdentifier: "TextLeftCell")
        self.registerClass(nib: UINib(nibName: "TextRightCell", bundle: nil), forMessageCellWithReuseIdentifier: "TextRightCell")
        self.setBackground(with: UIImage(named: "bg_chat")!)
    }
    
    @objc func addMember() {
        let alert = UIAlertController(title: "Invite Member", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alert.addTextField(configurationHandler: { textField in
            textField.placeholder = "Qiscus User or email"
        })
        
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
            if let name = alert.textFields?.first?.text {
                guard let _room = self.room  else { return }
                QiscusCore.shared.addParticipant(userEmails: [name], roomId: _room.id, onSuccess: { (member) in
                    //
                }, onError: { (error) in
                    //
                })
                
            }
        }))
        
        self.present(alert, animated: true)

    }
    
}

extension ChatViewController : UIChatView {
    func uiChat(viewController: UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            print("copy")
        }else if action ==  #selector(UIResponderStandardEditActions.cut(_:)) {
            let optionMenu = UIAlertController()
            let deleteAction = UIAlertAction(title: "Delete everyone", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                QiscusCore.shared.deleteMessage(uniqueIDs: [message.uniqId], type: .forEveryone, onSuccess: { (comment) in
                    //
                }, onError: { (error) in
                    //
                })
            })
            let saveAction = UIAlertAction(title: "Delete for me", style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                QiscusCore.shared.deleteMessage(uniqueIDs: [message.uniqId], type: .forMe, onSuccess: { (comment) in
                    //
                }, onError: { (error) in
                    //
                })
            })
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
                (alert: UIAlertAction!) -> Void in
                print("Cancelled")
            })
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(saveAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
        }
    }
    
    func uiChat(viewController: UIChatViewController, canPerformAction action: Selector, forRowAtmessage: CommentModel, withSender sender: Any?) -> Bool {
        return true
    }
    
    func uiChat(viewController: UIChatViewController, cellForMessage message: CommentModel) -> UIBaseChatCell? {
        if message.type == "file_attachment" {
            return self.reusableCell(withIdentifier: "image", for: message) as! ImageViewCell
        }else if message.type == "text" {
            if message.isMyComment() {
                return self.reusableCell(withIdentifier: "TextRightCell", for: message) as! TextRightCell
            }else {
                return self.reusableCell(withIdentifier: "TextLeftCell", for: message) as! TextLeftCell
            }
        }else {
            return nil
        }
    }
    
    func uiChat(viewController: UIChatViewController, didSelectMessage message: CommentModel) {
        //
    }
    
    func uiChat(viewController: UIChatViewController, firstMessage message: CommentModel, viewForHeaderInSection section: Int) -> UIView? {
        return nil
    }
    
    func uiChat(input InViewController: UIChatViewController) -> UIChatInput? {
        let inputBar = CustomChatInput()
        inputBar.delegate = self
        return inputBar
    }
    
}

extension ChatViewController : CustomChatInputDelegate {
    func sendAttachment() {
        let optionMenu = UIAlertController()
        let deleteAction = UIAlertAction(title: "Camera", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getCamera()
        })
        let saveAction = UIAlertAction(title: "Photo & Video Library", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
        })
        let docAction = UIAlertAction(title: "Document", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            print("File Saved")
        })
        let contactAction = UIAlertAction(title: "Contact", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getContact()
        })
        let couponAction = UIAlertAction(title: "Coupon", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.getCoupon()
        })
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
            print("Cancelled")
        })
        optionMenu.addAction(deleteAction)
        optionMenu.addAction(saveAction)
        optionMenu.addAction(docAction)
        optionMenu.addAction(contactAction)
        optionMenu.addAction(couponAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    private func getCamera() {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
        if picker == nil {
            picker = UIImagePickerController()
        }
        picker?.delegate = self
        picker?.allowsEditing = false
        picker?.sourceType = .camera
        picker?.cameraCaptureMode = .photo
        picker?.modalPresentationStyle = .popover
        picker?.mediaTypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary)!
        guard let _picker = picker else { return }
        present(_picker, animated: true, completion: nil)
        }else {
            print("no camera")
        }
    }
    
    private func getContact() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self
        contactPicker.displayedPropertyKeys =
            [CNContactGivenNameKey
                , CNContactPhoneNumbersKey]
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    private func getCoupon() {
        // send custom comment type, ex: coupon. payload can be anything dictionary
        let message = CommentModel()
        message.type = "Coupon/BukaToko"
        message.payload = [
            "name"  : "BukaToko",
            "voucher" : "xyz",
            "extra" : [
                "id" : "112",
                "value" : "20000",
            ]
        ]
        message.message = "Send Coupon"
        self.send(message: message)
    }
}

// Contact Picker
extension ChatViewController : CNContactPickerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
        let userName:String = contact.givenName
        let surName:String = contact.familyName
        let fullName:String = userName + " " + surName
        print("Select contact \(fullName)")
        //  user phone number
        let userPhoneNumbers:[CNLabeledValue<CNPhoneNumber>] = contact.phoneNumbers
        let firstPhoneNumber:CNPhoneNumber = userPhoneNumbers[0].value
        let primaryPhoneNumberStr:String = firstPhoneNumber.stringValue
        print(primaryPhoneNumberStr)
        
        // send contact, with qiscus comment type "contact_person" payload must valit
        let message = CommentModel()
        message.type = "contact_person"
        message.payload = [
            "name"  : fullName,
            "value" : primaryPhoneNumberStr,
            "type"  : "phone"
        ]
        message.message = "Send Contact"
        self.send(message: message)
    }
    
}

// Image Picker
extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        var chosenImage = UIImage()
        chosenImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        dismiss(animated:true, completion: nil)
        
        // send image
        let data = UIImageJPEGRepresentation(chosenImage, 0.5)!
        let timestamp = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
        QiscusCore.shared.upload(data: data, filename: timestamp, onSuccess: { (file) in
            // send image, with qiscus comment type "file_attachment" payload must valid
            let message = CommentModel()
            message.type = "file_attachment"
            message.payload = [
                "url"       : file.url.absoluteString,
                "file_name" : file.name,
                "size"      : file.size,
                "caption"   : ""
            ]
            message.message = "Send Attachment"
            self.send(message: message)
        }, onError: { (error) in
            //
        }) { (progress) in
            print("upload progress: \(progress)")
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}
