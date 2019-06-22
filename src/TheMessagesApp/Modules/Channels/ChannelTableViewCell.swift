//
//  ChannelTableViewCells.swift
//  TheMessagesApp
//
//  Created by jabari on 6/22/19.
//

import UIKit

class ChannelTableViewCell: UITableViewCell {
    static let id = "channelCell"
    
    var state: ChannelTableViewCellState? {
        didSet {
            guard let state = state else { return }
            textLabel?.text = state.text
            detailTextLabel?.text = state.detailText
            detailTextLabel?.accessibilityLabel = state.accessibilityText
        }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        detailTextLabel?.numberOfLines = 0
        detailTextLabel?.textColor = .gray
        accessoryType = .disclosureIndicator
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

struct ChannelTableViewCellState {
    let text: String
    let detailText: String
    let accessibilityText: String
    
    init(from channel: Channel) {
        text = channel.name
        detailText = ""
        accessibilityText = "Channel: \(channel)"
    }
}
