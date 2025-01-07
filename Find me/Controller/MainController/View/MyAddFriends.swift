//
//  MyAddFriends.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct MyAddFriends: View {
    
    
    @StateObject var viewModel: FindMeViewModel
    @State private var navigatioFriendRequest: Bool = false
    @State private var sendNewFriend: Bool = false
    @Binding var isHide: Bool
    
    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Button(action: {
                        isHide.toggle()
                    }, label: {
                        Image(systemName: "chevron.left.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.white)
                    })
                    Text("My Friends")
                        .font(.title2.bold())
                        .foregroundStyle(Color.white)
                    Spacer()
                    NavigationLink {
                        FriendRequest(viewModel: viewModel)
                            .navigationBarBackButtonHidden(true)
                    } label: {
                        HStack {
                            Text("Request")
                                .fontWeight(.bold)
                                .padding(.all, 4)
                        }.background(Color.white)
                            .clipShape(.rect(cornerRadius: 12))
                    }
                    .overlay(alignment: .topTrailing) {
                        VStack {
                            Text("\(viewModel.requestCount)")
                                .padding(.all, 4)
                                .fontWeight(.bold)
                                .foregroundStyle(Color.white)
                                .background(Color.blue)
                                .clipShape(Circle())
                        }.padding(.top, -16)
                    }
                }.padding([.horizontal, .vertical])
                ScrollView {
                    LazyVStack {
                        ForEach(viewModel.myfriend, id: \.id) { friend in
                            NavigationLink(destination: MyFriendsMapLocationDetails(person: friend, viewModel: viewModel).navigationBarBackButtonHidden(true)) {
                                MyFriendsCell(person: friend)
                            }
                        }
                    }
                }
                .onAppear(perform: {
                    Task {
                    await viewModel.fetchAllMyFriends()
                    }
                })
            }.createBackgrounfFon()
        }
    }
}

#Preview {
    MyAddFriends(viewModel: FindMeViewModel.shared, isHide: .constant(false))
}
