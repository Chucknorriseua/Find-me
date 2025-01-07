//
//  FriendRequest.swift
//  Find me
//
//  Created by Евгений Полтавец on 16/12/2024.
//

import SwiftUI

struct FriendRequest: View {
    
    @StateObject var viewModel: FindMeViewModel
    @Environment (\.dismiss) var dismiss
    
    var body: some View {
        VStack {
            LazyVStack {
                ForEach(viewModel.requestFriend) { item in
                    FriendAccept(person: item, viewModel: viewModel)
                }
            }
            Spacer()
        }.createBackgrounfFon()
            .toolbar(content: {
                ToolbarItem(placement: .topBarLeading) {
                    HStack {
                        Button(action: {dismiss()}, label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)
                        })
                        Text("Friend Request")
                            .font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                    }
                }
            })
    }
}

#Preview {
    FriendRequest(viewModel: FindMeViewModel.shared)
}
