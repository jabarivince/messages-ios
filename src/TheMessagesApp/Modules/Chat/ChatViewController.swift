//
//  ChatViewController.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import UIKit
import RxSwift
import MessageKit
import Photos

final class ChatViewController: MessagesViewController {
    private let bag = DisposeBag()
    private var coordinator: ChatCoordinator!
    private var cameraItem: InputBarButtonItem!
    
    // Will be moved to Coordinator
    private let user: LocalUser
    private var messages: [Message] = []
    
    init(user: LocalUser, channel: Channel) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        self.coordinator = ChatCoordinator(self, user: user, channel: channel)
        
        bag.insert(
            // New message
            coordinator.viewModel.messages.subscribe() { [weak self] event in
                guard let message = event.element else { return }
                self?.insertNewMessage(message)
            },
            
            // Title changes
            coordinator.viewModel.title.subscribe() { [unowned self] event in
                self.title = event.element
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
            }
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        coordinator.emit(ChatViewDidLoadEvent())
        
        navigationItem.largeTitleDisplayMode = .never
        maintainPositionOnKeyboardFrameChanged = true
        
        setupCollectionView()
        setupCameraButton()
        setupInputBar()
        setupUISubscribers()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

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
        coordinator.emit(ChatChatCameraButtonPressedEvent())
        
        let picker = UIImagePickerController()
        picker.delegate = self
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            picker.sourceType = .camera
        } else {
            picker.sourceType = .photoLibrary
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func insertNewMessage(_ message: Message) {
        guard !messages.contains(message) else { return }
        
        messages.append(message)
        messages.sort()
        
        let isLatestMessage = messages.firstIndex(of: message) == (messages.count - 1)
        let shouldScrollToBottom = messagesCollectionView.isAtBottom && isLatestMessage
        
        messagesCollectionView.reloadData()
        
        if shouldScrollToBottom {
            DispatchQueue.main.async { [weak self] in
                self?.coordinator.viewModel.scrollToBottom.onNext(true)
            }
        }
    }
}

// MARK: - MessagesLayoutDelegate
extension ChatViewController: MessagesLayoutDelegate {
    func avatarSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return .zero
    }
    
    func footerViewSize(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 0, height: 8)
    }
    
    func heightForLocation(message: MessageType, at indexPath: IndexPath, with maxWidth: CGFloat, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
}

// MARK: - MessagesDisplayDelegate
extension ChatViewController: MessagesDisplayDelegate {
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .primary : .incomingMessage
    }
    
    func shouldDisplayHeader(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> Bool {
        return false
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        
        return .bubbleTail(corner, .curved)
    }
}

// MARK: - MessagesDataSource
extension ChatViewController: MessagesDataSource {
    func currentSender() -> Sender {
        return Sender(id: user.uid!, displayName: AppSettings.displayName)
    }
    
    func numberOfMessages(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(
            string: name,
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
        let message = Message(user: user, content: text)
        
        coordinator.emit(ChatSaveMessageEvent(message: message))
        inputBar.inputTextView.text = ""
    }
}

// MARK: - UIImagePickerControllerDelegate
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: nil) { result, info in
                    
                    guard let image = result else { return }
                    
                    self.coordinator.emit(ChatSendImageEvent(image: image))
            }
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            coordinator.emit(ChatSendImageEvent(image: image))
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}
