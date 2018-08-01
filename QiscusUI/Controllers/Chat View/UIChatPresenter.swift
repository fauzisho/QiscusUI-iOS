//
//  File.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 07/05/18.
//

import Foundation
import QiscusCore

protocol UIChatUserInteraction {
    func sendMessage(withText text: String)
    func loadRoom(withId roomId: String)
    func loadComments(withID roomId: String)
    func getMessage(inRoom roomId: String)
    func getAvatarImage(section: Int, imageURL: URL?)
}

protocol UIChatViewDelegate {
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?)
    func onLoadMessageFinished()
    func onSendMessageFinished(comment: CommentModel)
    func onGotNewComment(newSection: Bool, isMyComment: Bool)
}

class UIChatPresenter: UIChatUserInteraction {
    
    private var viewPresenter: UIChatViewDelegate?
    var comments: [[CommentModel]] {
        didSet {
            self.viewPresenter?.onLoadMessageFinished()
        }
    }
    var room: QRoom?

    init() {
        self.comments = [[CommentModel]]()
    }
    
    func attachView(view : UIChatViewDelegate){
        viewPresenter = view
        if let room = self.room {
            self.loadComments(withID: room.id)
            viewPresenter?.onLoadRoomFinished(roomName: room.roomName, roomAvatarURL: URL.init(string: room.avatarUrl))
        }
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func getComments() -> [[CommentModel]] {
        return self.comments
    }
    
    func loadRoom(withId roomId: String) {

    }
    
    func loadComments(withID roomId: String) {
        QiscusCore.shared.loadComments(roomID: roomId) { (c, error) in
            self.comments.removeAll()
            //self.comments.append(c!)
        }
    }
    
    func sendMessage(withText text: String) {
        // create object comment
        let message = CommentModel()
        message.id = ""
        message.message = text
        message.type = "text"
        message.uniqueTempId = "ios_"
        
        // add new comment to ui
        self.comments.append([message])
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message) { (comment, error) in
            // update comment status delivered
        }
    }
    
    func getMessage(inRoom roomId: String) {

    }
    
    func getDate(section:Int, labelView : UILabel) {

    }
    
    func getAvatarImage(section: Int, imageURL: URL?) {

    }
    
    // MARK: private function
    private func getReplyData(stringJSON: String) {
//        let replyData = JSON(parseJSON: self.comment!.data)
//        var text = replyData["replied_comment_message"].stringValue
//        var replyType = self.comment!.replyType(message: text)
//        if replyType == .text  {
//            switch replyData["replied_comment_type"].stringValue {
//            case "location":
//                replyType = .location
//                break
//            case "contact_person":
//                replyType = .contact
//                break
//            default:
//                break
//            }
//        }
    }
    
    private func loadRoomAvatar(room: QRoom) {
//        room.loadAvatar(onSuccess: { (avatar) in
//            self.view.onLoadRoomFinished(roomName: room.name, roomAvatar: room.avatar)
//        }, onError: { (error) in
//            room.downloadRoomAvatar(onSuccess: { room in
//                self.loadRoomAvatar(room: room)
//            })
//        })
    }
    
//    private func generateComments(CommentModels: [CommentModel]) -> [[CommentModel]] {
//        var CommentModels = CommentModels.map { (comment) -> CommentModel in
//            let comment = CommentModel(uniqueId: comment.uniqueId, id: comment.id, roomId: comment.roomId, text: comment.text, time: comment.time, date: comment.date, senderEmail: comment.senderEmail, senderName: comment.senderName, senderAvatarURL: comment.senderAvatarURL, roomName: comment.roomName, textFontName: "", textFontSize: 0, displayImage: QCacheManager.shared.getImage(onCommentUniqueId: comment.uniqueId), additionalData: comment.data, durationLabel: comment.durationLabel, currentTimeSlider: comment.currentTimeSlider, seekTimeLabel: comment.seekTimeLabel, audioIsPlaying: comment.audioIsPlaying, isDownloading: comment.isDownloading, isUploading: comment.isUploading, progress: comment.progress, isRead: comment.isRead, extras: comment.extras, isMyComment: comment.senderEmail == Qiscus.client.email, commentType: comment.type, commentStatus: comment.status, file: comment.file)
//
//            return comment
//        }
//        return self.groupingComments(comments: CommentModels)
//    }


    
    private func groupingComments(comments: [CommentModel]) -> [[CommentModel]]{
        var retVal = [[CommentModel]]()
        var uidList = [CommentModel]()
        var s = 0
        let date = Double(Date().timeIntervalSince1970)
        var prevComment:CommentModel?
        var group = [CommentModel]()
        var count = 0
//        func checkPosition(ids:[String]) {
//            var n = 0
//            for id in ids {
//                var position = QCellPosition.middle
//                if ids.count > 1 {
//                    switch n {
//                    case 0 :
//                        position = .first
//                        break
//                    case ids.count - 1 :
//                        position = .last
//                        break
//                    default:
//                        position = .middle
//                        break
//                    }
//                }else{
//                    position = .single
//                }
//                n += 1
//                if let c = CommentModel.threadSaveComment(withUniqueId: id){
//                    c.updateCellPos(cellPos: position)
//                }
//            }
//        }
        
//        for comment in  comments.reversed() {
//            if !uidList.contains(where: { (CommentModel) -> Bool in
//                return CommentModel.uniqueId == comment.uniqueId
//            }) {
//                if let prev = prevComment{
//                    if prev.date == comment.date && prev.senderEmail == comment.senderEmail {
//                        uidList.append(comment)
//                        group.append(comment)
//                    }else{
//                        retVal.append(group)
////                        checkPosition(ids: group)
//                        group = [CommentModel]()
//                        group.append(comment)
//                        uidList.append(comment)
//                    }
//                }else{
//                    group.append(comment)
//                    uidList.append(comment)
//                }
//                if count == comments.count - 1  {
//                    retVal.append(group)
////                    checkPosition(ids: group)
//                }else{
//                    prevComment = comment
//                }
//            }
//            count += 1
//        }
        return retVal
    }
    
    // MARK : Notification center function
    @objc private func newCommentNotif(_ notification: Notification) {
        if let userInfo = notification.userInfo {
//            guard let property = userInfo["property"] as? QRoomProperty else {return}
//            if property == .lastComment {
//                guard let room = userInfo["room"] as? QRoom else {return}
//                guard let comment = room.lastComment else {return}
//
//                if room.isInvalidated { return }
//                if comment.senderEmail == Qiscus.client.email {
//                    self.chatService.room(withId: room.id)
//                    return
//                }
//
//                let CommentModel = CommentModel(uniqueId: comment.uniqueId, id: comment.id, roomId: comment.roomId, text: comment.text, time: comment.time, date: comment.date, senderEmail: comment.senderEmail, senderName: comment.senderName, senderAvatarURL: comment.senderAvatarURL, roomName: comment.roomName, textFontName: "", textFontSize: 0, displayImage: QCacheManager.shared.getImage(onCommentUniqueId: comment.uniqueId), additionalData: comment.data, durationLabel: comment.durationLabel, currentTimeSlider: comment.currentTimeSlider, seekTimeLabel: comment.seekTimeLabel, audioIsPlaying: comment.audioIsPlaying, isDownloading: comment.isDownloading, isUploading: comment.isUploading, progress: comment.progress, isRead: comment.isRead, extras: comment.extras, isMyComment: comment.senderEmail == Qiscus.client.email, commentType: comment.type, commentStatus: comment.status, file: comment.file)
//
//                if let latestCommentSection = self.comments.first {
//                    if let latestComment = latestCommentSection.first {
//                        if CommentModel.senderName != latestComment.senderName || CommentModel.date != latestComment.date {
//                            self.comments.insert([CommentModel], at: 0)
//                            self.view.onGotNewComment(newSection: true, isMyComment: false)
//                        } else {
//                            self.comments[0].insert(CommentModel, at: 0)
//                            self.view.onGotNewComment(newSection: false, isMyComment: false)
//                        }
//                    }
//                } else {
//                    self.comments.insert([CommentModel], at: 0)
//                    self.view.onGotNewComment(newSection: true, isMyComment: false)
//                }
//
//            }
        }
    }
}

//extension QChatPresenter: QChatServiceDelegate {
//    func chatService(didFinishLoadRoom room:QRoom, withMessage message:String?) {
//        self.room = room
//        self.comments = self.generateComments(CommentModels: room.comments)
//        self.view.onLoadMessageFinished()
//        
//        self.view.onLoadRoomFinished(roomName: room.name, roomAvatar: room.avatar)
//        self.loadRoomAvatar(room: room)
//    }
//    
//    func chatService(didFailLoadRoom error:String) {
//        
//    }
//}
