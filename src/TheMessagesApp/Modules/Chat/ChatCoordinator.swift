//
//  ChatCoordinator.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import RxSwift
import RxCocoa
import Firebase
import Photos
import UIKit

class ChatCoordinator: Coordinator<ChatViewModel> {
    private var messageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    private let storage = Storage.storage().reference()
    private var channel: Channel!
    private var user: LocalUser!
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        addObservers()
    }
    
    deinit {
        messageListener?.remove()
    }
}

private extension ChatCoordinator{
    
    func addObservers() {
        observe(ChatViewDidLoadEvent.self) { [weak self] event in
            self?.viewModel.title.onNext(event.channel.name)
            self?.channel = event.channel
            self?.user = event.user
        }
        
        observe(ChatViewDidLoadEvent.self) { [weak self] event in
            guard let id = event.channel.id else { return }
            
            self?.reference = self?.db.collection(["channels", id, "thread"].joined(separator: "/"))
            self?.messageListener = self?.reference?.addSnapshotListener { querySnapshot, error in
                guard let snapshot = querySnapshot else {
                    print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                    return
                }
                
                snapshot.documentChanges.forEach { change in
                    self?.respond(to: change)
                }
            }
        }
        
        observe(ChatChatCameraButtonPressedEvent.self) { [weak self] event in
            print("Camera button tapped")
        }
        
        observe(ChatUploadImageEvent.self) { [weak self] event in
            let image = event.image
            let channel = event.channel
            let completion = event.completion
            
            guard let channelID = channel.id else {
                completion(nil)
                return
            }
            
            guard let scaledImage = image.scaledToSafeUploadSize else {return}
            guard let data = scaledImage.jpegData(compressionQuality: 0.4) else {
                completion(nil)
                return
            }
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
            self?.storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
                completion(meta?.downloadURL())
            }
        }
        
        observe(ChatSendImageEvent.self) { [weak self] event in
            
            guard let channel = self?.channel else { return }
            self?.viewModel.isSendingPhoto.onNext(true)
            
            let event = ChatUploadImageEvent(image: event.image, channel: channel) { [weak self] url in
                guard let self = self else { return }
                
                self.viewModel.isSendingPhoto.onNext(false)
                
                guard let url = url else { return }
                
                var message = Message(user: self.user, image: event.image)
                message.downloadURL = url
                
                self.emit(ChatSaveMessageEvent(message: message))
                self.viewModel.scrollToBottom.onNext(false)
            }
            
            self?.emit(event)
        }
        
        observe(ChatSaveMessageEvent.self) { [weak self] event in
            self?.reference?.addDocument(data: event.message.representation) { [weak self] error in
                if let e = error {
                    print("Error sending message: \(e.localizedDescription)")
                    return
                }
                
                self?.viewModel.scrollToBottom.onNext(false)
            }
        }
    }
    
    func respond(to change: DocumentChange) {
        guard var message = Message(document: change.document) else {
            return
        }
        
        switch change.type {
        case .added:
            if let url = message.downloadURL {
                downloadImage(at: url) { [weak self] image in
                    guard let self = self else {
                        return
                    }
                    guard let image = image else {
                        return
                    }
                    
                    message.image = image
                    self.insertNewMessage(message)
                }
            } else {
                insertNewMessage(message)
            }
        default:
            break
        }
    }
    
    func downloadImage(at url: URL, completion: @escaping (UIImage?) -> Void) {
        let ref = Storage.storage().reference(forURL: url.absoluteString)
        let megaByte = Int64(1 * 1024 * 1024)
        
        ref.getData(maxSize: megaByte) { data, error in
            guard let imageData = data else {
                completion(nil)
                return
            }
            
            completion(UIImage(data: imageData))
        }
    }
    
    func insertNewMessage(_ message: Message) {
        viewModel.messages.onNext(message)
    }
}

struct ChatViewModel: ViewModel {
    let messages = PublishSubject<Message>()
    let title = PublishSubject<String>()
    let isSendingPhoto = PublishSubject<Bool>()
    let scrollToBottom = PublishSubject<Bool>()
}

struct ChatViewDidLoadEvent: ActionEvent {
    let channel: Channel
    let user: LocalUser
}

struct ChatChatCameraButtonPressedEvent: ActionEvent {}

struct ChatUploadImageEvent: ActionEvent {
    static func == (lhs: ChatUploadImageEvent, rhs: ChatUploadImageEvent) -> Bool {
        return lhs.image == rhs.image && lhs.channel == rhs.channel
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(image)
        hasher.combine(channel)
    }
    
    let image: UIImage
    let channel: Channel
    let completion: (URL?) -> Void
}

struct ChatSendImageEvent: ActionEvent {
    let image: UIImage
}

struct ChatSaveMessageEvent: ActionEvent {
    static func == (lhs: ChatSaveMessageEvent, rhs: ChatSaveMessageEvent) -> Bool {
        return lhs.message.content == rhs.message.content
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(message.content)
    }
    
    let message: Message
    
    init(user: LocalUser, content: String) {
        self.message = Message(user: user, content: content)
    }
    
    init(message: Message) {
       self.message = message
    }
}
