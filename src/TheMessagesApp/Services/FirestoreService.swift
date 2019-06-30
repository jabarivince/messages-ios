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
    
    static func reference(for name: Collection) -> CollectionReference {
        var collection = collections[name]
        
        if collection == nil {
            collection = db.collection(name.name)
            collections[name] = collection
        }
        
        return collection!
    }
    
    static func add(_ representation: DatabaseRepresentation, to name: Collection, completion: ((Error?) -> Void)? = nil) {
        reference(for: name).addDocument(data: representation.representation, completion: completion)
    }
    
    static func onChanges(to name: Collection, _ completion: @escaping (DocumentChange) -> Void) -> ListenerRegistration {
        return reference(for: name).addSnapshotListener { querySnapshot, error in
            guard let snapshot = querySnapshot else {
                print("Error listening for collection updates: \(error?.localizedDescription ?? "No error")")
                return
            }
            
            snapshot.documentChanges.forEach { change in
                completion(change)
            }
        }
    }
    
    struct Collection: Hashable, Equatable {
        let name: String
        
        init(name: String) {
            self.name = name
        }
        
        init(_ names: String...) {
            self.name = names.joined(separator: "/")
        }
        
        static let channels = Collection(name: "channels")
    }
}
