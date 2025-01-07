//
//  AuthViewModel.swift
//  Find me
//
//  Created by Евгений Полтавец on 14/12/2024.
//

import Foundation
import FirebaseAuth

@MainActor
final class AuthViewModel: ObservableObject {
    
    static var sherad = AuthViewModel()
    
    @Published var locationManager = LocationManager()
    @Published var currentUser: User? = nil
    @Published var errorMessage: String = ""
    @Published var isShowAlert: Bool = false
    @Published var isLoader: Bool = false
    
    let auth = Auth.auth()
    
    init() {
        _ = auth.addStateDidChangeListener { [weak self] _ , user in
            DispatchQueue.main.async {
                self?.currentUser = user
            }
        }
    }
    
    func createAccount(email: String, password: String, name: String, phone: String, coordinator: Coordinator) async throws {
        do {
            let result = try await Auth.auth().createUser(withEmail: email, password: password)
            let uid = result.user.uid
            let createUser = FindMeUser(id: uid, email: email, 
                                        name: name,
                                        phone: phone,
                                        friendPhone:  "",
                                        records: [],
                                        longitude: locationManager.userLongitude,
                                        latitude: locationManager.userLatitude, isOn: false, date: Date())
            
            try await FireBaseManager.sherad.setDataFindMeUser(user: createUser)
            isLoader = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                coordinator.push(page: .main)
            }
        } catch {
            isLoader = false
            isShowAlert = true
            errorMessage = error.localizedDescription.lowercased()
            print("creatAccount", error.localizedDescription.lowercased())
        }
    }
    
    func signIn(email: String, password: String, coordinator: Coordinator) async throws {
        do {
           _ = try await auth.signIn(withEmail: email, password: password)
            isLoader = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                coordinator.push(page: .main)
            }
        } catch {
            isLoader = false
            isShowAlert = true
            errorMessage = error.localizedDescription.lowercased()
            print("signIn Error ", error.localizedDescription.lowercased())
        }
    }
        
    func signOut(coordinator: Coordinator) async {
        do {
            try auth.signOut()
            self.currentUser = nil
            coordinator.popToRoot()
        } catch {
            isShowAlert = true
            errorMessage = error.localizedDescription.lowercased()
            print("DEBUG: SignOut Error...", error.localizedDescription)
        }
    }
}
