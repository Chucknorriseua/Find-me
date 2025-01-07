//
//  AuthViewController.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct AuthViewController: View {
    
    @State private var email: String = ""
    @State private var nickname: String = ""
    @State private var password: String = ""
    @State private var phone: String = ""
    @State private var textLoader: String = "Loader"
    
    @State var showPassword: Bool = false
    @State private var isCreateAccount: Bool = false
    
    @EnvironmentObject var coordinator: Coordinator
    @StateObject var authViewModel = AuthViewModel()
    
    
    var body: some View {
        NavigationStack {
            GeometryReader { geo in
                VStack {
                    VStack {
                        Group {
                            CustomTextField(text: $email, title: "Email@", width: geo.size.width * 0.88, showPassword: .constant(false))
                            
                            CustomTextField(text: $password, title: "Password", width: geo.size.width * 0.88, showPassword: $showPassword)
                            if isCreateAccount {
                                CustomTextField(text: $nickname, title: "Name", width: geo.size.width * 0.88, showPassword: .constant(false))
                                CustomTextField(text: $phone, title: "phone", width: geo.size.width * 0.88, showPassword: .constant(false))
                                    .keyboardType(.phonePad)
                                    .textContentType(.telephoneNumber)
                                    .onChange(of: phone) { _, new in
                                        phone = formatPhoneNumber(new)
                                    }
                                
                                MainButtonSignIn(image: "person.crop.circle.fill", title: "Registrations", width: geo.size.width * 0.78) {
                                        Task {
                                            try await authViewModel.createAccount(email: email, password: password, name: nickname, phone: phone, coordinator: coordinator)
                                    }
                                }
                            } else {
                                MainButtonSignIn(image: "figure.walk", title: "Sign In", width: geo.size.width * 0.78) {
                                        Task {
                                            try await authViewModel.signIn(email: email, password: password, coordinator: coordinator)
                                    }
                                }
                            }
                            
                            VStack {
                                Button(action: {
                                    withAnimation(.easeOut(duration: 0.7)) {
                                        isCreateAccount.toggle()
                                    }
                                }) {
                                    isCreateAccount ? Text("Back") : Text("Create Account")
                                    
                                }.transition(.slide)
                                    .font(.system(size: 18, weight: .heavy, design: .rounded))
                                    .foregroundStyle(Color.white)
                            }.padding(.top, 30)
                        }
                        .onAppear {
                            authViewModel.isLoader = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                if authViewModel.auth.currentUser != nil {
                                    coordinator.push(page: .main)
                                } else {
                                    authViewModel.isLoader = false
                                    print("user not auth.")
                                }
                            }
                        }
                        .onDisappear(perform: {
                            authViewModel.isLoader = false
                            isCreateAccount = false
                            password = ""
                            phone = ""
                        })
                        
                    }.frame(width: geo.size.width * 0.9, height:  isCreateAccount ? geo.size.height * 0.65 : geo.size.height * 0.5)
                        .background(Color.init(hex: "#063970").opacity(0.3))
                        .clipShape(.rect(cornerRadius: 12))
                        .padding(.top, 140)
                        .padding(.leading, 20)
                        
                }
            }.createBackgrounfFon()
                .ignoresSafeArea(.keyboard)
                .toolbar(content: {
                    VStack {
                        HStack {
                            Text("Welcom in, Find me")
                            Image(systemName: "poweroutlet.type.k.fill")
                        }
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(Color.init(hex: "#dce1db"))
                    }.padding(.horizontal, 30)
                })
        }.customAlert(isPresented: $authViewModel.isShowAlert, hideCancel: false, message: authViewModel.errorMessage, title: "Error", onConfirm: {}, onCancel: {})
            .overlay(alignment: .center) {
                ZStack {
                    CustomLoader(isLoader: $authViewModel.isLoader, text: $textLoader)
                }
                
            }
    }
}

#Preview {
    AuthViewController()
}
