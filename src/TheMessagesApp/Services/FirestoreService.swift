//
//  FirestoreService.swift
//  TheMessagesApp
//
//  Created by jabari on 6/20/19.
//

import Firebase

class FirestoreService {
    private static let db = Firestore.firestore()
    private static var collections: [Collection: CollectionReference] = [:]
    
    static func collection(_ name: Collection) -> CollectionReference {
        var collection = collections[name]
        
        if collection == nil {
            collection = db.collection(name.rawValue)
            collections[name] = collection
        }
        
        return collection!
    }
    
    static func add(_ representation: DatabaseRepresentation, to name: Collection, completion: ((Error?) -> Void)? = nil) {
        collection(name).addDocument(data: representation.representation, completion: completion)
    }
    
    static func onChanges(to name: Collection, _ completion: @escaping (DocumentChange) -> Void) -> ListenerRegistration {
        return collection(name).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for collection updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                completion(change)
            }
        }
    }
    
    enum Collection: String {
        case channels
    }
}
