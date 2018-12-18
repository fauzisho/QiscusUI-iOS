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

enum ChatInputType {
    case none
    case attachment
    case buttons
}

class ChatViewController: UIChatViewController {
    var roomID : String?
    var picker : UIImagePickerController?
    let imageCache = NSCache<NSString, UIImage>()
    
    // Demo custom input
    var inputType : ChatInputType = .none
    
    override func viewDidLoad() {
        self.chatDelegate = self
        // Set delegate before super
        super.viewDidLoad()
        // right button
        let rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.add, target: self, action: #selector(self.addMember))
        self.navigationItem.rightBarButtonItem = rightBarButtonItem
        
        // customize chat list
        customizeChatList()
        
        // MARK : Sample Room Event
        guard let id = self.room?.id else { return }
        QiscusCore.shared.subscribeEvent(roomID: id) { (event) in
            print("room event : \(event.sender) \n data : \(event.data)")
        }
        
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
    func uiChat(navigationView inViewConroller: UIChatViewController) -> UIChatNavigation? {
        return nil
    }
    
    func uiChat(viewController: UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?) {
        if action == #selector(UIResponderStandardEditActions.copy(_:)) {
            print("copy")
        }else if action ==  #selector(UIResponderStandardEditActions.cut(_:)) {
            QiscusCore.shared.deleteMessage(uniqueIDs: [message.uniqId], onSuccess: { (comment) in
                //
            }, onError: { (error) in
                //
            })
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
        var inputBar : UIChatInput? = nil
        
        switch self.inputType {
        case .buttons:
            // Input chat button
            inputBar = CustomChatInputButton()
        case .attachment:
            let _input = CustomChatInput()
            _input.delegate = self
            inputBar = _input
        default:
            break
        }
        inputBar?.setHeight(50)
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
        let roomEventAction = UIAlertAction(title: "Room Event", style: .default, handler: {
            (alert: UIAlertAction!) -> Void in
            self.roomEvent()
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
        optionMenu.addAction(roomEventAction)
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
        self.send(message: message, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
        
        // Mock unsubscribe event
        guard let id = self.room?.id else { return }
        QiscusCore.shared.unsubscribeEvent(roomID: id)
    }
    
    func roomEvent() {
        guard let id = self.room?.id else { return }
        // dummy send event
        let payload = [
            "type" : "unknown"
        ]
        if QiscusCore.shared.publishEvent(roomID: id, payload: payload) {
            print("success end event")
        }
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
        self.send(message: message, onSuccess: { (comment) in
            //success
        }) { (error) in
            //error
        }
    }
    
}

// Image Picker
extension ChatViewController : UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
// Local variable inserted by Swift 4.2 migrator.
let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)

        var chosenImage = UIImage()
        chosenImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as! UIImage
        dismiss(animated:true, completion: nil)
        
        // send image
        let data = chosenImage.jpegData(compressionQuality: 0.5)!
        let timestamp = "\(NSDate().timeIntervalSince1970 * 1000).jpg"
        
        let uploader = ChatUploaderVC()
        uploader.chatView = self
        uploader.data = data
        uploader.fileName = timestamp
        self.navigationController?.pushViewController(uploader, animated: true)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
	return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
	return input.rawValue
}
