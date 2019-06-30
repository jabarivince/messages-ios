//
//  Message.swift
//  TheMessagesApp
//
//  Created by Vince G on 6/26/19.
//

import Firebase
import MessageKit
import FirebaseFirestore

struct Message: MessageType {
    
    let id: String?
    let content: String
    let sentDate: Date
    let sender: Sender
    
    var data: MessageData {
        if let image = image {
            return .photo(image)
        } else {
            return .text(content)
        }
    }
    
    var messageId: String {
        return id ?? UUID().uuidString
    }
    
    var image: UIImage? = nil
    var downloadURL: URL? = nil
    
    init(user: LocalUser, content: String) {
        sender = Sender(id: user.user.uid, displayName: AppSettings.displayName)
        self.content = content
        sentDate = Date()
        id = nil
    }
    
    init(user: LocalUser, image: UIImage) {
       // let id = user.user.uid
       // let display = AppSettings.displayName
        
        sender = Sender(id: user.user.uid, displayName: "Splash")
        self.image = image
        content = ""
        sentDate = Date()
        id = nil
    }
    
    init?(document: QueryDocumentSnapshot) {
        let data = document.data()
        
        guard let sentDate = data["created"] as? Date else {
            return nil
        }
        guard let senderID = data["senderID"] as? String else {
            return nil
        }
        guard let senderName = data["senderName"] as? String else {
            return nil
        }
        
        id = document.documentID
        
        self.sentDate = sentDate
        sender = Sender(id: senderID, displayName: senderName)
        
        if let content = data["content"] as? String {
            self.content = content
            downloadURL = nil
        } else if let urlString = data["url"] as? String, let url = URL(string: urlString) {
            downloadURL = url
            content = ""
        } else {
            return nil
        }
    }
    
}

extension Message: DatabaseRepresentation {
    
    var representation: [String : Any] {
        var rep: [String : Any] = [
            "created": sentDate,
            "senderID": sender.id,
            "senderName": sender.displayName
        ]
        
        if let url = downloadURL {
            rep["url"] = url.absoluteString
        } else {
            rep["content"] = content
        }
        
        return rep
    }
    
}

extension Message: Comparable {
    
    static func == (lhs: Message, rhs: Message) -> Bool {
        return lhs.id == rhs.id
    }
    
    static func < (lhs: Message, rhs: Message) -> Bool {
        return lhs.sentDate < rhs.sentDate
    }
    
}
