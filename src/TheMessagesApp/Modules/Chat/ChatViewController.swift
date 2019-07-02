//
//  ChatViewController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import UIKit
import RxSwift
import MessageKit

final class ChatViewController: MessagesViewController {
    private let bag = DisposeBag()
    private var coordinator: ChatCoordinator!
    private var cameraItem: InputBarButtonItem!
    
    private var messages: [Message] {
        get {
            return coordinator.viewModel.messages
        }
       
        set {
            coordinator.viewModel.messages = newValue
        }
    }
    
    init(user: LocalUser, channel: Channel) {
        super.init(nibName: nil, bundle: nil)
        self.coordinator = ChatCoordinator(self, user: user, channel: channel)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.emit(ChatViewDidLoadEvent())
        
        title = coordinator.viewModel.title
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true

        setupCollectionView()
        setupCameraButton()
        setupInputBar()
        setupSubscribers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK:- Setup functions
private extension ChatViewController {
    func setupCollectionView() {
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
    }
    
    func setupCameraButton() {
        cameraItem = InputBarButtonItem(type: .system)
        cameraItem.tintColor = .primary
        cameraItem.image = #imageLiteral(resourceName: "camera")
        cameraItem.setSize(CGSize(width: 60, height: 30), animated: false)
    }
    
    func setupInputBar() {
        messageInputBar.inputTextView.tintColor = .primary
        messageInputBar.sendButton.setTitleColor(.primary, for: .normal)
        messageInputBar.delegate = self
        messageInputBar.leftStackView.alignment = .center
        messageInputBar.setLeftStackViewWidthConstant(to: 50, animated: false)
        messageInputBar.setStackViewItems([cameraItem], forStack: .left, animated: false)
    }
    
    func setupSubscribers() {
        setupCoordinatorSubscribers()
        setupUISubscribers()
    }
}

// MARK:- Rx subscribers
private extension ChatViewController {
    func setupCoordinatorSubscribers() {
        bag.insert(
            // New message
            coordinator.viewModel.newMessage.subscribe() { [weak self] event in
                guard let message = event.element else { return }
                self?.insertNewMessage(message)
            },
            
            // Sending photo status
            coordinator.viewModel.isSendingPhoto.subscribe() { [unowned self] event in
                guard let isSendingPhoto = event.element else { return }
                
                DispatchQueue.main.async { [weak self] in
                    self?.messageInputBar.leftStackViewItems.forEach { item in
                        item.isEnabled = !isSendingPhoto
                    }
                }
            },
            
            // Notification to scroll to bottom
            coordinator.viewModel.scrollToBottom.subscribe() { [unowned self] event in
                self.messagesCollectionView.scrollToBottom(animated: event.element ?? false)
            },
            
            // Clear the input bar
            coordinator.viewModel.clearInputText.subscribe() { [unowned self] event in
                self.messageInputBar.inputTextView.text = ""
            }
        )
    }
    
    func setupUISubscribers() {
        bag.insert(
            cameraItem.rx.tap.asObservable().subscribe() { [unowned self] _ in
                self.cameraButtonPressed()
            }
        )
    }
}

private extension ChatViewController {
    // MARK: - Actions
    func cameraButtonPressed() {
        let picker = UIImagePickerController()
        picker.delegate = self
        coordinator.emit(ChatChatCameraButtonPressedEvent(picker: picker))
    }
    
    func insertNewMessage(_ message: Message) {
        // goes
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        // pass this thru rx
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        
        // stays
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        //--------------------------------------
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async { [weak self] in
                
                // call directly
                self?.coordinator.viewModel.scrollToBottom.onNext(true)
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType,
                    at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType,
                        at indexPath: IndexPath,
                        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType,
                           at indexPath: IndexPath,
                           with maxWidth: CGFloat,
                           in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return coordinator.viewModel.currentSender
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return NSAttributedString(
            string: message.sender.displayName,
            attributes: [
                .font: UIFont.preferredFont(forTextStyle: .caption1),
                .foregroundColor: UIColor(white: 0.3, alpha: 1)
            ]
        )
    }
}

// MARK: - MessageInputBarDelegate
extension ChatViewController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        coordinator.emit(ChatDidPressSendButtonWithTextEvent(text: text))
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        coordinator.emit(ChatImagePickerDidFinishPickingMediaEvent(picker: picker, info: info))
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        coordinator.emit(ChatImagePickerDidCancelEvent(picker: picker))
    }
}
