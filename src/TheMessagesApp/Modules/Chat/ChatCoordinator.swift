//
//  ChatCoordinator.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import RxSwift
import RxCocoa
import Firebase

class ChatCoordinator: Coordinator<ChatViewModel> {
    private var messageListener: ListenerRegistration?
    private let db = Firestore.firestore()
    private var reference: CollectionReference?
    
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
}

struct ChatViewDidLoadEvent: ActionEvent {
    let channel: Channel
}

struct ChatChatCameraButtonPressedEvent: ActionEvent {}

