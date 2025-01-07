//
//  FriendAccept.swift
//  Find me
//
//  Created by Евгений Полтавец on 16/12/2024.
//

import SwiftUI

struct FriendAccept: View {
    
    @State var person: FindMeUser
    @StateObject var viewModel: FindMeViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(person.name ?? "")
                        .font(.system(size: 22, weight: .bold))
     
                        Text(person.email ?? "")
                        .fontWeight(.light)
                }.foregroundStyle(Color.init(hex: "#dce1db"))
                Spacer()
                Button(action: {
                    Task {
                       try await viewModel.removeRequestFriend(id: person.id, request: person)
                    }
                }, label: {
                    Text("Cancel")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.all, 6)
                }).background(Color.red)
                    .clipShape(.rect(cornerRadius: 12))
                Button(action: {
                    let persons = FindMeUser(id: person.id, email: person.email, name: person.name, phone: person.phone, friendPhone: person.friendPhone, records: person.records, longitude: person.longitude, latitude: person.latitude, isOn: person.isOn, date: Date())
                    Task { await viewModel.acceptRequestFromUser(friendID: persons.id, friend: persons)}
                }, label: {
                    Text("Accept")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.all, 6)
                }).background(Color.blue)
                    .clipShape(.rect(cornerRadius: 12))
                
            }.padding(.horizontal)
                .padding(.vertical)
        }.frame(maxWidth: .infinity, maxHeight: 80)
            .background(.ultraThickMaterial.opacity(0.4))
            .clipShape(.rect(cornerRadius: 32))
            .padding(.horizontal, 8)
    }
}

//#Preview {
//    FriendAccept(person: FindMeUser.init(id: "", email: "wfdfdsfdsfsdfsd", name: "sasasasa", records: "", isOn: false, date: Date()), viewModel: FindMeViewModel.shared)
//}
