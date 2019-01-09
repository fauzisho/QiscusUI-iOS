//
//  QiscusUIManager.swift
//  QiscusUI
//
//  Created by Qiscus on 26/08/18.
//
// Trick duplicate delagate when using qiscus ui chat list  and listen qiscuscore delegate

import Foundation
import QiscusCore

class QiscusUIManager {
    static var shared : QiscusUIManager = QiscusUIManager()
    var delegate  : UIChatDelegate? {
        get {
            return self._delegate
        }
        set {
            self._delegate = newValue
           setDelegate()
        }
    }
    var _delegate : UIChatDelegate? = nil
    var uidelegate : UIChatDelegate? {
        get {
            return self._uidelegate
        }
        set {
            self._uidelegate = newValue
            if self._delegate == nil {
                setDelegate()
            }
        }
    }
    var _uidelegate : UIChatDelegate? = nil
    
    private func setDelegate() {
         QiscusCore.delegate = self
    }
}

extension QiscusUIManager : QiscusCoreDelegate {
    func onRoom(deleted room: RoomModel) {
        self.uidelegate?.onRoom(deleted: room)
        self.delegate?.onRoom(deleted: room)
    }
    
    func onRoom(update room: RoomModel) {
        //
    }
    
    func onChange(user: MemberModel, isOnline online: Bool, at time: Date) {
        self.uidelegate?.onChange(user: user, isOnline: online, at: time)
        self.delegate?.onChange(user: user, isOnline: online, at: time)
    }
    
    func onRoom(_ room: RoomModel, didDeleteComment comment: CommentModel) {
        //
    }
    
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        self.uidelegate?.onRoom(room, gotNewComment: comment)
        self.delegate?.onRoom(room, gotNewComment: comment)
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        self.uidelegate?.onRoom(room, didChangeComment: comment, changeStatus: status)
        self.delegate?.onRoom(room, didChangeComment: comment, changeStatus: status)
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: MemberModel, isTyping typing: Bool) {
        self.uidelegate?.onRoom(room, thisParticipant: user, isTyping: typing)
        self.delegate?.onRoom(room, thisParticipant: user, isTyping: typing)
    }
    
    func gotNew(room: RoomModel) {
        self.uidelegate?.gotNew(room: room)
        self.delegate?.gotNew(room: room)
    }
    
    func remove(room: RoomModel) {
        self.uidelegate?.remove(room: room)
        self.delegate?.remove(room: room)
    }
}
