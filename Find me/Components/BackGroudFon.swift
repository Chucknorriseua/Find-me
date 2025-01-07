//
//  BackGroudFon.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct BackGroudFon: ViewModifier {
    func body(content: Content) -> some View {
        content
            .frame(maxWidth: UIScreen.main.bounds.width, maxHeight: UIScreen.main.bounds.height)
            .background(
                LinearGradient(colors: [Color.init(hex: "#1e81b0"), Color.init(hex: "#063970").opacity(0.9)],
                               startPoint: .topLeading,
                               endPoint: .bottomLeading)
            )
    }
}

extension View {
    func createBackgrounfFon() -> some View {
        self.modifier(BackGroudFon())
    }
}
