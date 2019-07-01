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
    private var channel: Channel!
    private var user: LocalUser!
    
    convenience init(_ viewController: UIViewController, user: LocalUser, channel: Channel) {
        self.init(viewController)
        self.user         = user
        self.channel      = channel
        self.collection   = FirestoreService.Collection("channels", channel.id!, "thread")
        self.imageService = DefaultImageService.shared
        self.viewModel.user = user
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
            self.viewModel.title.onNext(self.channel.name)
            
            self.messageListener = FirestoreService.onChanges(to: self.collection) { [weak self] change in
                self?.respond(to: change)
            }
        }
        
        // Camera button tapped
        observe(ChatChatCameraButtonPressedEvent.self) { [unowned self] event in
            let picker = event.picker
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                picker.sourceType = .camera
            } else {
                picker.sourceType = .photoLibrary
            }
            
            self.viewController?.present(picker, animated: true, completion: nil)
        }
        
        // Send image
        observe(ChatSendImageEvent.self) { [unowned self] event in
            self.viewModel.isSendingPhoto.onNext(true)
            
            self.imageService.upload(image: event.image, channel: self.channel) { [weak self] url in
                guard let self = self else { return }
                
                self.viewModel.isSendingPhoto.onNext(false)
                
                guard let url = url else { return }
                
                var message = Message(user: self.user, image: event.image)
                message.downloadURL = url
                
                self.save(message)
            }
        }
        
        // Save message
        observe(ChatSaveMessageEvent.self) { [unowned self] event in
            self.save(event.message)
        }
        
        observe(ChatImagePickerDidFinishPickingMediaEvent.self) { [unowned self] event in
            self.imagePickerController(event.picker, didFinishPickingMediaWithInfo: event.info)
        }
        
        observe(ChatImagePickerDidCancelEvent.self) { event in
             event.picker.dismiss(animated: true, completion: nil)
        }
        
        observe(ChatDidPressSendButtonWithTextEvent.self) { [unowned self] event in
            let message = Message(user: self.user, content: event.text)
            self.save(message)
            self.viewModel.clearInputText.onNext(())
        }
    }
}

private extension ChatCoordinator {
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

private extension ChatCoordinator {
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
                    
                    self.emit(ChatSendImageEvent(image: image))
                    // send()
            }
        } else if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            emit(ChatSendImageEvent(image: image))
            // send()
        }
    }
}


struct ChatViewModel: ViewModel {
    let title = PublishSubject<String>()
    let newMessage = PublishSubject<Message>()
    let isSendingPhoto = PublishSubject<Bool>()
    let scrollToBottom = PublishSubject<Bool>()
    let clearInputText = PublishSubject<Void>()
    
    fileprivate var user: LocalUser!
    
    var messages = [Message]()
    
    var currentSender: Sender {
        return Sender(id: user.uid!, displayName: AppSettings.displayName)
    }
}
