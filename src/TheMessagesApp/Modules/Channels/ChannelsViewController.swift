import UIKit
import RxSwift

class ChannelsViewController: UITableViewController {
    private let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: nil)
    private let signoutButton = UIBarButtonItem(title: "Sign Out", style: .plain, target: self, action: nil)
    private lazy var coordinator = ChannelsCoordinator(self)
    private let bag = DisposeBag()
    
    init() {
        super.init(style: .plain)
        subscribeToView()
        subscribeToCoordinator()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(ChannelTableViewCell.self, forCellReuseIdentifier: ChannelTableViewCell.id)
        navigationItem.leftBarButtonItem = signoutButton
        navigationItem.rightBarButtonItem = addButton
        coordinator.emit(ChannelsViewDidLoadEvent())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
}

extension ChannelsViewController {
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return coordinator.viewModel.channelCount
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ChannelTableViewCell.id) as! ChannelTableViewCell
        cell.state = coordinator.viewModel.stateForChannel(at: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        coordinator.emit(ChannelsChannelTappedEvent(at: indexPath))
    }
}

private extension ChannelsViewController {
    func subscribeToView() {
        bag.insert(
            signoutButton.rx.tap.subscribe() { [unowned self] _ in
                self.coordinator.emit(ChannelsLogoutButtonTappedEvent())
            },
            
            addButton.rx.tap.subscribe() { [unowned self] _ in
                self.coordinator.emit(ChannelsAddButtonTappedEvent())
            }
        )
    }
    
    func subscribeToCoordinator() {
        bag.insert(
            coordinator.viewModel.title.asObservable().subscribe() { [unowned self] event in
                self.title = event.element
            },
            
            coordinator.viewModel.addRowIndex.asObservable().subscribe() { [unowned self] event in
                guard let index = event.element else { return }
                self.tableView.insertRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            },
            
            coordinator.viewModel.updateRowIndex.asObservable().subscribe() { [unowned self] event in
                guard let index = event.element else { return }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            },
            
            coordinator.viewModel.removeRowIndex.asObservable().subscribe() { [unowned self] event in
                guard let index = event.element else { return }
                self.tableView.beginUpdates()
                self.tableView.deleteRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
                self.tableView.endUpdates()
            }
        )
    }
}
