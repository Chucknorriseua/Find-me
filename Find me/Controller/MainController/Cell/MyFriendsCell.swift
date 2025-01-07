//
//  MyFriendsCell.swift
//  Find me
//
//  Created by Евгений Полтавец on 11/12/2024.
//

import SwiftUI

struct MyFriendsCell: View {
    
    @State var person: FindMeUser
    
    var body: some View {
        VStack {
            HStack {
                VStack {
                    Text(person.name ?? "")
                        .font(.system(size: 24, weight: .bold))

                }.foregroundStyle(Color.init(hex: "#dce1db"))
                Spacer()
                if person.isOn {
                    Text("Broadcast location")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.green)
                } else {
                    Text("non broadcast location")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(Color.red)
                }
                
                Image(systemName: "chevron.forward")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundStyle(Color.blue.opacity(0.8))
                
            }.padding(.horizontal)
                .padding(.vertical)
            
        }.frame(maxWidth: .infinity, maxHeight: 80)
            .background(.ultraThickMaterial.opacity(0.4))
        
        .clipShape(.rect(cornerRadius: 32))
        .padding(.horizontal, 8)
    }
}

//#Preview {
//    MyFriendsCell(person: FindMeUser.init(id: "", email: "", name: "sasasa", records: [], isOn: true, date: Date()))
//}
