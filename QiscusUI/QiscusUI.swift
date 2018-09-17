//
//  QiscusUI.swift
//  QiscusUI
//
//  Created by Rahardyan Bisma on 25/05/18.
//

import Foundation
import QiscusCore

public class QiscusUI {
    class var bundle:Bundle{
        get{
            let podBundle = Bundle(for: QiscusUI.self)
            
            if let bundleURL = podBundle.url(forResource: "QiscusUI", withExtension: "bundle") {
                return Bundle(url: bundleURL)!
            }else{
                return podBundle
            }
        }
    }
    public static var enableDebugPrint: Bool = false
    static var disableLocalization: Bool = false
    
    public static var delegate  : UIChatDelegate? {
        get {
            return QiscusUIManager.shared.delegate
        }
        set {
            QiscusUIManager.shared.delegate = newValue
        }
    }
    
    @objc public class func image(named name:String)->UIImage?{
        return UIImage(named: name, in: QiscusUI.bundle, compatibleWith: nil)?.localizedImage()
    }
}


