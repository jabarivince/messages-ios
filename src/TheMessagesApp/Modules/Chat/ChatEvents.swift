//
//  ChatEvents.swift
//  TheMessagesApp
//
//  Created by jabari on 6/30/19.
//

import UIKit

struct ChatViewDidLoadEvent: ActionEvent {}

struct ChatChatCameraButtonPressedEvent: ActionEvent {}

struct ChatSendImageEvent: ActionEvent {
    let image: UIImage
}

struct ChatSaveMessageEvent: ActionEvent {
    let message: Message
    
    init(user: LocalUser, content: String) {
        self.message = Message(user: user, content: content)
    }
    
    init(message: Message) {
        self.message = message
    }
}
