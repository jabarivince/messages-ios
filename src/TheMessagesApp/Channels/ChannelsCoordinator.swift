//
//  ChannelsCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import RxSwift
import RxCocoa
import Firebase

class ChannelsCoordinator: Coordinator<ChannelsViewModel> {
    var authenticationService = DefaultAuthenticationService.shared
    
    private let db = Firestore.firestore()
    
    private var channelReference: CollectionReference {
        return db.collection("channels")
    }
    
    private var channelListener: ListenerRegistration?
    
    deinit {
        channelListener?.remove()
    }
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        
        channelListener = channelReference.addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for channel updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                self.handleDocumentChange(change)
            }
        }
        
        observe(ChannelsLogoutButtonTappedEvent.self) { [weak self] event in
            self?.authenticationService.logout()
            let loginController = UINavigationController(rootViewController: LoginViewController())
            self?.viewController.present(loginController, animated: true, completion: nil)
        }
        
        observe(ChannelsCreateEvent.self) { [weak self] event in
            let channel = Channel(name: event.name)
            
            self?.channelReference.addDocument(data: channel.representation) { error in
                if let error = error {
                    print("Error saving channel: \(error.localizedDescription)")
                }
            }
        }
        
        observe(ChannelsChannelTappedEvent.self) { event in
            print("TAPPED \(event.channel.name)")
//            let vc = ChatViewController(user: currentUser, channel: event.channel)
//            navigationController?.pushViewController(vc, animated: true)
        }
    }
}

private extension ChannelsCoordinator {
    func addChannelToTable(_ channel: Channel) {
        guard !viewModel.channels.contains(channel) else { return }
        viewModel.channels.append(channel)
        viewModel.channels.sort()
        
        guard let index = viewModel.channels.firstIndex(of: channel) else { return }
        viewModel.addRowIndex.accept(index)
    }
    
    func updateChannelInTable(_ channel: Channel) {
        guard let index = viewModel.channels.firstIndex(of: channel) else { return }
        viewModel.channels[index] = channel
        viewModel.updateRowIndex.accept(index)
    }
    
    func removeChannelFromTable(_ channel: Channel) {
        guard let index = viewModel.channels.firstIndex(of: channel) else { return }
        viewModel.channels.remove(at: index)
        viewModel.removeRowIndex.accept(index)
    }
    
    func handleDocumentChange(_ change: DocumentChange) {
        guard let channel = Channel(document: change.document) else { return }
        
        switch change.type {
        case .added:
            addChannelToTable(channel)
            
        case .modified:
            updateChannelInTable(channel)
            
        case .removed:
            removeChannelFromTable(channel)
        default:
            break
        }
    }
}

struct ChannelsViewModel: ViewModel {
    var channels: [Channel] = []
    var addRowIndex = PublishRelay<Int>()
    var updateRowIndex = PublishRelay<Int>()
    var removeRowIndex = PublishRelay<Int>()
}

struct ChannelsViewDidLoadEvent: ActionEvent {}
struct ChannelsLogoutButtonTappedEvent: ActionEvent {}

struct ChannelsCollectionChanedEvent: ActionEvent {
    
}

struct ChannelsChannelTappedEvent: ActionEvent, Hashable {
    let channel: Channel
}

struct ChannelsCreateEvent: ActionEvent {
    let name: String
}
