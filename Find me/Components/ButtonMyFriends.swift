//
//  ButtonMyFriends.swift
//  Find me
//
//  Created by Евгений Полтавец on 11/12/2024.
//

import SwiftUI

struct ButtonMyFriends: View {
    
    @Binding var request: Int
    var action: () -> ()
    
    var body: some View {
        ZStack {
            Button(action: {
                withAnimation(.snappy(duration: 1)) {
                    action()
                }
            }) {
                Image(systemName: "person.2.circle.fill")
                    .resizable()
                    .frame(width: 60, height: 60)
                    .clipped()
                    .foregroundStyle(Color.init(hex: "#abdbe3"))
            }
        }.overlay(alignment: .topTrailing) {
            VStack {
                if request > 0 {
                    Text("\(request)")
                        .padding(.all, 4)
                        .fontWeight(.bold)
                        .foregroundStyle(Color.white)
                        .background(Color.blue)
                        .clipShape(Circle())
                }
            }.padding(.top, -10)
        }
    }
}

