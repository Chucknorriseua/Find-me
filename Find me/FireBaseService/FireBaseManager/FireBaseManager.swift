//
//  FireBaseManager.swift
//  Find me
//
//  Created by Евгений Полтавец on 14/12/2024.
//

import Foundation
import CoreLocation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class FireBaseManager {
    
    static var sherad = FireBaseManager()
    
    private(set) weak var listener: ListenerRegistration?
    
    let auth = Auth.auth()
    
    private init() {}
    
    private let db = Firestore.firestore()
    
    private let storage = Storage.storage()
    
    private var findMeUser: CollectionReference {
        return db.collection("FindMeUser")
    }
    
    private var requestUser: CollectionReference {
        return db.collection("RequestUser")
    }
    private var voiceRecords: CollectionReference {
        return db.collection("VoiceRecords")
    }
    
    func setDataFindMeUser(user: FindMeUser) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await findMeUser.document(uid).setData(user.personModel, merge: true)
    }

    func uploadDataRecordsForUser(records: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let userDocument = findMeUser.document(uid)
        let snapShot = try await userDocument.getDocument()
        var arrayRecords = snapShot.data()?["records"] as? [String] ?? []
        arrayRecords.append(records)
        try await userDocument.updateData(["records": arrayRecords])
    }
    
    func uploadDataRecordsForMyFriends(id: String, records: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        let userDocument = findMeUser.document(id).collection("MyFriends").document(uid)
        let snapShot = try await userDocument.getDocument()
        var arrayRecords = snapShot.data()?["records"] as? [String] ?? []
        arrayRecords.append(records)
        try await userDocument.updateData(["records": arrayRecords])
    }
    
    func updateMyDataAllMyFriend(id: String, user: FindMeUser) async throws {
        guard let uid = auth.currentUser?.uid else { return }
        try await findMeUser.document(id).collection("MyFriends").document(uid).setData(user.personModel, merge: true)
    }
    
    func fetchCurrentUserData() async throws -> FindMeUser {
        guard let uid = auth.currentUser?.uid else { throw NSError(domain: "Not found id", code: 0, userInfo: nil)}
        let snapShot = try await findMeUser.document(uid).getDocument(as: FindMeUser.self)
        return snapShot
    }
    
    
    // MARK: FETCH_All_Registers
    func fethAll_Registers_FindMe_Users(id: String) async throws -> [FindMeUser] {
        let query = findMeUser.whereField("id", isNotEqualTo: id)
        
        let snapShot = try await query.getDocuments()
        let findMeUsers: [FindMeUser] = try snapShot.documents.compactMap {[weak self] document in
            return try self?.convertDocumentToFindMeUser(document)
        }
        return findMeUsers
    }
    
    
    // MARK: FETCH_Request
    func fethRequestAllUsers(id: String) async throws -> ([FindMeUser], Int) {
        guard let uid = auth.currentUser?.uid else {throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        let query = findMeUser.document(uid).collection("Request").whereField("id", isNotEqualTo: id)
        
        let snapShot = try await query.getDocuments()
        let requestCount = snapShot.documents.count
     
        let findMeUsers: [FindMeUser] = try snapShot.documents.compactMap { document in
            return try self.convertDocumentToFindMeUser(document)
        }
        return (findMeUsers, requestCount)
    }
    
    // MARK: FETCH_All_MyFriends
    func fetchAllMyFriends() async throws -> [FindMeUser] {
        guard let uid = auth.currentUser?.uid else {throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        let query = findMeUser.document(uid).collection("MyFriends")
        let snapShot = try await query.getDocuments()
        let findMeUsers: [FindMeUser] = try snapShot.documents.compactMap {[weak self] document in
            return try self?.convertDocumentToFindMeUser(document)
        }
        return findMeUsers
    }
    
    func fetchFriendLocation(friendId: String) async throws -> CLLocationCoordinate2D? {
        let snapshot = try await findMeUser.document(friendId).getDocument()
        guard let data = snapshot.data(),
              let latitude = data["latitude"] as? Double,
              let longitude = data["longitude"] as? Double else {
            return nil
        }
        print("USER LOCATION: fetchFriendLocation ", data)
        return CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    
    // MARK: Send_Request
    func sendRequestFriendsMyRoom(id: String, friend: FindMeUser) async throws {
        guard let uid = auth.currentUser?.uid else {throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        let check = await isCheckUserForRequest(id: id, collection: "MyFriends")
        if check {
         return
        }
        try await findMeUser.document(id).collection("Request").document(uid).setData(friend.personModel)
    }
    
    
    // MARK: Accept_Request
    func Accept_RequestFriendsMyRoom(id: String, friend: FindMeUser) async throws {
        guard let uid = auth.currentUser?.uid else {throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        try await findMeUser.document(uid).collection("MyFriends").document(friend.id).setData(friend.personModel)
        try await Remove_RequestFriendsMyRoom(id: id, friend: friend, collection: "Request")
    }
    
    
    // MARK: Remove_Request
    func Remove_RequestFriendsMyRoom(id: String, friend: FindMeUser, collection: String) async throws {
        guard let uid = auth.currentUser?.uid else {throw NSError(domain: "Not found id", code: 0, userInfo: nil) }
        try await findMeUser.document(uid).collection(collection).document(friend.id).delete()
    }
    
    
    //    MARK: REMOVE
    func removeMyRecords(id: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }

        let userDocRef = findMeUser.document(uid)
        let userDoc = try await userDocRef.getDocument()

        if let data = userDoc.data() {
            if var records = data["records"] as? [String] {
                if let index = records.firstIndex(of: id) {
                    let fileURL = records[index]

                    records.remove(at: index)
                    try await userDocRef.updateData(["records": records])

                    let storageRef = storage.reference(forURL: fileURL)
                    
                    try await storageRef.delete()
                }
            }
        }
    }
    
    func removeMyUrlRecordsForFriends(friendId: String, recordToRemove: String) async throws {
        guard let uid = auth.currentUser?.uid else { return }

        let userDocument = findMeUser.document(friendId).collection("MyFriends").document(uid)
        let userDoc = try await userDocument.getDocument()

        if let data = userDoc.data(),
           var records = data["records"] as? [String],
           let index = records.firstIndex(of: recordToRemove) {
 
//            let recordURL = records[index]
            records.remove(at: index)
            try await userDocument.updateData(["records": records])
            
            print("Record successfully removed.")
        } else {
            print("Record not found or document does not exist.")
        }
    }
    
    func isCheckUserForRequest(id: String, collection: String) async -> Bool {
        guard let uid = auth.currentUser?.uid else {return false}
        let ref = findMeUser.document(id).collection(collection).document(uid)
        do {
            let document = try await ref.getDocument()
            return document.exists
        } catch {
            print("DEBUG: Error isMasterAllReadyInRoom", error.localizedDescription)
            return false
        }
    }
    
//MARK: UPDATE
    func updateLocationUser(user: FindMeUser) async {
        guard let uid = auth.currentUser?.uid else { return }
        guard let latitude = user.latitude, let longitudes = user.longitude else { return }
        let isOn = user.isOn
        do {
            let user = findMeUser.document(uid)
            try await user.updateData(["latitude": latitude, "longitude": longitudes, "isOn": isOn])
        } catch {
            print("DEBUG: Error updateLocationUser", error.localizedDescription)
        }
    }
    
    
    func updateLocationForMyFriend(id: String, user: FindMeUser) async {
        guard let uid = auth.currentUser?.uid else { return }
        guard let latitude = user.latitude, let longitudes = user.longitude else { return }
        let isOn = user.isOn
        do {
            let user = findMeUser.document(id).collection("MyFriends").document(uid)
            try await user.updateData(["latitude": latitude, "longitude": longitudes, "isOn": isOn])
        } catch {
            print("DEBUG: Error updateLocationForMyFriend", error.localizedDescription)
        }
    }
    
    //MARK: STORAGE Send records
    func sendVoiceRecords(id: String, records: Data) async throws -> URL? {
        guard let uid = auth.currentUser?.uid else { return nil }
        do {
            let fileName = UUID().uuidString + ".m4a"
            let store = storage.reference().child("Records/\(uid)/\(fileName)")
            
            let metadata = StorageMetadata()
            metadata.contentType = "audio/m4a"
            print("metadata", metadata)
            _ = try await store.putDataAsync(records, metadata: metadata)
            let dowload = try await store.downloadURL()
            print("DOWNLOAD", dowload)
            try await uploadDataRecordsForUser(records: dowload.absoluteString)
            try await uploadDataRecordsForMyFriends(id: id, records: dowload.absoluteString)
            return dowload
        } catch {
            print("DEBUG: Error sendVoiceRecords...", error.localizedDescription)
            return nil
        }
    }
    
//    func chechStatusLocationMyFriends(id: String) async throws -> Bool {
//        guard let uid = auth.currentUser?.uid else { return false}
//        let snapshot = try await findMeUser.document(uid).collection("MyFriends").document(id).getDocument()
//        guard let data = snapshot.data(),
//              let isOn = data["isOn"] as? Bool else {
//            return false
//        }
//        print("isON", isOn)
//        return isOn
//    }
    
}

extension FireBaseManager {
    func convertDocumentToFindMeUser(_ document: DocumentSnapshot) throws -> FindMeUser {
        let data = document.data()
        guard let id = data?["id"] as? String,
              let email = data?["email"] as? String,
              let name =  data?["name"] as? String,
              let phone = data?["phone"] as? String,
              let friendPhone = data?["friendPhone"] as? String,
              let records = data?["records"] as? [String],
              let isOn = data?["isOn"] as? Bool,
              let date = data?["date"] as? Timestamp,
              let latitude = data?["latitude"] as? Double,
              let longitude = data?["longitude"] as? Double else { throw NSError(domain: "Not correct create data", code: 0, userInfo: nil)  }
        
        let createTampDate = date.dateValue()
        
        
        return FindMeUser(id: id, email: email, name: name, phone: phone, friendPhone: friendPhone, records: records, longitude: longitude, latitude: latitude, isOn: isOn, date: createTampDate)
    }
}
