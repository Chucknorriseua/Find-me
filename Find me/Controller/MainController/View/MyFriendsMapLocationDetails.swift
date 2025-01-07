//
//  MyFriendsMapLocationDetails.swift
//  Find me
//
//  Created by Евгений Полтавец on 11/12/2024.
//

import SwiftUI
import MapKit

struct MyFriendsMapLocationDetails: View {
    
    @Environment (\.dismiss) private var dismiss
    @StateObject var locationManager = LocationManager()
    @State private var position: MapCameraPosition = .userLocation(fallback: .automatic)
    @State private var showDetails: Bool = false
    @State private var isZoomfriend: Bool = false
    @State private var route: MKRoute?
  
    
    @State private var friendLocation: CLLocationCoordinate2D?
    
    @State var person: FindMeUser
    @StateObject var viewModel: FindMeViewModel
    
    var body: some View {
        VStack {
        
            if let userLocation = locationManager.currentLocation, let friendLocation {
                VStack {
                    VStack {
                        MapView(userLocation: userLocation, friendLocation: friendLocation, route: locationManager.userRoute, zoomFriend: $isZoomfriend)
                            .frame(minWidth: 400, maxHeight: 700)
                            .ignoresSafeArea()
                            .onAppear {
                                locationManager.getDirections(from: userLocation, to: friendLocation)
                        }
                    }.ignoresSafeArea(.all)
                }
                .onChange(of: locationManager.currentLocation) {_, newLocation in
                    if let newLocation = newLocation {
                        let friendLocation = friendLocation
                        locationManager.getDirections(from: newLocation, to: friendLocation)
                    }
                }
            } else {
                VStack {
                    Image(systemName: "map")
                    Text("Non found")
                }.font(.system(size: 20, weight: .bold))
                    .foregroundStyle(Color.white)
            }
        }.createBackgrounfFon()
            .customAlert(isPresented: $locationManager.isShowAlert, hideCancel: true, message: locationManager.errorMessage, title: "Not nearby", onConfirm: {
                isZoomfriend = true
            }, onCancel: {
                
            })
            .overlay(alignment: .center, content: {
                ZStack {
                    if showDetails {
                        Rectangle()
                            .fill(.ultraThinMaterial.opacity(0.8))
                            .ignoresSafeArea(.all)
                            .transition(.opacity)
                        VStack {
                            FriendFlipDetailsCell(friendModel: person, viewModel: viewModel)
                        }.transition(.scale)
                        
                    }
                }.animation(.easeOut, value: showDetails)
            })
            .onAppear(perform: {
                locationManager.locationManager.startUpdatingLocation()
                Task {
                    friendLocation = await locationManager.fetchCurrentUserCoordinate(user: person)
                    await locationManager.updateLocation(user: FindMeViewModel.shared.modelFindMeUser, isOn: true)
                }
            })
            .onDisappear(perform: {
                locationManager.locationManager.stopUpdatingLocation()
                Task {
                    await locationManager.updateLocation(user: FindMeViewModel.shared.modelFindMeUser, isOn: false)
                }
            })
            .toolbar(content: {
                ToolbarItem(placement: .navigation) {
                    HStack {
                        Button(action: {dismiss()}, label: {
                            Image(systemName: "chevron.left.circle.fill")
                                .font(.system(size: 20, weight: .bold))
                                .foregroundStyle(Color.white)
                        })
                    }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        withAnimation(.snappy(duration: 0.6)) {
                            
                            showDetails.toggle()
                        }
                    } label: {
                        VStack(alignment: .trailing) {
                            HStack {
                                Text(person.name ?? "")
                                Image(systemName: showDetails ? "chevron.left.circle.fill" : "chevron.right.circle.fill")
                            }
                            VStack {
                                Text(locationManager.distance)
                                Text(locationManager.timeTo)
                            }.fontWeight(.bold)
                                .foregroundStyle(Color.white)
                        }
                        .font(.system(size: 18, weight: .bold))
                        .foregroundStyle(Color.white)
                    }.padding(.top, 40)
                }
            })
    }
}
