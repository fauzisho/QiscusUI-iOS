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
    func onUser(name: String, isOnline: Bool, message: String)
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
        message.message = text
        message.type = .text
        message.status = "sending"
        if let user = QiscusCore.getProfile() {
            message.email = user.email
        }
        addNewCommentUI(message)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!, comment: message as CommentModel) { (comment, error) in
            if comment != nil {
                message.status = "deliverd"
            }else {
                message.status = "failed"
            }
            message.onChange(message)
        }
    }
    
    private func addNewCommentUI(_ message: UICommentModel) {
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

    }
    
    private func groupingComments(comments: [UICommentModel]) -> [[UICommentModel]]{
        var retVal = [[UICommentModel]]()
        var uidList = [UICommentModel]()
        
        var prevComment:UICommentModel?
        var group = [UICommentModel]()
        var count = 0
        
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
    
    
}


extension UIChatPresenter : QiscusCoreRoomDelegate {
    func gotNewComment(comment: CommentModel) {
        guard let room = self.room else { return }
        let message = UICommentModel.generate(comment)
        self.comments.insert([message], at: 0)
        self.viewPresenter?.onGotNewComment(newSection: true, isMyComment: false)
        // MARK: TODO unread new comment, need trotle
        QiscusCore.shared.updateCommentRead(roomId: room.id, lastCommentReadId: comment.id)
    }
    
    func didComment(comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(thisParticipant user: MemberModel, isTyping typing: Bool) {
        self.viewPresenter?.onUser(name: user.username, typing: typing)
    }
    
    func onChangeUser(_ user: MemberModel, onlineStatus status: Bool, whenTime time: Date) {
        if let room = self.room {
            if room.chatType != "group" {
                var message = ""
                //let lessMinute = time.timeIntervalSinceNow.second
                //if lessMinute <= 59 {
                    message = "online"
               // }else {
                    //if lessMinute
                   // message = "Last seen .. ago"
                //}
                self.viewPresenter?.onUser(name: user.username, isOnline: status, message: message)
            }
        }
    }
}
