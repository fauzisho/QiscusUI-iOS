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
    func onLoadMessageFailed(message: String)
    func onLoadMoreMesageFinished()
    func onSendingComment(comment: CommentModel, newSection: Bool)
    func onSendMessageFinished(comment: CommentModel)
    func onGotNewComment(newSection: Bool, isMyComment: Bool)
    func onGotComment(comment: CommentModel, indexpath: IndexPath)
    func onUser(name: String, typing: Bool)
    func onUser(name: String, isOnline: Bool, message: String)
}

class UIChatPresenter: UIChatUserInteraction {
    private var viewPresenter: UIChatViewDelegate?
    var comments: [[CommentModel]]
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
        let comment = comments[atIndexPath.section][atIndexPath.row]
        return comment
    }
    
    func loadRoom(withId roomId: String) {
        //
    }
    
    func loadComments(withID roomId: String) {
        // load local
        if let _comments = QiscusCore.database.comment.find(roomId: roomId) {
            self.comments = self.groupingComments(_comments)
            print("section count \(comments.count), \(_comments.count)")
            for c in comments {
                print("comment count \(c.count)")
            }
            self.viewPresenter?.onLoadMessageFinished()
        }
        QiscusCore.shared.loadComments(roomID: roomId) { (dataResponse, error) in
            guard let response = dataResponse else {
                guard let _error = error else { return }
                self.viewPresenter?.onLoadMessageFailed(message: _error.message)
                return
            }
            // convert model
            var tempComments = [CommentModel]()
            for i in response {
                tempComments.append(i)
            }
            // MARK: TODO improve and grouping
            self.comments.removeAll()
            self.comments = self.groupingComments(tempComments)
            self.viewPresenter?.onLoadMessageFinished()
        }
    }
    
    func loadMore() {
        return
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
                            return qComment 
                        })
                        
                        self.comments.append(contentsOf: self.groupingComments(tempComments))
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
        addNewCommentUI(comment, isIncoming: false)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: comment) { (_comment, error) in
            guard let c = _comment else { return }
            self.didComment(comment: c, changeStatus: c.status)
        }
    }
    
    func sendMessage(withText text: String) {
        // create object comment
        // MARK: TODO improve object generator
        let message = CommentModel()
        message.message = text
        message.type    = "text"
        addNewCommentUI(message, isIncoming: false)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: message) { (comment, error) in
            guard let c = comment else { return }
            self.didComment(comment: c, changeStatus: c.status)
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
        addNewCommentUI(message, isIncoming: false)
        QiscusCore.shared.sendMessage(roomID: (self.room?.id)!,comment: message) { (comment, error) in
            print("failed \(String(describing: error?.message))")
        }
    }
    
    private func addNewCommentUI(_ message: CommentModel, isIncoming: Bool) {
        // add new comment to ui
        var section = false
        if self.comments.count > 0 {
            if self.comments[0].count > 0 {
                let lastComment = self.comments[0][0]
                if lastComment.userEmail == message.userEmail {
                    self.comments[0].insert(message, at: 0)
                    section = false
                } else {
                    self.comments.insert([message], at: 0)
                    section = true
                }
            } else {
                self.comments.insert([message], at: 0)
                section = true
            }
        } else {
            // last comments is empty, then create new group and append this comment
            self.comments.insert([message], at: 0)
            section = true
        }
        // choose uidelegate
        if isIncoming {
            guard let user = QiscusCore.getProfile() else { return }
            self.viewPresenter?.onGotNewComment(newSection: section, isMyComment: user.email == message.userEmail)
        }else {
            self.viewPresenter?.onSendingComment(comment: message, newSection: section)
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
    
    /// Grouping by useremail and date(same day), example [[you,you],[me,me],[me]]
    private func groupingComments(_ data: [CommentModel]) -> [[CommentModel]]{
        var retVal = [[CommentModel]]()
        let groupedMessages = Dictionary(grouping: data) { (element) -> Date in
            return element.date.reduceToMonthDayYear()
        }

        let sortedKeys = groupedMessages.keys.sorted(by: { $0.compare($1) == .orderedDescending })
        sortedKeys.forEach { (key) in
            let values = groupedMessages[key]
            retVal.append(values ?? [])
        }
        return retVal
    }
    
    func getIndexPath(comment : CommentModel, in data: [[CommentModel]]) -> IndexPath? {
        for (group,c) in data.enumerated() {
            if let index = c.index(where: { $0.uniqId == comment.uniqId }) {
                return IndexPath.init(row: index, section: group)
            }
        }
        return nil
    }
}


// MARK: Core Delegate
extension UIChatPresenter : QiscusCoreRoomDelegate {
    func gotNewComment(comment: CommentModel) {
        guard let room = self.room else { return }
        // 2check comment already in ui?
        if (self.getIndexPath(comment: comment, in: self.comments) == nil) {
            self.addNewCommentUI(comment, isIncoming: true)
            // MARK: TODO unread new comment, need trotle
            QiscusCore.shared.updateCommentRead(roomId: room.id, lastCommentReadId: comment.id)
        }
    }

    func didComment(comment: CommentModel, changeStatus status: CommentStatus) {
        // check comment already exist in view
        for (group,c) in comments.enumerated() {
            if let index = c.index(where: { $0.uniqId == comment.uniqId }) {
                // then update comment value and notice onChange()
                print("comment \(comment.message), status update \(status.rawValue)")
                print("comment change last \(comments.count), \(c.count)")
                comments[group][index] = comment
                self.viewPresenter?.onGotComment(comment: comment, indexpath: IndexPath(row: index, section: group))
            }
        }
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

extension Date {
    func reduceToMonthDayYear() -> Date {
        let calendar = Calendar.current
        let month = calendar.component(.month, from: self)
        let day = calendar.component(.day, from: self)
        let year = calendar.component(.year, from: self)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        return dateFormatter.date(from: "\(month)/\(day)/\(year)") ?? Date()
    }
}
