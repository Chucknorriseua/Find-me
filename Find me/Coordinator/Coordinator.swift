//
//  Coordinator.swift
//  Find me
//
//  Created by Евгений Полтавец on 13/12/2024.
//

import SwiftUI

enum PageView: String, Identifiable {
    case auth, main, search, setting, friend, newFriend
    
    var id: String {
        self.rawValue
    }
}

final class Coordinator: ObservableObject  {
    @Published var path: NavigationPath = .init()
    
    
    func push(page: PageView) {
        path.append(page)
    }
    
    func pop() {
        path.removeLast()
    }
    
    func popToRoot() {
        path.removeLast(path.count)
    }
    
    @ViewBuilder
    func Adminbuild(page: PageView) -> some View {
        NavigationView(content: {
            switch page {
            case .auth:
                AuthViewController()
            case .main:
                FindMeMain(viewModel: FindMeViewModel.shared)
            case .search:
                FindFriendsAndAdd(viewModel: FindMeViewModel.shared)
            case .setting:
                SettingsView(viewModel: FindMeViewModel.shared)
            case .friend:
                MyAddFriends(viewModel: FindMeViewModel.shared, isHide: .constant(false))
            case .newFriend:
                FriendRequest(viewModel: FindMeViewModel.shared)
            }
            
        }).navigationBarBackButtonHidden(true)
    }
}
