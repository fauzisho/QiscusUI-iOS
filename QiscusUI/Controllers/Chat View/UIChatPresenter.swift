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
    func getAvatarImage(section: Int, imageView: UIImageView)
    func getMessage(atIndexPath: IndexPath) -> CommentModel
}

protocol UIChatViewDelegate {
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?)
    func onLoadMessageFinished()
    func onLoadMoreMesageFinished()
    func onSendingComment(comment: CommentModel, newSection: Bool)
    func onSendMessageFinished(comment: CommentModel)
    func onGotNewComment(newSection: Bool, isMyComment: Bool)
    func onUser(name: String, typing: Bool)
    func onUser(name: String, isOnline: Bool, message: String)
}

class UIChatPresenter: UIChatUserInteraction {
    private var viewPresenter: UIChatViewDelegate?
    var comments: [[CommentModel]] = []
    var room: RoomModel? 
    var loadMoreAvailable: Bool = true
    var participants : [MemberModel] = [MemberModel]()
    
    init() {
        self.comments = [[CommentModel]]()
    }
    
    func attachView(view : UIChatViewDelegate){
        viewPresenter = view
        if let room = self.room {
            room.delegate = self
            self.loadComments(withID: room.id)
            viewPresenter?.onLoadRoomFinished(roomName: room.name, roomAvatarURL: room.avatarUrl)
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
    
    func getMessage(atIndexPath: IndexPath) -> CommentModel {
        let comments = self.comments
        let comment = comments[atIndexPath.section][atIndexPath.row]
        return comment
    }
    
    func getComments() -> [[CommentModel]] {
        return self.comments
    }
    
    func loadRoom(withId roomId: String) {
        
    }
    
    func loadComments(withID roomId: String) {
        // load local
        if let _comments = QiscusCore.dataStore.getCommentbyRoomID(id: roomId) {
            self.comments = self.groupingComments(comments: _comments)
            self.viewPresenter?.onLoadMessageFinished()
        }
        QiscusCore.shared.loadComments(roomID: roomId) { (dataResponse, error) in
            self.comments.removeAll()
            // convert model
            var tempComments = [CommentModel]()
            if let data = dataResponse {
                for i in data {
                    tempComments.append(i)
                }
                // MARK: TODO improve and grouping
                self.comments = self.groupingComments(comments: tempComments)
                self.viewPresenter?.onLoadMessageFinished()
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
                        let tempComments = comments.map({ (qComment) -> CommentModel in
                            return qComment as! CommentModel
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
    
    func sendMessage(withComment comment: CommentModel) {
        
        addNewCommentUI(comment)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: comment) { (_comment, error) in
            
        }
    }
    
    func sendMessage(withText text: String) {
        // create object comment
        // MARK: TODO improve object generator
        let message = CommentModel()
        message.message = text
        message.type    = "text"
        addNewCommentUI(message)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: message) { (comment, error) in
            
        }
    }
    
    func sendMessageLoc() {
        // create object comment
        // MARK: TODO improve object generator
        let message = CommentModel()
        message.message = "location"
        message.type    = "custom"
        message.payload = [
            "type" : "data",
            "content" : "",
        ]
        addNewCommentUI(message)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: message) { (comment, error) in
            print("failed \(String(describing: error?.message))")
        }
    }
    
    private func addNewCommentUI(_ message: CommentModel) {
            // add new comment to ui
            if self.comments.count > 0 {
                if self.comments[0].count > 0 {
                    let lastComment = self.comments[0][0]
                    if lastComment.userEmail == message.userEmail && lastComment.timestamp == message.timestamp {
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
    
    func getAvatarImage(section: Int, imageView: UIImageView) {
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                if let url = self.comments[0][0].userAvatarUrl {
                    imageView.loadAsync(url: "\(url)")
                }
            }
        }
        
    }
    
    private func groupingComments(comments: [CommentModel]) -> [[CommentModel]]{
        var retVal = [[CommentModel]]()
        var uidList = [CommentModel]()
        
        var prevComment:CommentModel?
        var group = [CommentModel]()
        var count = 0
        
        for comment in comments {
            if !uidList.contains(where: { (CommentModel) -> Bool in
                return CommentModel.id == comment.id
            }) {
                if let prev = prevComment{
                    if prev.timestamp == comment.timestamp && prev.userEmail == comment.userEmail {
                        uidList.append(comment)
                        group.append(comment)
                    }else{
                        retVal.append(group)
                        //                        checkPosition(ids: group)
                        group = [CommentModel]()
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
        let message = comment as! CommentModel
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
            if room.type != .group {
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
