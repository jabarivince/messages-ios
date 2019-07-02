//
//  ChatCoordinator.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import RxSwift
import Firebase
import MessageKit
import Photos
import UIKit

class ChatCoordinator: Coordinator<ChatViewModel> {
    private var imageService: ImageService!
    private var messageListener: ListenerRegistration!
    private var collection: FirestoreService.Collection!
    
    convenience init(_ viewController: UIViewController, user: LocalUser, channel: Channel) {
        self.init(viewController)
        self.viewModel.user    = user
        self.viewModel.channel = channel
        self.collection        = FirestoreService.Collection("channels", channel.id!, "thread")
        self.imageService      = DefaultImageService.shared
        addObservers()
    }
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
    }
    
    deinit {
        messageListener.remove()
    }
}

private extension ChatCoordinator {
    func addObservers() {
        // View loaded
        observe(ChatViewDidLoadEvent.self) { [unowned self] event in
            self.messageListener = FirestoreService.onChanges(to: self.collection) { [weak self] change in
                self?.respond(to: change)
            }
        }
        
        // Camera button tapped
        observe(ChatChatCameraButtonPressedEvent.self) { [unowned self] event in
            event.picker.sourceType = UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary
            self.viewController?.present(event.picker, animated: true, completion: nil)
        }
        
        // Image picked
        observe(ChatImagePickerDidFinishPickingMediaEvent.self) { [unowned self] event in
            self.imagePickerController(event.picker, didFinishPickingMediaWithInfo: event.info)
        }
        
        // Image picker cancelled
        observe(ChatImagePickerDidCancelEvent.self) { event in
             event.picker.dismiss(animated: true, completion: nil)
        }
        
        //  Send button tapped with text to send
        observe(ChatDidPressSendButtonWithTextEvent.self) { [unowned self] event in
            let message = Message(user: self.viewModel.user, content: event.text)
            self.save(message)
            self.viewModel.clearInputText.onNext(())
        }
    }
}

private extension ChatCoordinator {
    func send(_ image: UIImage) {
        self.viewModel.isSendingPhoto.onNext(true)
        
        self.imageService.upload(image: image, channel: self.viewModel.channel) { [weak self] url in
            guard let self = self else { return }
            
            self.viewModel.isSendingPhoto.onNext(false)
            
            guard let url = url else { return }
            
            var message = Message(user: self.viewModel.user, image: image)
            message.downloadURL = url
            
            self.save(message)
        }
    }
    
    func save(_ message: Message) {
        FirestoreService.add(message, to: collection) { [weak self] error in
            self?.viewModel.scrollToBottom.onNext(false)
        }
    }
    
    func respond(to change: DocumentChange) {
        guard
            change.type == .added,
            var message = Message(document: change.document)
        else { return }
        
        guard let url = message.downloadURL else {
            viewModel.newMessage.onNext(message)
            return
        }
        
        imageService.download(from: url) { [weak self] image in
            guard let image = image else { return }
            message.image = image
            self?.viewModel.newMessage.onNext(message)
        }
    }
}

// UIImagePicker
private extension ChatCoordinator {
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        
        if let asset = info[UIImagePickerController.InfoKey.phAsset] as? PHAsset {
            let size = CGSize(width: 500, height: 500)
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: size,
                contentMode: .aspectFit,
                options: nil) { result, info in
                    
                    guard let image = result else { return }
                    self.send(image)
            }
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            send(image)
        }
    }
}


struct ChatViewModel: ViewModel {
    fileprivate var user: LocalUser!
    fileprivate var channel: Channel!
    
    // TODO - Eventually will be fileprivate
    var messages = [Message]()
    
    var title: String {
        return channel.name
    }
    
    var currentSender: Sender {
        return Sender(id: user.uid!, displayName: AppSettings.displayName)
    }
    
    let isSendingPhoto = PublishSubject<Bool>()
    let scrollToBottom = PublishSubject<Bool>()
    let clearInputText = PublishSubject<Void>()
    let newMessage     = PublishSubject<Message>()
}
