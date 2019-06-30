//
//  ImageService.swift
//  TheMessagesApp
//
//  Created by jabari on 6/30/19.
//

import UIKit
import Firebase

protocol ImageService {
    func upload(image: UIImage, channel: Channel, completion: @escaping (URL?) -> Void)
    func download(from url: URL, completion: @escaping (UIImage?) -> Void)
}

class DefaultImageService: ImageService {
    static let shared = DefaultImageService()
    private let storage = Storage.storage().reference()
    
    private init() {}
    
    func upload(image: UIImage, channel: Channel, completion: @escaping (URL?) -> Void) {
        guard let channelID = channel.id else {
            completion(nil)
            return
        }
        
        guard let scaledImage = image.scaledToSafeUploadSize else { return }
        guard let data = scaledImage.jpegData(compressionQuality: 0.4) else {
            completion(nil)
            return
        }
        
        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"
        
        let imageName = [UUID().uuidString, String(Date().timeIntervalSince1970)].joined()
        
        storage.child(channelID).child(imageName).putData(data, metadata: metadata) { meta, error in
            completion(meta?.downloadURL())
        }
    }
    
    func download(from url: URL, completion: @escaping (UIImage?) -> Void) {
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
}
