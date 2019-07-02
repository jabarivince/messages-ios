//
//  ChatEvents.swift
//  TheMessagesApp
//
//  Created by jabari on 6/30/19.
//

import UIKit

struct ChatViewDidLoadEvent: ActionEvent {}

struct ChatChatCameraButtonPressedEvent: ActionEvent {
    let picker: UIImagePickerController
}

struct ChatImagePickerDidFinishPickingMediaEvent: ActionEvent {
    let picker: UIImagePickerController
    let info: [UIImagePickerController.InfoKey : Any]
}

struct ChatImagePickerDidCancelEvent: ActionEvent {
    let picker: UIImagePickerController
}

struct ChatDidPressSendButtonWithTextEvent: ActionEvent {
    let text: String
}
