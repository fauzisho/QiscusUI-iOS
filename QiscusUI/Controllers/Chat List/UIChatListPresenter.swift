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
    func didFinishLoadChat(rooms : [QRoom])
}

class UIChatListPresenter {
    
    private var viewPresenter : UIChatListView?
    
    init() {
        
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
            }else {
                self.viewPresenter?.setEmptyData(message: "")
            }
        }
    }
}
