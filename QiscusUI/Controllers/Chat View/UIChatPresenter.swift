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
    func loadMore()
    func getMessage(inRoom roomId: String)
    func getAvatarImage(section: Int, imageView: UIImageView)
}

protocol UIChatViewDelegate {
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?)
    func onLoadMessageFinished()
    func onLoadMoreMesageFinished()
    func onSendingComment(comment: UICommentModel, newSection: Bool)
    func onSendMessageFinished(comment: UICommentModel)
    func onGotNewComment(newSection: Bool, isMyComment: Bool)
    func onUser(name: String, typing: Bool)
}

class UIChatPresenter: UIChatUserInteraction {
    private var viewPresenter: UIChatViewDelegate?
    var comments: [[UICommentModel]] = []
    var room: RoomModel? 
    var loadMoreAvailable: Bool = true
    var participants : [MemberModel] = [MemberModel]()
    
    init() {
        self.comments = [[UICommentModel]]()
    }
    
    func attachView(view : UIChatViewDelegate){
        viewPresenter = view
        if let room = self.room {
            room.delegate = self
            self.loadComments(withID: room.id)
            viewPresenter?.onLoadRoomFinished(roomName: room.name, roomAvatarURL: URL.init(string: room.avatarUrl))
            if let p = room.participants {
                self.participants = p
            }
        }
    }
    
    func detachView() {
        viewPresenter = nil
        if let room = self.room {
            room.delegate = nil
        }
    }
    
    func getComments() -> [[UICommentModel]] {
        return self.comments
    }
    
    func loadRoom(withId roomId: String) {
        
    }
    
    func loadComments(withID roomId: String) {
        QiscusCore.shared.loadComments(roomID: roomId) { (dataResponse, error) in
            self.comments.removeAll()
            // convert model
            var tempComments = [UICommentModel]()
            if let data = dataResponse {
                for i in data {
                    tempComments.append(UICommentModel.generate(i))
                }
                // MARK: TODO improve and grouping
                self.comments = self.groupingComments(comments: tempComments)
                self.viewPresenter?.onLoadMessageFinished()
            } else {
                
            }
            
        }
    }
    
    func loadMore() {
        if loadMoreAvailable {
            if let lastGroup = self.comments.last, let lastComment = lastGroup.last {
                if lastComment.id.isEmpty {
                    return
                }
                
                QiscusCore.shared.loadMore(roomID: (self.room?.id)!, lastCommentID: Int(lastComment.id)!, completion: { (commentsRsponse, error) in
                    if let comments = commentsRsponse {
                        if comments.count == 0 {
                            self.loadMoreAvailable = false
                        }
                        let tempComments = comments.map({ (qComment) -> UICommentModel in
                            return UICommentModel.generate(qComment)
                        })
                        
                        self.comments.append(contentsOf: self.groupingComments(comments: tempComments))
                        self.viewPresenter?.onLoadMoreMesageFinished()
                    } else {
                        
                    }
                })
            }
        }
    }
    
    func isTyping(_ value: Bool) {
        if let r = self.room {
            QiscusCore.shared.isTyping(value, roomID: r.id)
        }
    }
    
    func sendLocation() {
        // create object comment
        let message = UICommentModel()
        message.id = ""
        message.type = .location
        message.status = "sending"
        if let user = QiscusCore.getProfile() {
            message.email = user.email
        }
        
        // add new comment to ui
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                let lastComment = self.comments[0][0]
                if lastComment.email == message.email && lastComment.timestamp == message.timestamp {
                    self.comments[0].insert(message, at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: false)
                } else {
                    self.comments.insert([message], at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: true)
                }
            } else {
                self.comments.insert([message], at: 0)
                self.viewPresenter?.onSendingComment(comment: message, newSection: true)
            }
        } else {
            self.comments.insert([message], at: 0)
            self.viewPresenter?.onSendingComment(comment: message, newSection: true)
        }
        
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message as CommentModel) { (comment, error) in
            if comment != nil {
                message.status = "deliverd"
            }else {
                message.status = "failed"
            }
            message.onChange(message)
        }
    }
    
    func sendContact() {
        // create object comment
        let message = UICommentModel()
        message.id = ""
        message.type = .contactPerson
        message.status = "sending"
        if let user = QiscusCore.getProfile() {
            message.email = user.email
        }
        // add new comment to ui
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                let lastComment = self.comments[0][0]
                if lastComment.email == message.email && lastComment.timestamp == message.timestamp {
                    self.comments[0].insert(message, at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: false)
                } else {
                    self.comments.insert([message], at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: true)
                }
            } else {
                self.comments.insert([message], at: 0)
                self.viewPresenter?.onSendingComment(comment: message, newSection: true)
            }
        } else {
            self.comments.insert([message], at: 0)
            self.viewPresenter?.onSendingComment(comment: message, newSection: true)
        }
        
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message as CommentModel) { (comment, error) in
            if comment != nil {
                message.status = "deliverd"
            }else {
                message.status = "failed"
            }
            message.onChange(message)
        }
    }
    
    func sendImage() {
        // create object comment
        let message = UICommentModel()
        message.id = ""
        message.type = .fileAttachment
        message.status = "sending"
        if let user = QiscusCore.getProfile() {
            message.email = user.email
        }
        // add new comment to ui
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                let lastComment = self.comments[0][0]
                if lastComment.email == message.email && lastComment.timestamp == message.timestamp {
                    self.comments[0].insert(message, at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: false)
                } else {
                    self.comments.insert([message], at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: true)
                }
            } else {
                self.comments.insert([message], at: 0)
                self.viewPresenter?.onSendingComment(comment: message, newSection: true)
            }
        } else {
            self.comments.insert([message], at: 0)
            self.viewPresenter?.onSendingComment(comment: message, newSection: true)
        }
        
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message as CommentModel) { (comment, error) in
            if comment != nil {
                message.status = "deliverd"
            }else {
                message.status = "failed"
            }
            message.onChange(message)
        }
    }
    
    func sendMessage(withText text: String) {
        // create object comment
        let message = UICommentModel()
        message.id = ""
        message.message = text
        message.type = .text
        message.status = "sending"
        if let user = QiscusCore.getProfile() {
            message.email = user.email
        }
        // add new comment to ui
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                let lastComment = self.comments[0][0]
                if lastComment.email == message.email && lastComment.timestamp == message.timestamp {
                    self.comments[0].insert(message, at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: false)
                } else {
                    self.comments.insert([message], at: 0)
                    self.viewPresenter?.onSendingComment(comment: message, newSection: true)
                }
            } else {
                self.comments.insert([message], at: 0)
                self.viewPresenter?.onSendingComment(comment: message, newSection: true)
            }
        } else {
            self.comments.insert([message], at: 0)
            self.viewPresenter?.onSendingComment(comment: message, newSection: true)
        }
        
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message as CommentModel) { (comment, error) in
            if comment != nil {
                message.status = "deliverd"
            }else {
                message.status = "failed"
            }
            message.onChange(message)
        }
    }
    
    
    // MARK: TODO change this using got new comment from core
    func mockGotNewComment() {
        let commentTypes =  [CommentType.text, CommentType.fileAttachment, CommentType.contactPerson, CommentType.location]
        let commentType: CommentType = commentTypes[Int(arc4random_uniform(UInt32(commentTypes.count)))]
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            let message = UICommentModel()
            message.id = ""
            message.message = "rasakan ini balasanmu"
            message.type = commentType
            message.email = "asik"
            message.username = "horee"
            message.userAvatarUrl = URL(string: "https://image.tmdb.org/t/p/w185/tGGJOuLHX7UDlTz57sjfhW1qreP.jpg")
            
            
            self.comments.insert([message], at: 0)
            self.viewPresenter?.onGotNewComment(newSection: true, isMyComment: false)
        }
    }
    
    func getMessage(inRoom roomId: String) {
        
    }
    
    func getDate(section:Int, labelView : UILabel) {
        
    }
    
    func getAvatarImage(section: Int, imageView: UIImageView) {
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                if let url = self.comments[0][0].userAvatarUrl {
                    imageView.loadAsync(url: "\(url)")
                }
            }
        }
        
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
    
    private func loadRoomAvatar(room: RoomModel) {
        //        room.loadAvatar(onSuccess: { (avatar) in
        //            self.view.onLoadRoomFinished(roomName: room.name, roomAvatar: room.avatar)
        //        }, onError: { (error) in
        //            room.downloadRoomAvatar(onSuccess: { room in
        //                self.loadRoomAvatar(room: room)
        //            })
        //        })
    }
    
    //    private func generateComments(UICommentModels: [UICommentModel]) -> [[UICommentModel]] {
    //        var UICommentModels = UICommentModels.map { (comment) -> UICommentModel in
    //            let comment = UICommentModel(uniqueId: comment.uniqueId, id: comment.id, roomId: comment.roomId, text: comment.text, time: comment.time, date: comment.date, senderEmail: comment.senderEmail, senderName: comment.senderName, senderAvatarURL: comment.senderAvatarURL, roomName: comment.roomName, textFontName: "", textFontSize: 0, displayImage: QCacheManager.shared.getImage(onCommentUniqueId: comment.uniqueId), additionalData: comment.data, durationLabel: comment.durationLabel, currentTimeSlider: comment.currentTimeSlider, seekTimeLabel: comment.seekTimeLabel, audioIsPlaying: comment.audioIsPlaying, isDownloading: comment.isDownloading, isUploading: comment.isUploading, progress: comment.progress, isRead: comment.isRead, extras: comment.extras, isMyComment: comment.senderEmail == Qiscus.client.email, commentType: comment.type, commentStatus: comment.status, file: comment.file)
    //
    //            return comment
    //        }
    //        return self.groupingComments(comments: UICommentModels)
    //    }
    
    
    
    private func groupingComments(comments: [UICommentModel]) -> [[UICommentModel]]{
        var retVal = [[UICommentModel]]()
        var uidList = [UICommentModel]()
        
        var prevComment:UICommentModel?
        var group = [UICommentModel]()
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
        //                if let c = UICommentModel.threadSaveComment(withUniqueId: id){
        //                    c.updateCellPos(cellPos: position)
        //                }
        //            }
        //        }
        
        for comment in comments {
            if !uidList.contains(where: { (UICommentModel) -> Bool in
                return UICommentModel.id == comment.id
            }) {
                if let prev = prevComment{
                    if prev.timestamp == comment.timestamp && prev.email == comment.email {
                        uidList.append(comment)
                        group.append(comment)
                    }else{
                        retVal.append(group)
                        //                        checkPosition(ids: group)
                        group = [UICommentModel]()
                        group.append(comment)
                        uidList.append(comment)
                    }
                }else{
                    group.append(comment)
                    uidList.append(comment)
                }
                if count == comments.count - 1  {
                    retVal.append(group)
                    //                    checkPosition(ids: group)
                }else{
                    prevComment = comment
                }
            }
            count += 1
        }
        return retVal
    }
    
    // MARK : Notification center function
    @objc private func newCommentNotif(_ notification: Notification) {
        if notification.userInfo != nil {
            //            guard let property = userInfo["property"] as? RoomModelProperty else {return}
            //            if property == .lastComment {
            //                guard let room = userInfo["room"] as? RoomModel else {return}
            //                guard let comment = room.lastComment else {return}
            //
            //                if room.isInvalidated { return }
            //                if comment.senderEmail == Qiscus.client.email {
            //                    self.chatService.room(withId: room.id)
            //                    return
            //                }
            //
            //                let UICommentModel = UICommentModel(uniqueId: comment.uniqueId, id: comment.id, roomId: comment.roomId, text: comment.text, time: comment.time, date: comment.date, senderEmail: comment.senderEmail, senderName: comment.senderName, senderAvatarURL: comment.senderAvatarURL, roomName: comment.roomName, textFontName: "", textFontSize: 0, displayImage: QCacheManager.shared.getImage(onCommentUniqueId: comment.uniqueId), additionalData: comment.data, durationLabel: comment.durationLabel, currentTimeSlider: comment.currentTimeSlider, seekTimeLabel: comment.seekTimeLabel, audioIsPlaying: comment.audioIsPlaying, isDownloading: comment.isDownloading, isUploading: comment.isUploading, progress: comment.progress, isRead: comment.isRead, extras: comment.extras, isMyComment: comment.senderEmail == Qiscus.client.email, commentType: comment.type, commentStatus: comment.status, file: comment.file)
            //
            //                if let latestCommentSection = self.comments.first {
            //                    if let latestComment = latestCommentSection.first {
            //                        if UICommentModel.senderName != latestComment.senderName || UICommentModel.date != latestComment.date {
            //                            self.comments.insert([UICommentModel], at: 0)
            //                            self.view.onGotNewComment(newSection: true, isMyComment: false)
            //                        } else {
            //                            self.comments[0].insert(UICommentModel, at: 0)
            //                            self.view.onGotNewComment(newSection: false, isMyComment: false)
            //                        }
            //                    }
            //                } else {
            //                    self.comments.insert([UICommentModel], at: 0)
            //                    self.view.onGotNewComment(newSection: true, isMyComment: false)
            //                }
            //
            //            }
        }
    }
}


extension UIChatPresenter : QiscusCoreRoomDelegate {
    func onRoom(thisParticipant user: MemberModel, isTyping typing: Bool) {
        self.viewPresenter?.onUser(name: user.username, typing: typing)
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        let message = UICommentModel.generate(comment)
        self.comments.insert([message], at: 0)
        self.viewPresenter?.onGotNewComment(newSection: true, isMyComment: false)
        // MARK: TODO unread new comment, need trotle
        QiscusCore.shared.updateCommentRead(roomId: room.id, lastCommentReadId: comment.id)
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onChangeUser(_ user: UserModel, onlineStatus status: Bool, whenTime time: Date) {
        //
    }
}
