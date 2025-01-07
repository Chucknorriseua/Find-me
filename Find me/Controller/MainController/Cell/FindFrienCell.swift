//
//  FindFrienCell.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct FindFrienCell: View {
    
    @State var person: FindMeUser
    @StateObject var viewModel: FindMeViewModel
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(person.name ?? "")
                        .font(.system(size: 20, weight: .bold))
     
                        Text(person.email ?? "")
                        .fontWeight(.light)
                }.foregroundStyle(Color.init(hex: "#dce1db"))
                Spacer()
                Button(action: {
                    let persons = FindMeUser(id: person.id, email: person.email, name: person.name, phone: person.phone, friendPhone: person.friendPhone, records: person.records, longitude: person.longitude, latitude: person.latitude, isOn: person.isOn, date: Date())
                    Task { await viewModel.sendRequestFriend(friendID: persons.id)}
                }, label: {
                    Image(systemName: "person.crop.circle.fill.badge.plus")
                        .font(.system(size: 28, weight: .bold))
                        .foregroundStyle(Color.blue.opacity(0.8))
                })
            }.padding(.horizontal)
                .padding(.vertical)
        }.frame(maxWidth: .infinity, maxHeight: 80)
         
            .background(.ultraThickMaterial.opacity(0.4))
        .clipShape(.rect(cornerRadius: 32))
        .padding(.horizontal, 8)
    }
}

#Preview {
    FindFrienCell(person: FindMeUser.personModel(), viewModel: FindMeViewModel.shared)
}
