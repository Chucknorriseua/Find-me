//
//  ButtonAnimationLocation.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI
import WidgetKit

struct ButtonAnimationLocation: View {
    
    @Binding var isOn: Bool
    @State private var animateRings: Bool = false
    @StateObject var viewModel = LocationManager()
    @AppStorage("isButtonPressed", store: UserDefaults(suiteName: "group.findme.com"))
    var isButtonPressed: Bool = false
    
    var body: some View {
        ZStack {
            if isOn {
                ForEach(0..<3, id: \.self) { index in
                    Circle()
                        .stroke(Color.white, lineWidth: 8)
                        .frame(width: animateRings ? 400 : 50, height: animateRings ? 400 : 50)
                        .scaleEffect(animateRings ? 1 : 0.1)
                        .opacity(animateRings ? 0 : 1)
                        .animation(
                            .easeInOut(duration: 2.5).repeatForever(autoreverses: false).delay(Double(index) * 0.3),
                            value: animateRings
                        )
                }
            }
            Button(action: {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isOn.toggle()
                    isButtonPressed ? viewModel.startUpdate() : viewModel.stopUpdate()
                }
                WidgetCenter.shared.reloadAllTimelines()
            }, label: {
                if !isOn {
                    Image(systemName: "play.circle.fill")
                } else {
                    Image(systemName: "stop.circle.fill")
                }
            })
            .font(.system(size: 84, weight: .bold))
            .foregroundStyle(isOn ? Color.red.opacity(0.8) : Color.green.opacity(0.8))
        }
        .onChange(of: isOn, { _, newValue in
            animateRings = newValue
        })
        .onAppear {
            animateRings = isOn
        }
    }
}
