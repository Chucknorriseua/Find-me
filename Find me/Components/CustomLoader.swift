//
//  CustomLoader.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct CustomLoader: View {

    @Binding var isLoader: Bool
    @State private var dots = 0
    @Binding var text: String
    private let maxDots = 3
    private let timer = Timer.publish(every: 0.5, on: .main, in: .common).autoconnect()
    
    var body: some View {
        if isLoader {
            ZStack {
                Color.black.opacity(0.3)
                    .ignoresSafeArea()
                VStack(alignment: .center, spacing: 6) {
//                    ProgressView()
//                        .tint(Color.white)
//                        .progressViewStyle(CircularProgressViewStyle())
//                        .scaleEffect(1.5)
                    Text("\(text)" + String(repeating: ".", count: dots))
                        .font(.system(size: 16, weight: .bold))
                        .bold()
                        .onReceive(timer) { _ in
                     
                            if dots < maxDots {
                                dots += 1
                            } else {
                                dots = 0
                            }
                        }
                }
                .padding(.all, 20)
                .background(.ultraThinMaterial.opacity(0.6))
                .clipShape(.rect(cornerRadius: 24))
                .shadow(radius: 10)
            }
        }
        
    }
}

