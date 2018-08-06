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
    var displayImage : UIImage? = nil
    var fileType : FileType {
        get {
            if type == .fileAttachment {
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
