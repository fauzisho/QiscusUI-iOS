//
//  Protocol.swift
//  QiscusUI
//
//  Created by Qiscus on 30/07/18.
//  Copyright © 2018 Qiscus. All rights reserved.
//

import UIKit
import QiscusCore

protocol BaseView {
    func startLoading(message: String)
    func finishLoading(message: String)
    func setEmptyData(message: String)
}

public protocol UIChatDelegate : QiscusCoreDelegate {
    
}
