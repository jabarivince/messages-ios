//
//  ChatCoordinator.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import RxSwift
import Firebase
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
        observe(ChatChatCameraButtonPressedEvent.self) { event in
            print("Camera button tapped")
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
            viewModel.messages.onNext(message)
            return
        }
        
        imageService.download(from: url) { [weak self] image in
            guard let image = image else { return }
            message.image = image
            self?.viewModel.messages.onNext(message)
        }
    }
}

struct ChatViewModel: ViewModel {
    let title = PublishSubject<String>()
    let messages = PublishSubject<Message>()
    let isSendingPhoto = PublishSubject<Bool>()
    let scrollToBottom = PublishSubject<Bool>()
}
