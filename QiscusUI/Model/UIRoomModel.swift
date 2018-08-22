//
//  UIRoomModel.swift
//  QiscusCore
//
//  Created by Qiscus on 22/08/18.
//

import Foundation
import QiscusCore

class UIRoomModel : RoomModel {
    var onChange : (UIRoomModel) -> Void = { _ in}
    
    class func generate(_ i:RoomModel) -> UIRoomModel {
        let new = UIRoomModel()
        new.id              = i.id

        // ...
        return new
    }
}
