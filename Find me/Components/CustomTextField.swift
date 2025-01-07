//
//  CustomTextField.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct CustomTextField: View {
    
    var text: Binding<String>
    var title: String
    var width: CGFloat
    
    
    @Binding var showPassword: Bool
    
    var body: some View {
        Group {
            if title == "Password" && !showPassword {
                SecureField(text: text) {
                    Text(title)
                        .monospaced()
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                        .contentTransition(.numericText())
                }
            } else {
                TextField(text: text) {
                    Text(title)
                        .monospaced()
                        .foregroundStyle(.white.opacity(0.5))
                        .fontWeight(.semibold)
                }
            }
        }
        .foregroundStyle(.white)
        .padding(.leading)
        .frame(width: width, height: 60)
        .background(Color(hex: "#21292F"), in: RoundedRectangle(cornerRadius: 24))
        .overlay(alignment: .trailing) {
            if title == "Password" {
                Button(action: {
                    withAnimation {
                        showPassword.toggle()
                    }
                }, label: {
                    Image(systemName: showPassword ? "eye.fill" : "eye.slash.fill")
                        .foregroundStyle(Color.init(hex: "F3E3CE"))
                        .font(.system(size: 22))
                        .padding(.trailing)
                })
            }
        }
    }
}

