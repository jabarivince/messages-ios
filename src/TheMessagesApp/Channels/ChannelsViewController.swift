import UIKit
import RxSwift
import FirebaseAuth

class ChannelsViewController: UITableViewController {
    var coordinator: ChannelsCoordinator!
    let bag = DisposeBag()
    
    private let channelCellIdentifier = "channelCell"
    private var currentChannelAlertController: UIAlertController?
    
    init(currentUser: User) {
        super.init(style: .grouped)
        coordinator = ChannelsCoordinator(self)
        addSubscibers()
        title = "Conversations"
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        clearsSelectionOnViewWillAppear = true
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: channelCellIdentifier)
        
        toolbarItems = [
            UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: #selector(signOut)),
            UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil),
            UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonPressed)),
        ]
        
        coordinator.emit(ChannelsViewDidLoadEvent())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isToolbarHidden = false
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.isToolbarHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func signOut() {
        promptToContinue("Are you sure you want to sign out?", continueButtonText: "Sign Out") { [unowned self] in
            self.coordinator.emit(ChannelsLogoutButtonTappedEvent())
        }
    }
    
    @objc private func addButtonPressed() {
        promptForText(title: "Create a new Channel",
                      placeholder: "Channel name",
                      confirmButtonText: "Create") { [weak self] text in
                        
            guard let text = text else { return }
            self?.coordinator.emit(ChannelsCreateEvent(name: text))
        }
    }
}

// MARK: - TableViewDelegate

extension ChannelsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coordinator.viewModel.channels.count
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: channelCellIdentifier, for: indexPath)
        cell.accessoryType = .disclosureIndicator
        cell.textLabel?.text = coordinator.viewModel.channels[indexPath.row].name
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let channel = coordinator.viewModel.channels[indexPath.row]
        coordinator.emit(ChannelsChannelTappedEvent(channel: channel))
    }
}

private extension ChannelsViewController {
    @objc func logout() {
        coordinator.emit(ChannelsLogoutButtonTappedEvent())
    }
    
    func addSubscibers() {
        coordinator.viewModel.addRowIndex
        .asObservable()
        .subscribe() { [weak self] event in
            guard let index = event.element else { return }
            self?.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        .disposed(by: bag)
        
        coordinator.viewModel.updateRowIndex
        .asObservable()
        .subscribe() { [weak self] event in
            guard let index = event.element else { return }
            self?.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
        }
        .disposed(by: bag)
        
        coordinator.viewModel.removeRowIndex
        .asObservable()
        .subscribe() { [weak self] event in
            guard let index = event.element else { return }
            self?.tableView.beginUpdates()
            self?.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            self?.tableView.endUpdates()
        }
        .disposed(by: bag)
    }
}
