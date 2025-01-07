//
//  FindFriendsAndAdd.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct FindFriendsAndAdd: View {
    
    
    @State private var findFriend: String = ""
    @EnvironmentObject var coordinator: Coordinator
    @StateObject  var viewModel: FindMeViewModel
   
    private var searchFriend: [FindMeUser] {
        if findFriend.isEmpty {
            return []
        } else {
            return viewModel.searchFriend.filter { $0.name?.localizedCaseInsensitiveContains(findFriend) ?? false}
        }
    }
    
    var body: some View {
            VStack {
                ScrollView {
                    LazyVStack {
                        ForEach(searchFriend, id: \.name) { persons in
                            FindFrienCell(person: persons, viewModel: viewModel)
                        }
                    }
                }
                .onAppear(perform: {
                    Task {
                    await viewModel.fetchAllRegistersFindMeUsers()
                    }
                })
            }.searchable(text: $findFriend)
                .toolbar(content: {
                    ToolbarItem(placement: .navigation) {
                        HStack {
                            Button(action: {coordinator.pop()}, label: {
                               Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)
                            })
                        }
                    }
                    ToolbarItem(placement: .topBarTrailing) {
                        Text("Find Friend")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                })
             .createBackgrounfFon()
             .customAlert(isPresented: $viewModel.isShowAlert, hideCancel: false, message: viewModel.errorMessage, title: "Error") {} onCancel: {}
    }
}

#Preview {
    FindFriendsAndAdd(viewModel: FindMeViewModel.shared)
}
