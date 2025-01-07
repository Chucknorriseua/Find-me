//
//  FindMeViewModel.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI


@MainActor
final class FindMeViewModel: ObservableObject {
    
    static let shared = FindMeViewModel()
    
  
    @Published var isShowAlert: Bool = false
    
    
    @Published var requestCount: Int = 0
//    @Published var checkStatus = 10.0
    @Published var errorMessage: String = ""
//    @Published var timer: Timer?
    
    
    @Published var searchFriend: [FindMeUser] = []
    @Published var myfriend: [FindMeUser] = []
    @Published var requestFriend: [FindMeUser] = []
    @Published var modelFindMeUser: FindMeUser

    
    @AppStorage("isButtonPressed", store: UserDefaults(suiteName: "group.findme.com"))
    var isButtonPressed: Bool = false {
        didSet {
            if let sharedDefaults = UserDefaults(suiteName: "group.findme.com") {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {[weak self] in
                    self?.isButtonPressed = sharedDefaults.bool(forKey: "isButtonPressed")
                }
            }
        }
    }
    
    init(person: FindMeUser? = nil) {
        self.modelFindMeUser = person ?? FindMeUser.personModel()
//        startTimerCheckStatus()
    }
    
//    private func startTimerCheckStatus() {
//        timer?.invalidate()
//        timer = Timer.scheduledTimer(withTimeInterval: checkStatus, repeats: true, block: { [weak self] _ in
//            guard let self else { return }
//            Task {
//                await self.checkStatusLocation()
//            }
//        })
//    }
    
//    func checkStatusLocation() async {
//        do {
//            for friend in myfriend {
//                let check = try await FireBaseManager.sherad.chechStatusLocationMyFriends(id: friend.id)
//                if check {
//                    await sendNotificationLocationFindme(name: friend.name ?? "", time: 1)
//                    print("send")
//                } else {
//                    print("not send")
//                }
//            }
//        } catch {
//            print("Error addNewFriend", error.localizedDescription)
//            isShowAlert = true
//            errorMessage = error.localizedDescription
//        }
//    }
    
    func acceptAndAdd_MyFriend(friendID: String, friend: FindMeUser) async {
        do {
            _ = try await FireBaseManager.sherad.Accept_RequestFriendsMyRoom(id: friendID, friend: friend)
        } catch {
            print("Error addNewFriend", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func sendRequestFriend(friendID: String) async {
        do {
            _ = try await FireBaseManager.sherad.sendRequestFriendsMyRoom(id: friendID, friend: modelFindMeUser)
        } catch {
            print("Error addNewFriend", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func acceptRequestFromUser(friendID: String, friend: FindMeUser) async {
        do {
            _ = try await FireBaseManager.sherad.Accept_RequestFriendsMyRoom(id: friendID, friend: friend)
        } catch {
            print("Error addNewFriend", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func updateProfileUser(user: FindMeUser) async  {
        do {
            try await FireBaseManager.sherad.setDataFindMeUser(user: modelFindMeUser)
            for userId in myfriend {
                try await FireBaseManager.sherad.updateMyDataAllMyFriend(id: userId.id, user: modelFindMeUser)
            }
        } catch {
            print("Error updateProfileUser", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    //MARK: FETCH
    
    func fetchProfileUser() async {
        do {
            let user = try await FireBaseManager.sherad.fetchCurrentUserData()
            await MainActor.run { [weak self] in
                self?.modelFindMeUser = user
            }
            await fetchAllMyFriends()
            await fetchRequestFromUser()
        } catch {
            print("Error fetchProfileUser", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllRegistersFindMeUsers() async {
        do {
            let users = try await FireBaseManager.sherad.fethAll_Registers_FindMe_Users(id: modelFindMeUser.id)
            await MainActor.run { [weak self] in
                self?.searchFriend = users
            }
            print("fetchAllRegistersFindMeUsers", users)
        } catch {
            print("Error fetchAllRegistersFindMeUsers", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchRequestFromUser() async  {
        do {
            let (users, requestCount) = try await FireBaseManager.sherad.fethRequestAllUsers(id: modelFindMeUser.id)
            await MainActor.run { [weak self] in
                self?.requestFriend = users
            }
            self.requestCount = requestCount
            print("fetchRequestFromUser", users)
        } catch {
            print("Error fetchAllRegistersFindMeUsers", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    func fetchAllMyFriends() async {
        do {
            let users = try await FireBaseManager.sherad.fetchAllMyFriends()
            await MainActor.run { [weak self] in
                self?.myfriend = users
            }
            await fetchRequestFromUser()
            print("fetchAllMyFriends", users)
        } catch {
            print("Error fetchAllRegistersFindMeUsers", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
    //MARK: Remove
    func removeRequestFriend(id: String, request: FindMeUser) async throws {
        if let index = requestFriend.firstIndex(where: {$0.id == request.id}) {
            self.requestFriend.remove(at: index)
        }
        try await FireBaseManager.sherad.Remove_RequestFriendsMyRoom(id: id, friend: request, collection: "Request")
    }
    
    func removeMyFriends(id: String, request: FindMeUser) async throws {
        if let index = requestFriend.firstIndex(where: {$0.id == request.id}) {
            self.requestFriend.remove(at: index)
        }
        try await FireBaseManager.sherad.Remove_RequestFriendsMyRoom(id: id, friend: request, collection: "MyFriends")
    }
    
    func removeRecords(id: String) async  {
        do {
            try await FireBaseManager.sherad.removeMyRecords(id: id)
            for userID in myfriend {
                try await FireBaseManager.sherad.removeMyUrlRecordsForFriends(friendId: userID.id, recordToRemove: id)
            }
        } catch {
            print("Error removeRecords", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
        }
    }
    
//    func sendNotificationLocationFindme(name: String, time: Int) async {
//        NotificatioManager.shared.notify(title: "Broadcasr \(name)", subTitle: "Your friend turned on the geolocation broadcast may be in trouble!", timeInterval: time)
//    }
    
}
