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

// Chat view blue print
protocol UIChatView {
    func registerClass(nib: UINib?, forMessageCellWithReuseIdentifier reuseIdentifier: String)
    func indentifierFor(message: CommentModel, atUIChatViewController : UIChatViewController) -> String
    func chatInputBar() -> UIChatInput?
    func chatViewController(viewController : UIChatViewController, didSelectMessage message: CommentModel)
//    func allComments() -> [[CommentModel]]
}

class DateHeaderLabel: UILabel {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .clear
        textColor = .gray
        textAlignment = .center
        translatesAutoresizingMaskIntoConstraints = false // enables auto layout
        font = UIFont.boldSystemFont(ofSize: 10)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override var intrinsicContentSize: CGSize {
        let originalContentSize = super.intrinsicContentSize
        let height = originalContentSize.height + 12
        layer.cornerRadius = height / 2
        layer.masksToBounds = true
        return CGSize(width: originalContentSize.width + 10, height: height)
    }
    
}

open class UIChatViewController: UIViewController, UIChatView {
    @IBOutlet weak var tableViewConversation: UITableView!
    @IBOutlet weak var viewChatInput: UIView!
    @IBOutlet weak var viewInput: NSLayoutConstraint!
    @IBOutlet weak var constraintViewInputBottom: NSLayoutConstraint!
    private var titleLabel = UILabel()
    private var subtitleLabel = UILabel()
    private var subtitleText:String = ""
    private var roomAvatar = UIImageView()
    private var titleView = UIView()
    private var presenter: UIChatPresenter = UIChatPresenter()
    var heightAtIndexPath: [String: CGFloat] = [:]
    var roomId: String = ""

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
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        center.addObserver(self, selector: #selector(UIChatViewController.keyboardChange(_:)), name: NSNotification.Name.UIKeyboardWillChangeFrame, object: nil)
        view.endEditing(true)
    }
    
    override open func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillChangeFrame, object: nil)
        
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
        if let customInputBar = chatInputBar() {
            self.setupInputBar(customInputBar)
        }else {
            // use default
            self.setupInputBar(UIChatInput())
        }
    }
    
    open func chatInputBar() -> UIChatInput? {
        return nil
    }
    
    private func setupInputBar(_ inputchatview: UIChatInput) {
        inputchatview.frame.size    = self.viewChatInput.frame.size
        inputchatview.frame.origin  = CGPoint.init(x: 0, y: 0)
        inputchatview.delegate = self
        self.viewChatInput.addSubview(inputchatview)
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
        
        //        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(QiscusChatVC.goToTitleAction))
        //        self.titleView.addGestureRecognizer(tapRecognizer)
        
        let containerWidth = QiscusUIHelper.screenWidth() - 49
        let titleWidth = QiscusUIHelper.screenWidth() - CGFloat(49 * totalButton) - 40
        
        self.titleLabel.frame = CGRect(x: 40, y: 7, width: titleWidth, height: 17)
        self.titleLabel.textColor = UINavigationBar.appearance().tintColor
        
        self.subtitleLabel.frame = CGRect(x: 40, y: 25, width: titleWidth, height: 13)
//        self.subtitleLabel.font.withSize(9.0)
        self.subtitleLabel.textColor = UIColor.gray
        
        self.roomAvatar.frame = CGRect(x: 0,y: 6,width: 32,height: 32)
        self.roomAvatar.layer.cornerRadius = 16
        self.roomAvatar.contentMode = .scaleAspectFill
        self.roomAvatar.backgroundColor = UIColor.white
        //        let bgColor = QiscusColorConfiguration.sharedInstance.avatarBackgroundColor
        self.roomAvatar.frame = CGRect(x: 0,y: 6,width: 32,height: 32)
        self.roomAvatar.layer.cornerRadius = 16
        self.roomAvatar.clipsToBounds = true
        //        self.roomAvatar.backgroundColor = bgColor[0]
        
        self.titleView.frame = CGRect(x: 0, y: 0, width: containerWidth, height: 44)
        self.titleView.addSubview(self.titleLabel)
        self.titleView.addSubview(self.subtitleLabel)
        self.titleView.addSubview(self.roomAvatar)
        
        let backButton = self.backButton(self, action: #selector(UIChatViewController.goBack))
        self.navigationItem.setHidesBackButton(true, animated: false)
        self.navigationItem.leftBarButtonItems = [backButton]
        
        self.navigationItem.titleView = titleView
    }
    
    private func backButton(_ target: UIViewController, action: Selector) -> UIBarButtonItem{
        let backIcon = UIImageView()
        backIcon.contentMode = .scaleAspectFit
        
        let image = QiscusUI.image(named: "ic_back")?.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        backIcon.image = image
        backIcon.tintColor = UINavigationBar.appearance().tintColor
        
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            backIcon.frame = CGRect(x: 0,y: 11,width: 13,height: 22)
        }else{
            backIcon.frame = CGRect(x: 22,y: 11,width: 13,height: 22)
        }
        
        let backButton = UIButton(frame:CGRect(x: 0,y: 0,width: 23,height: 44))
        backButton.addSubview(backIcon)
        backButton.addTarget(target, action: action, for: UIControlEvents.touchUpInside)
        return UIBarButtonItem(customView: backButton)
    }
    
    private func setupTableView() {
        let rotate = CGAffineTransform(rotationAngle: .pi)
        self.tableViewConversation.transform = rotate
        self.tableViewConversation.scrollIndicatorInsets = UIEdgeInsetsMake(0,0,0,UIScreen.main.bounds.width - 8)
        self.tableViewConversation.rowHeight = UITableViewAutomaticDimension
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
        
        let animateDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        //        let goToRow = self.lastVisibleRow
        self.constraintViewInputBottom.constant = 0
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            //            if goToRow != nil {
            //                self.collectionView.scrollToItem(at: goToRow!, at: .bottom, animated: false)
            //            }
        }, completion: nil)
    }
    
    @objc func keyboardChange(_ notification: Notification){
        let info:NSDictionary = (notification as NSNotification).userInfo! as NSDictionary
        let keyboardSize = (info[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        let keyboardHeight: CGFloat = keyboardSize.height
        let animateDuration = info[UIKeyboardAnimationDurationUserInfoKey] as! Double
        
        self.constraintViewInputBottom.constant = 0 - keyboardHeight
        //        let goToRow = self.lastVisibleRow
        UIView.animate(withDuration: animateDuration, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
            //            if goToRow != nil {
            //                self.collectionView.scrollToItem(at: goToRow!, at: .bottom, animated: true)
            //            }
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
    
    open func indentifierFor(message: CommentModel, atUIChatViewController: UIChatViewController) -> String {
        return "TextCell"
    }
    
    public func registerClass(nib: UINib?, forMessageCellWithReuseIdentifier reuseIdentifier: String) {
        self.tableViewConversation.register(nib, forCellReuseIdentifier: reuseIdentifier)
    }
    
    open func chatViewController(viewController: UIChatViewController, didSelectMessage message: CommentModel) {
        //
    }
}

// MARK: UIChatDelegate
extension UIChatViewController: UIChatViewDelegate {
    func onGotComment(comment: CommentModel, indexpath: IndexPath) {
        // reload cell in section and index path
        self.tableViewConversation.reloadRows(at: [indexpath], with: .automatic)
    }
    
    func onLoadMessageFailed(message: String) {
        //
    }
    
    func onUser(name: String, isOnline: Bool, message: String) {
        self.subtitleLabel.text = message
    }
    
    func onUser(name: String, typing: Bool) {
        if typing {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.subtitleLabel.text = "\(name) is Typing..."
                }else {
                    self.subtitleLabel.text = "is Typing..."
                }
            }
        }else {
            if let room = self.presenter.room {
                if room.type == .group {
                    self.subtitleLabel.text = getParticipant()
                }else {
                    self.subtitleLabel.text = "" // or last seen at
                }
            }
        }
    }
    
    func onSendingComment(comment: CommentModel, newSection: Bool) {
        if newSection {
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .left)
            self.tableViewConversation.endUpdates()
        } else {
            let indexPath = IndexPath(row: 0, section: 0)
            self.tableViewConversation.beginUpdates()
            self.tableViewConversation.insertRows(at: [indexPath], with: .left)
            self.tableViewConversation.endUpdates()
        }
    }
    
    func onLoadRoomFinished(roomName: String, roomAvatarURL: URL?) {
        DispatchQueue.main.async {
            self.titleLabel.text = roomName
            guard let avatar = roomAvatarURL else { return }
            self.roomAvatar.af_setImage(withURL: avatar)
        }
    }
    
    func onLoadMoreMesageFinished() {
        //self.tableViewConversation.reloadData()
    }
    
    func onLoadMessageFinished() {
        self.tableViewConversation.reloadData()
    }
    
    func onSendMessageFinished(comment: CommentModel) {
        
    }
    
    func onGotNewComment(newSection: Bool, isMyComment: Bool) {
        if Thread.isMainThread {
            if newSection {
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertSections(IndexSet(integer: 0), with: .right)
                if isMyComment {
                    self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
                self.tableViewConversation.endUpdates()
            } else {
                let indexPath = IndexPath(row: 0, section: 0)
                self.tableViewConversation.beginUpdates()
                self.tableViewConversation.insertRows(at: [indexPath], with: .right)
                if isMyComment {
                    self.tableViewConversation.scrollToRow(at: IndexPath(row: 0, section: 0), at: .bottom, animated: true)
                }
                self.tableViewConversation.endUpdates()
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
        print("number of section \(self.presenter.comments.count)")
        return self.presenter.comments.count
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableViewAutomaticDimension
    }
    
    // MARK: table cell confi
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // get mesage at indexpath
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        // get cell identifier at indexpath
        let identifier = indentifierFor(message: comment, atUIChatViewController: self)
        // generate cell by index path
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! UIBaseChatCell
        // setup cell message = this message
        cell.comment = comment
//        cell.firstInSection = indexPath.row == self.presenter.getComments()[indexPath.section].count - 1
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
            dateFormatter.dateFormat = "dd/MM/yyyy"
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
    
    // MARK: chat avatar setup
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: QiscusUIHelper.screenWidth(), height: 0))
        view.backgroundColor = .clear
        view.transform = CGAffineTransform(rotationAngle: CGFloat.pi)
        
        let viewAvatar = UIView(frame: CGRect(x: 5, y: -30, width: 30, height: 60))
        let avatar = UIImageView(frame: CGRect(x: 5, y: 0, width: 30, height: 30))
        avatar.clipsToBounds = true
        avatar.layer.cornerRadius = avatar.frame.width/2
        avatar.backgroundColor = .black
        avatar.contentMode = .scaleAspectFill
        
        viewAvatar.addSubview(avatar)
        
        self.presenter.getAvatarImage(section: section, imageView: avatar)
        
        
        view.addSubview(viewAvatar)
        
        if let firstComment = self.presenter.getComments()[section].first {
            if firstComment.isMyComment() {
                return nil
            } else {
                return view
            }
        }
        return view
    }
}

extension UIChatViewController : UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        self.presenter.isTyping(true)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        self.presenter.isTyping(false)
    }
}

extension UIChatViewController: UITableViewDelegate {
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // get mesage at indexpath
        let comment = self.presenter.getMessage(atIndexPath: indexPath)
        self.chatViewController(viewController: self, didSelectMessage: comment)
    }
    
}

extension UIChatViewController : UIChatInputDelegate {
    public func send(message: CommentModel) {
        print("number of comment : \(self.presenter.comments.count)")
        self.presenter.sendMessage(withComment: message)
    }
}
