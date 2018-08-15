//
//  UIChatListPresenter.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import Foundation
import QiscusCore

protocol UIChatListView : BaseView {
    func didFinishLoadChat(rooms : [RoomModel])
    
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    var rooms : [RoomModel]? = nil
    
    init() {
        QiscusCore.delegate = self
    }
    
    func attachView(view : UIChatListView){
        viewPresenter = view
    }
    
    func detachView() {
        viewPresenter = nil
    }
    
    func loadChat() {
        QiscusCore.shared.getAllRoom { (rooms, error) in
            if let results = rooms {
                self.viewPresenter?.didFinishLoadChat(rooms: results)
                self.rooms = results
            }else {
                self.viewPresenter?.setEmptyData(message: "")
            }
        }
    }
}

extension UIChatListPresenter : QiscusCoreDelegate {
    func onRoom(_ room: RoomModel, gotNewComment comment: CommentModel) {
        //
        print("got new comment: \(comment.message)")
    }
    
    func onRoom(_ room: RoomModel, didChangeComment comment: CommentModel, changeStatus status: CommentStatus) {
        //
    }
    
    func onRoom(_ room: RoomModel, thisParticipant user: ParticipantModel, isTyping typing: Bool) {
        //
    }
    
    func onChangeUser(_ user: UserModel, onlineStatus status: Bool, whenTime time: Date) {
        //
    }
    
    func gotNew(room: RoomModel) {
        //
    }
    
    func onroom(change: RoomModel) {
        //
    }
    
    func remove(room: RoomModel) {
        //
    }
}
