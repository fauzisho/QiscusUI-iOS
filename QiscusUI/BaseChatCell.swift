//
//  BaseChatCell.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 09/05/18.
//

import Foundation
import QiscusCore

// UIBaseChatCell Interface
protocol UIMessagePresenting {
    func present(message: CommentModel)
    func update(message: CommentModel)
    var comment: CommentModel? { get set }
}

open class UIBaseChatCell: UITableViewCell, UIMessagePresenting {
    // MARK: cell data source
    public var comment: CommentModel? {
        set {
            self._comment = newValue
            if let data = newValue { present(message: data) } // bind data only
//            comment?.onChange = { newComment in
//                self.comment = newComment
//                self.update(message: newComment)
//            }
        }
        get {
            return self._comment
        }
    }
    private var _comment : CommentModel? = nil
    var indexPath: IndexPath!
    var firstInSection: Bool = false
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.configureUI()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.configureUI()
    }
    
    open func present(message: CommentModel) {
        preconditionFailure("this func must be override, without super")
    }
    
    open func update(message: CommentModel) {
        preconditionFailure("this func must be override, without super")
    }
    
    /// configure ui element when init cell
    func configureUI() {
        // MARK: configure long press on cell
        self.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi))
    }
}
