//
//  QChatVC.swift
//  Qiscus
//
//  Created by Rahardyan Bisma on 07/05/18.
//

import UIKit
import ContactsUI
import SwiftyJSON
import QiscusCore

// Chat view blue print or open function
public protocol UIChatView {
    func uiChat(viewController : UIChatViewController, didSelectMessage message: CommentModel)
    func uiChat(viewController : UIChatViewController, performAction action: Selector, forRowAt message: CommentModel, withSender sender: Any?)
    func uiChat(viewController : UIChatViewController, canPerformAction action: Selector, forRowAtmessage: CommentModel, withSender sender: Any?) -> Bool
    func uiChat(viewController : UIChatViewController, firstMessage message: CommentModel, viewForHeaderInSection section: Int) -> UIView?
    func uiChat(viewController : UIChatViewController, cellForMessage message: CommentModel) -> UIBaseChatCell?

    func uiChat(navigationView inViewConroller: UIChatViewController) -> UIChatNavigation?
    func uiChat(input inViewController: UIChatViewController) -> UIChatInput?
}

class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = #colorLiteral(red: 0.3555911001, green: 0.7599821354, blue: 1, alpha: 0.7924068921)
        textColor = .darkGray
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont.boldSystemFont(ofSize: 9.5)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 15, height: height)
    }
    
}

open class UIChatViewController: UIViewController {
    @IBOutlet weak var tableViewConversation: UITableView!
    @IBOutlet weak var viewChatInput: UIView!
    @IBOutlet weak var constraintViewInputBottom: NSLayoutConstraint!
    @IBOutlet weak var constraintViewInputHeight: NSLayoutConstraint!
    public var chatTitleView : UIChatNavigation = UIChatNavigation()
    
    private var presenter: UIChatPresenter = UIChatPresenter()
    var heightAtIndexPath: [String: CGFloat] = [:]
    var roomId: String = ""
    public var chatDelegate : UIChatView? = nil
    
    public var room : RoomModel? {
        set(newValue) {
            self.presenter.room = newValue
            self.refreshUI()
        }
        get {
            return self.presenter.room
        }
    }
    
    public init() {
        super.init(nibName: "UIChatViewController", bundle: QiscusUI.bundle)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override open func viewDidLoad() {
        super.viewDidLoad()
        self.setupUI()
    }
    
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.presenter.attachView(view: self)
        let center: NotificationCenter = NotificationCenter.default
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardChange(_:)), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        view.endEditing(true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        
        view.endEditing(true)
    }
    
    override open func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        self.presenter.detachView()
    }
    
    // Provide new flow, load chat ui then set room. old Qiscus SDK
    // MARK: TODO need optimize, prevent call api twice
    func refreshUI() {
        if self.isViewLoaded {
            self.presenter.attachView(view: self)
            self.setupUI()
        }
    }
    
    // MARK: View Event Listener
    
    private func setupUI() {
        // config navBar
        self.setupNavigationTitle()
        self.qiscusAutoHideKeyboard()
        self.setupTableView()
        
        // setup chatInputBar
        if let customInputBar = self.chatDelegate?.uiChat(input: self) {
            self.setupInputBar(customInputBar)
        }else {
            // use default
            self.setupInputBar(UIChatInput())
        }
    }
    
    private func setupInputBar(_ inputchatview: UIChatInput) {
        inputchatview.frame.size    = self.viewChatInput.frame.size
        inputchatview.frame.origin  = CGPoint.init(x: 0, y: 0)
        inputchatview.translatesAutoresizingMaskIntoConstraints = false
        inputchatview.delegate = self
        
        self.viewChatInput.addSubview(inputchatview)
        
        NSLayoutConstraint.activate([
            inputchatview.topAnchor.constraint(equalTo: self.viewChatInput.topAnchor, constant: 0),
            inputchatview.leftAnchor.constraint(equalTo: self.viewChatInput.leftAnchor, constant: 0),
            inputchatview.rightAnchor.constraint(equalTo: self.viewChatInput.rightAnchor, constant: 0),
            inputchatview.bottomAnchor.constraint(equalTo: self.viewChatInput.bottomAnchor, constant: 0)
            ])
    }
    
    private func setupNavigationTitle(){
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = false
        }
        var totalButton = 1
        if let leftButtons = self.navigationItem.leftBarButtonItems {
            totalButton += leftButtons.count
        }
        if let rightButtons = self.navigationItem.rightBarButtonItems {
            totalButton += rightButtons.count
        }
        
        let backButton = self.backButton(self, action: #selector(UIChatViewController.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        if let customNavigation = self.chatDelegate?.uiChat(navigationView: self) {
            customNavigation.frame = self.navigationController?.navigationBar.frame ?? CGRect.zero
            self.navigationItem.titleView = customNavigation
            customNavigation.room = room
        }else {
            self.chatTitleView = UIChatNavigation(frame: self.navigationController?.navigationBar.frame ?? CGRect.zero)
            self.navigationItem.titleView = chatTitleView
            self.chatTitleView.room = room
        }
        
        
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = QiscusUI.image(named: "ic_back")?.withRenderingMode(UIImage.RenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UINavigationBar.appearance().tintColor
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 13,height: 22)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 13,height: 22)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 23,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControl.Event.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func setupTableView() {
        let rotate = CGAffineTransform(rotationAngle: .pi)
        self.tableViewConversation.transform = rotate
        self.tableViewConversation.scrollIndicatorInsets = UIEdgeInsets(top: 0,left: 0,bottom: 0,right: UIScreen.main.bounds.width - 8)
        self.tableViewConversation.rowHeight = UITableView.automaticDimension
        self.tableViewConversation.dataSource = self
        self.tableViewConversation.delegate = self
        self.tableViewConversation.scrollsToTop = false
        self.tableViewConversation.allowsSelection = false
        
        self.tableViewConversation.register(UINib(nibName: "TextCell", bundle: QiscusUI.bundle), forCellReuseIdentifier: "TextCell")
        
    }
    
    @objc func goBack() {
        view.endEditing(true)
        self.navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Keyboard Methode
    @objc func keyboardWillHide(_ notification: Notification){
        let info: NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        self.constraintViewInputBottom.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        self.constraintViewInputBottom.constant = 0 - keyboardHeight
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIView.AnimationOptions(), animations: {
            self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    func getParticipant() -> String {
        var result = ""
        for m in self.presenter.participants {
            if result.isEmpty {
                result = m.username
            }else {
                result = result + ", \(m.username)"
            }
        }
        return result
    }
    
    public func reusableCell(withIdentifier identifier: String, for comment: CommentModel) -> UIBaseChatCell {
        if let indexPath = self.presenter.getIndexPath(comment: comment) {
            return self.tableViewConversation.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UIBaseChatCell
        }else {
            return self.tableViewConversation.dequeueReusableCell(withIdentifier: "TextCell") as! UIBaseChatCell
        }
    }
    
    // MARK : Public open method
    public func registerClass(nib: UINib?, forMessageCellWithReuseIdentifier reuseIdentifier: String) {
        self.tableViewConversation.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    
    public func setBackground(with image: UIImage) {
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFill
        imageView.transform = imageView.transform.rotated(by: CGFloat(M_PI))
        self.tableViewConversation.isOpaque = false
        self.tableViewConversation.backgroundView =   imageView
    }
    
    public func setBackground(with color: UIColor) {
        self.tableViewConversation.backgroundColor = color
    }
    
    public func scrollToComment(comment: CommentModel) {
        if let indexPath = self.presenter.getIndexPath(comment: comment) {
            self.tableViewConversation.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
    
    public func reloadToComment(comment: CommentModel) {
        if let indexPath = self.presenter.getIndexPath(comment: comment) {
             self.tableViewConversation.reloadRows(at: [indexPath], with: .none)
        }
    }

}

// MARK: UIChatDelegate
extension UIChatViewController: UIChatViewDelegate {
    func onReloadComment(){
        self.tableViewConversation.reloadData()
    }
    func onUpdateComment(comment: CommentModel, indexpath: IndexPath) {
        // reload cell in section and index path
        if self.tableViewConversation.cellForRow(at: indexpath) != nil{
            self.reloadToComment(comment: comment)
        }
    }
    
    func onLoadMessageFailed(message: String) {
        //
    }
    
    func onUser(name: String, isOnline: Bool, message: String) {
        self.chatTitleView.labelSubtitle.text = message
    }
    
    func onUser(name: String, typing: Bool) {
        if typing {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.chatTitleView.labelSubtitle.text = "\(name) is Typing..."
                }else {
                    self.chatTitleView.labelSubtitle.text = "is Typing..."
                }
            }
        }else {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.chatTitleView.labelSubtitle.text = getParticipant()
                }else {
                    let user = QiscusCore.getProfile()
                    guard let opponent = self.presenter.participants.filter({ $0.email == user?.email ?? ""}).first else { return }
                    guard let lastSeen = opponent.lastSeen() else { return }
                    self.chatTitleView.labelSubtitle.text = lastSeen.timeAgoSinceDate(numericDates: false)
                }
            }
        }
    }
    
    func onSendingComment(comment: CommentModel, newSection: Bool) {
        if newSection {
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .left)
            self.tableViewConversation.endUpdates()
            self.scrollToComment(comment: comment)
        } else {
            let indexPath = IndexPath(row: 0, section: 0) // all view rotate because of this
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertRows(at: [indexPath], with: .left)
            self.tableViewConversation.endUpdates()
            self.scrollToComment(comment: comment)
        }
    }
    
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?) {
        if let _room = room {
            self.chatTitleView.room = _room
        }
    }
    
    func onLoadMoreMesageFinished() {
        self.tableViewConversation.reloadData()
    }
    
    func onLoadMessageFinished() {
        self.tableViewConversation.reloadData()
    }
    
    func onSendMessageFinished(comment: CommentModel) {
        
    }
    
    func onGotNewComment(comment: CommentModel, newSection: Bool) {
        if Thread.isMainThread {
            if newSection {
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .right)
                self.tableViewConversation.endUpdates()
                self.scrollToComment(comment: comment)
                
                
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertRows(at: [indexPath], with: .right)
                self.tableViewConversation.endUpdates()
                self.scrollToComment(comment: comment)
                
            }
        }
    }
}


extension UIChatViewController: UITableViewDataSource {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionCount = self.presenter.comments.count
        let rowCount = self.presenter.comments[section].count
        if sectionCount == 0 {
            return 0
        }
        return rowCount
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return self.presenter.comments.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // MARK: table cell confi
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get mesage at indexpath
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        var cell = tableView.dequeueReusableCell(withIdentifier: "TextCell", for: indexPath) as! UIBaseChatCell
        
        // Checking Custom Cell
        if let _custom = self.chatDelegate?.uiChat(viewController: self, cellForMessage: comment) {
            cell = _custom
        }
        cell.comment = comment
        cell.layer.shouldRasterize = true
        cell.layer.rasterizationScale = UIScreen.main.scale
        
        // Load More
        let comments = self.presenter.comments
        if indexPath.section == comments.count - 1 && indexPath.row > comments[indexPath.section].count - 10 {
            presenter.loadMore()
        }
        return cell
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    public func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 20
    }
    
    public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if let firstMessageInSection = self.presenter.comments[section].first {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "E, d MMM"
            let dateString = dateFormatter.string(from: firstMessageInSection.date)
            
            let label = DateHeaderLabel()
            label.text = dateString
            
            let containerView = UIView()
            containerView.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
            containerView.addSubview(label)
            label.centerXAnchor.constraint(equalTo: containerView.centerXAnchor).isActive = true
            label.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            
            return containerView
            
        }
        return nil
    }
    
}

extension UIChatViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // get mesage at indexpath
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        self.chatDelegate?.uiChat(viewController: self, didSelectMessage: comment)
    }
    
    public func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    public func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        if let response = self.chatDelegate?.uiChat(viewController: self, canPerformAction: action, forRowAtmessage: comment, withSender: sender) {
            return response
        }else {
            return false
        }
    }
    
    public func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        self.chatDelegate?.uiChat(viewController: self, performAction: action, forRowAt: comment, withSender: sender)
    }
    
}

extension UIChatViewController : UIChatInputDelegate {
    func onHeightChanged(height: CGFloat) {
        self.constraintViewInputHeight.constant = height
    }
    
    func typing(_ value: Bool) {
        self.presenter.isTyping(value)
    }
    
    public func send(message: CommentModel,onSuccess: @escaping (CommentModel) -> Void, onError: @escaping (String) -> Void) {
        self.presenter.sendMessage(withComment: message, onSuccess: { (comment) in
            onSuccess(comment)
        }) { (error) in
            onError(error)
        }
    }
}
