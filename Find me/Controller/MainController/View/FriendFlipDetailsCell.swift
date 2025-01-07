//
//  FriendFlipDetailsCell.swift
//  Find me
//
//  Created by Евгений Полтавец on 20/12/2024.
//

import SwiftUI

struct FriendFlipDetailsCell: View {
    
    
    @State var friendModel: FindMeUser
    @StateObject var viewModel: FindMeViewModel
    @StateObject var audioViewModel = AudioRecorderViewModel()
    

    @State private var isFlipped: Bool = false
    @Environment (\.dismiss) var dismiss
    
    
    var body: some View {
        GeometryReader(content: { geo in
            
            VStack(alignment: .center, spacing: 10) {
                HStack {
                    if !isFlipped {
                        VStack(spacing: 20) {
                            Group {
                                Text(friendModel.name ?? "")
                                    .fontWeight(.bold)
                                HStack {
                                    VStack(alignment: .leading, spacing: 10) {
                                        Text("longitude: \(friendModel.longitude ?? 0.0)")
                                        Text("latitude: \(friendModel.latitude ?? 0.0)")
                                        Text("email:  \(friendModel.email ?? "")")
                                        Text("phone:  \(friendModel.phone ?? "")")
                                        HStack {
                                            Text("Friend:  \(friendModel.friendPhone ?? "")")
                                            Image(systemName: "teletype.circle.fill")
                                                .font(.system(size: 30))
                                                .foregroundStyle(Color.green)
                                        }.onTapGesture(perform: {
                                            let phoneNumber = "tel://" + (friendModel.friendPhone ?? "")
                                            if let url = URL(string: phoneNumber) {
                                                UIApplication.shared.open(url)
                                            }
                                        })
                                    }
                                    Spacer()
                                }
                                Button {
                                    withAnimation(.snappy) {
                                        isFlipped.toggle()
                                    }
                                } label: {
                                    HStack {
                                        Text("Voice recording")
                                        Image(systemName: "waveform")
                                            .foregroundStyle(Color.red.opacity(0.9))
                                        
                                    }.padding(.all, 6)
                                        .background(Color.blue.opacity(0.8))
                                        .clipShape(.rect(cornerRadius: 14))
                                }
                                Spacer()
                                HStack(spacing: 60) {
                                    Button {
                                        Task {
                                            try await FindMeViewModel.shared.removeMyFriends(id: friendModel.id, request: friendModel)
                                            dismiss()
                                        }
                                    } label: {
                                        Image(systemName: "trash.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .foregroundStyle(Color.red.opacity(0.9))
                                    }
                                    Button {
                                        callNumber()
                                        
                                    } label: {
                                        Image(systemName: "phone.arrow.up.right.circle.fill")
                                            .resizable()
                                            .frame(width: 44, height: 44)
                                            .foregroundStyle(Color.green.opacity(0.9))
                                    }
                                }
                            }
                        }.font(.system(size: 19, weight: .medium))
                            .foregroundStyle(Color.white)
                    } else {
                        VStack {
                            ScrollView {
                                VStack {
                                    RecordsCell(records: friendModel, audiioViewModel: audioViewModel)
                                }.padding(.top, 20)
                            }.scrollIndicators(.visible)
                                .overlay(alignment: .topLeading) {
                                    Button {
                                        isFlipped.toggle()
                                    } label: {
                                        Image(systemName: "chevron.backward.circle.fill")
                                            .font(.title2)
                                    }.padding(.top, -6)
                                }
                        }.rotation3DEffect(Angle(degrees: 180), axis: (x: 0.0, y: 1.0, z: 0.0))
                            .ignoresSafeArea(.all)
                            .foregroundStyle(Color.white)
                    }
                    
                }
                .multilineTextAlignment(.center)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: geo.size.width * 1, maxHeight: geo.size.height * 1)
                //                                .background(Color.blue)
                .background(.ultraThickMaterial.opacity(0.7))
                .clipShape(RoundedRectangle(cornerRadius: 25.0, style: .continuous))
                .padding(.horizontal)
                .rotation3DEffect(
                    isFlipped ? Angle(degrees: 180) : .zero,
                    axis: (x: 0.0, y: 1.0, z: 0.0)
                )
                .animation(.spring(duration: 0.7), value: isFlipped)
            }
            .overlay(alignment: .center, content: {
                ZStack {}
                    .customAlert(isPresented: $audioViewModel.isShowAlert, hideCancel: false, message: audioViewModel.message, title: "Error") {} onCancel: {}
            })
        }).frame(maxHeight: 360)
        
    }
    
    func callNumber() {
        let phoneNumber = "tel://" + (friendModel.phone ?? "")
        if let url = URL(string: phoneNumber) {
            UIApplication.shared.open(url)
        }
    }
}

#Preview(body: {
    FriendFlipDetailsCell(friendModel: FindMeUser.personModel(), viewModel: FindMeViewModel.shared)
})

