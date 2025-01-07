//
//  CustomTextFieldSettings.swift
//  Find me
//
//  Created by Евгений Полтавец on 21/12/2024.
//

import SwiftUI

struct CustomTextFieldSettings: View {
    
    var title: String
    var text: Binding<String>
    
    var body: some View {
        VStack {
            VStack {
                TextField(title, text: text)
                    .foregroundStyle(Color.white)
            }.padding([.vertical, .horizontal])
            
        }.background(.ultraThinMaterial.opacity(0.8))
            .clipShape(.rect(cornerRadius: 24))
            
            .padding(.horizontal)
    }
}

#Preview {
    CustomTextFieldSettings(title: "", text: .constant(""))
}
