//
//  CommentModel.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 07/05/18.
//

import Foundation
import QiscusCore

class CommentModel : QComment {
    var onChange : (CommentModel) -> Void = { _ in}
    var isMyComment: Bool {
        get {
            // change this later when user savevd on presisstance storage
            return email == NetworkManager.userEmail
        }
    }
    
    class func generate(_ i:QComment) -> CommentModel {
        let new = CommentModel()
        new.id              = i.id
        new.message         = i.message
        new.commentBeforeId = i.commentBeforeId
        new.email           = i.email
        new.username        = i.username
        new.userAvatarUrl   = i.userAvatarUrl
        // ...
        return new
    }
}

//extension CommentModel {
//    // trick contain stored properties
//    private static var _senderName = [String:String]()
//    
//    var senderName: String {
//        get {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            return CommentModel._senderName[tmpAddress] ?? ""
//        }
//        set(newValue) {
//            let tmpAddress = String(format: "%p", unsafeBitCast(self, to: Int.self))
//            CommentModel._senderName[tmpAddress] = newValue
//        }
//    }
//    
//    var time : String {
//        get {
//            return self.timestamp
//        }
//    }
//    
//    var isMyComment : Bool {
//        get {
//            return false
//        }
//    }
//}

//public struct CommentModel : CommentModel {
//    var uniqueId: String = ""
//    var id: Int = 0
//    var roomId: String = ""
//    var text: String = ""
//    var time: String = ""
//    var date: String = ""
//    var senderEmail: String = ""
//    var senderName: String = ""
//    var senderAvatarURL: String = ""
//    var roomName: String = ""
//    var textFontName: String = ""
//    var textFontSize: Float = 0
//    var displayImage: UIImage?
//    var additionalData: String = ""
////    var repliedText: String = ""
//
//    //audio variable
//    var durationLabel: String = ""
//    var currentTimeSlider: Float = 0
//    var seekTimeLabel: String = "00:00"
//    var audioIsPlaying: Bool = false
//
//    //file variable
//    var isDownloading: Bool = false
//    var isUploading: Bool = false
//    var progress: CGFloat = 0
//
//    var isRead: Bool = false
//    var extras: [String: Any]?
//
//    var isMyComment: Bool = false
////    var commentType: CommentModelType = .text
////    var commentStatus: CommentModelStatus = .sending
////    var file: QFile?
//}
