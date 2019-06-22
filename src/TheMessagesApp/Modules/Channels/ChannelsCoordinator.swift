//
//  ChannelsCoordinator.swift
//  TheMessagesApp
//
//  Created by jabari on 6/17/19.
//

import RxCocoa
import Firebase

class ChannelsCoordinator: Coordinator<ChannelsViewModel> {
    private var channelListener: ListenerRegistration?
    
    deinit {
        channelListener?.remove()
    }
    
    required init(_ viewController: UIViewController) {
        super.init(viewController)
        addObservers()
    }
}

private extension ChannelsCoordinator {
    func addObservers() {
        channelListener = FirestoreService.onChanges(to: .channels) { [unowned self] change in
            self.respond(to: change)
        }
        
        observe(ChannelsViewDidLoadEvent.self) { [unowned self] _ in
            if !DefaultAuthenticationService.shared.userIsLoggedIn {
                let message = "You must be logged in to see your conversations"
                
                self.alert(Exception(message)) { [unowned self] in
                    self.dismiss()
                }
            } else {
                self.viewModel.title.accept("Conservations")
            }
        }
        
        observe(ChannelsAddButtonTappedEvent.self) { [unowned self] event in
            let title = "Create a new Channel"
            let placeholder = "Channel name"
            let confirmText = "Create"
            
            self.promptForText(title: title, placeholder: placeholder, confirmButtonText: confirmText) { [unowned self] text in
                FirestoreService.add(Channel(name: text), to: .channels) { error in
                    if let error = error {
                        self.alert(error)
                    }
                }
            }
        }
        
        observe(ChannelsLogoutButtonTappedEvent.self) { [unowned self] event in
            self.prompt("Are you sure you want to sign out?", continueButtonText: "Sign Out") { [unowned self] in
                DefaultAuthenticationService.shared.logout()
                self.dismiss()
            }
        }
        
        observe(ChannelsChannelTappedEvent.self) { [unowned self] event in
            let channel = self.viewModel.channel(at: event.index)
            print("TAPPED \(channel.name)")
        }
    }
}

private extension ChannelsCoordinator {
    func respond(to change: DocumentChange) {
        guard let channel = Channel(document: change.document) else { return }
        
        switch change.type {
        case .added:
            guard !viewModel.channels.contains(channel) else { break }
            viewModel.channels.append(channel)
            viewModel.channels.sort()
            
            guard let index = viewModel.channels.firstIndex(of: channel) else { break }
            viewModel.addRowIndex.accept(index)
            
        case .modified:
            guard let index = viewModel.channels.firstIndex(of: channel) else { break }
            viewModel.channels[index] = channel
            viewModel.updateRowIndex.accept(index)
            
        case .removed:
            guard let index = viewModel.channels.firstIndex(of: channel) else { break }
            viewModel.channels.remove(at: index)
            viewModel.removeRowIndex.accept(index)
        default:
            break
        }
    }
}

struct ChannelsViewModel: ViewModel {
    fileprivate var channels: [Channel] = []
    let title = PublishRelay<String>()
    let addRowIndex = PublishRelay<Int>()
    let updateRowIndex = PublishRelay<Int>()
    let removeRowIndex = PublishRelay<Int>()
    
    var channelCount: Int {
        return channels.count
    }
    
    func channel(at index: IndexPath) -> Channel {
        return channels[index.row]
    }
    
    func stateForChannel(at index: IndexPath) -> ChannelTableViewCellState {
        return ChannelTableViewCellState(from: channel(at: index))
    }
}

struct ChannelsViewDidLoadEvent: ActionEvent {}
struct ChannelsAddButtonTappedEvent: ActionEvent {}
struct ChannelsLogoutButtonTappedEvent: ActionEvent {}

struct ChannelsChannelTappedEvent: ActionEvent {
    let index: IndexPath
    
    init(at index: IndexPath) {
        self.index = index
    }
}
