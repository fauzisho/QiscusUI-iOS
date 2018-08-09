//
//  UICommentModel.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 07/05/18.
//

import Foundation
import QiscusCore

// Move complexity from core to UI logic
class UICommentModel : CommentModel {
    var onChange : (UICommentModel) -> Void = { _ in}
    var displayImage : UIImage? = nil
    var commentType : CommentType {
        get {
//            for i in CommentType.all {
//                if i.rawValue == type {
//                    return i
//                }else {
//                    // default type text
//                    return .text
//                }
//            }
            return .text
        }
        set {
            self.commentType = newValue
        }
    }
    var fileType : FileType {
        get {
            if commentType == .fileAttachment {
                if let filePayload = payload as? PayloadFile {
                    guard let fileExtension = filePayload.url.absoluteString.components(separatedBy: ".").last else { return .image }
                    if fileExtension.lowercased() == "png" || fileExtension.lowercased() ==  "jpg" || fileExtension.lowercased() ==  "jpeg" {
                        return .image
                    } else if fileExtension.lowercased() == "mp4" || fileExtension.lowercased() == "mkv" || fileExtension.lowercased() == "3gp" {
                        return .video
                    } else if fileExtension.lowercased() == "mp3" {
                        return .audio
                    } else {
                        return .document
                    }
                }
            }
            
            return .document
        }
    }
    
//    var commentPayload : Payload {
//        get {
////            switch commentType {
////            case .fileAttachment:
////                commentPayload = try values.decodeIfPresent(PayloadFile.self, forKey: .payload)
////            case .location:
////                payload = try values.decodeIfPresent(PayloadLocation.self, forKey: .payload)
////            case .contactPerson:
////                payload = try values.decodeIfPresent(PayloadContact.self, forKey: .payload)
////            default:
////                break
////            }
//        }
//        set {
//            self.commentPayload = newValue
//        }
//    }
    
    var isMyComment: Bool {
        get {
            // change this later when user savevd on presisstance storage
            if let user = QiscusCore.getUserLogin() {
                return email == user.email
            }else {
                return false
            }
        }
    }
    
    class func generate(_ i:CommentModel) -> UICommentModel {
        let new = UICommentModel()
        new.id              = i.id
        new.message         = i.message
        new.commentBeforeId = i.commentBeforeId
        new.email           = i.email
        new.username        = i.username
        new.userAvatarUrl   = i.userAvatarUrl
        new.type            = i.type
        new.payload         = i.payload
        // ...
        return new
    }
}

enum FileType {
    case image
    case audio
    case video
    case document
}

public enum CommentType: String {
    case text                       = "text"
    case fileAttachment             = "file_attachment"
    case accountLink                = "account_linking"
    case buttons                    = "buttons"
    case buttonPostbackResponse     = "button_postback_response"
    case reply                      = "replay"
    case systemEvent                = "system_event"
    case card                       = "card"
    case custom                     = "custom"
    case location                   = "location"
    case contactPerson              = "contactPerson"
    case carousel                   = "carousel"
    
    static let all = [text,fileAttachment,accountLink,buttons,buttonPostbackResponse,reply,systemEvent,card,custom,location,contactPerson,carousel]
}
