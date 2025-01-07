//
//  FindMeMain.swift
//  Find me
//
//  Created by Евгений Полтавец on 10/12/2024.
//

import SwiftUI

struct FindMeMain: View {
    
    
    @State private var isPresenstSettings: Bool = false
    @State private var isPresenstMyFreinds: Bool = false
    
    @State private var errorMassage: String = ""
    @StateObject var viewModel: FindMeViewModel
    @EnvironmentObject var audioRecordingManager: AudioRecorderViewModel
    @EnvironmentObject var coordinator: Coordinator

    
    var body: some View {
        VStack {
            VStack {
                if !viewModel.isButtonPressed {
                    Text("Start Location")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundStyle(Color.white)
                    
                } else {
                    Text("Your geolocation is broadcast to your friend.")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                }
                VStack {
                    ButtonAnimationLocation(isOn: $viewModel.isButtonPressed)
                    
                }
            }.transition(.opacity)
                .animation(.easeInOut(duration: 0.6), value: viewModel.isButtonPressed)
                .onChange(of: viewModel.isButtonPressed) { _, newValue in
                    handleButtonStateChange(newValue)
                }
                .onAppear(perform: {
                    Task {
                        await viewModel.fetchProfileUser()
                    }
                })
        }.createBackgrounfFon()
            .customAlert(isPresented: $viewModel.isShowAlert, hideCancel: false, message: errorMassage, title: "Error", onConfirm: {}, onCancel: {})
            .customAlert(isPresented: $audioRecordingManager.isShowAlert, hideCancel: false, message: errorMassage, title: "Audio Error", onConfirm: {}, onCancel: {})
            .ignoresSafeArea()
            .overlay(alignment: .bottomTrailing, content: {
                if !viewModel.isButtonPressed {
                    ButtonMyFriends(request: $viewModel.requestCount) {
                        isPresenstMyFreinds = true
                    }.padding(.horizontal)
                        .padding(.bottom)
                } else {
                    
                    HStack {
                        if audioRecordingManager.isRecording {
                            Text("Voice recording in progress")
                            Image(systemName: "waveform.circle")
                                .resizable()
                                .frame(width: 30, height: 30)
                        } else {
                            Button {
                                Task {
                                    await audioRecordingManager.startRecording()
                                }
                            } label: {
                                HStack {
                                    Text("Start new Records")
                                    Image(systemName: "record.circle")
                                   
                                }
                                .font(.system(size: 22, weight: .bold))
                                .padding(.trailing, 20)
                            }
                        }
                    }.font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                        .padding(.trailing, 60)
                        .padding(.vertical, 60)
                    
                }
            }).transition(.opacity)
            .animation(.easeInOut(duration: 0.6), value: viewModel.isButtonPressed)
            .sheet(isPresented: $isPresenstSettings, content: {
                SettingsView(viewModel: viewModel)
                    .presentationDetents([.height(700)])
            })
        
            .sheet(isPresented: $isPresenstMyFreinds, content: {
                MyAddFriends(viewModel: viewModel, isHide: $isPresenstMyFreinds)
                    .presentationDetents([.height(600)])
                    .interactiveDismissDisabled()
                
            }).toolbar {
                ToolbarItem(placement: .principal) {
                    if !viewModel.isButtonPressed {
                        HStack {
                            Button(action: {
                                coordinator.push(page: .search)
                            }, label: {
                                Image(systemName: "magnifyingglass.circle")
                            })
                            Spacer()
                            Button(action: {isPresenstSettings = true}, label: {
                                Image(systemName: "gearshape.2")
                            })
                            
                        }.font(.system(size: 22, weight: .bold))
                            .foregroundStyle(Color.white)
                    } else {
                        Text("")
                    }
                }
            }.transition(.opacity)
            .animation(.easeInOut(duration: 0.6), value: viewModel.isButtonPressed)
        
    }
    
    private func handleButtonStateChange(_ isOn: Bool) {
        if isOn {
            Task {
                await audioRecordingManager.startRecordsLoop()
            }
        } else {
            Task {
                await audioRecordingManager.stopRecording()
            }
        }
    }
}

#Preview {
    FindMeMain(viewModel: FindMeViewModel.shared)
}
