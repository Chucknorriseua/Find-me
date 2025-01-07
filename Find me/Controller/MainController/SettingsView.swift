//
//  SettingsView.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct SettingsView: View {
    
    @State private var phone: String = ""
    @State private var nickName: String = ""
    @State private var isSwitchGeo: Bool = false
    @State private var isMyRecords: Bool = false
    
    @StateObject var viewModel: FindMeViewModel
    @StateObject var authViewModel = AuthViewModel()
    @StateObject var audioViewModel = AudioRecorderViewModel()
    @EnvironmentObject var coordinator: Coordinator
    @Environment (\.dismiss) private var dismiss

    
    var body: some View {
        GeometryReader(content: { geometry in
            VStack {
                VStack {
                    Group {
                        CustomTextFieldSettings(title: "Nickname@", text: Binding(get: {
                            viewModel.modelFindMeUser.name ?? ""
                        }, set: { new in
                            viewModel.modelFindMeUser.name = new
                        }))
                        VStack {
                            CustomTextFieldSettings(title: "My phone: ", text: Binding(get: {
                                viewModel.modelFindMeUser.phone ?? ""
                            }, set: { new in
                                viewModel.modelFindMeUser.phone = formatPhoneNumber(new)
                            }))
                            CustomTextFieldSettings(title: "Friend phone:", text: Binding(get: {
                                viewModel.modelFindMeUser.friendPhone ?? ""
                            }, set: { new in
                                viewModel.modelFindMeUser.friendPhone = formatPhoneNumber(new)
                            }))
                        }.keyboardType(.phonePad)
                            .textContentType(.telephoneNumber)
                        
                        VStack {
                            
                            if !isMyRecords {
                                VStack {
                                    Button(action: {
                                        withAnimation(.snappy(duration: 1)) {
                                            isMyRecords.toggle()
                                        }
                                    }, label: {
                                        HStack {
                                            Text("My records")
                                            Image(systemName: "waveform.circle")
                                                .foregroundStyle(Color.red.opacity(0.8))
                                            Spacer()
                                            Image(systemName: "chevron.right")
                                        }.font(.system(size: 22, weight: .bold))
                                            .foregroundStyle(Color.white)
                                    }).padding(.horizontal)
                                }
                            } else {
                                VStack {
                                    ScrollView {
                                        LazyVStack {
                                            ForEach(Array(viewModel.modelFindMeUser.records.enumerated()), id: \.element) { index, record in
                                                
                                                RecordSettingsCell(records: record, date: viewModel.modelFindMeUser.date, count: index + 1, audiioViewModel: audioViewModel, delete: {
                                                    Task {
                                                       await viewModel.removeRecords(id: record)
                                                    }
                                                })
                                
                                            }
                                        }.padding(.vertical, 50)
                                            .overlay(alignment: .center, content: {
                                                ZStack {}
                                                    .customAlert(isPresented: $audioViewModel.isShowAlert, hideCancel: false, message: audioViewModel.message, title: "Error") {} onCancel: {}
                                            })
                                    }
                                    .overlay(alignment: .topLeading) {
                                        Button(action: {
                                            withAnimation(.snappy(duration: 1)) {
                                                isMyRecords.toggle()
                                            }
                                        }, label: {
                                            Image(systemName: "chevron.backward.circle.fill")
                                                .font(.title2)
                                                .foregroundStyle(Color.white)
                                        }).padding([.horizontal, .vertical])
                                    }
                                }
                            }
                        }.frame(maxWidth: .infinity, maxHeight: isMyRecords ? 340 : 50)
                            .background(.ultraThinMaterial.opacity(0.7))
                            .clipShape(.rect(cornerRadius: 32))
                            .padding(.horizontal)
                        
                        VStack(spacing: -20) {
                            
                            MainButtonSignIn(image: "person.crop.circle.fill", title: "Save", width: geometry.size.width * 0.8) {
                                Task {
                                    await viewModel.updateProfileUser(user: viewModel.modelFindMeUser)
                                }
                            }
                            MainButtonSignIn(image: "figure.walk.circle.fill", title: "Sign Out", width: geometry.size.width * 0.8) {
                                dismiss()
                                Task {
                                    await authViewModel.signOut(coordinator: coordinator)
                                }
                            }
                        }
                    }
                    Spacer()
                }.padding(.top, 30)
                
            }.createBackgrounfFon()
                .customAlert(isPresented: $viewModel.isShowAlert, hideCancel: false, message: viewModel.errorMessage, title: "Error") {} onCancel: {}
        }).onAppear {
            Task {
                await viewModel.fetchProfileUser()
            }
        }
    }
}

#Preview {
    SettingsView(viewModel: FindMeViewModel.shared)
}
