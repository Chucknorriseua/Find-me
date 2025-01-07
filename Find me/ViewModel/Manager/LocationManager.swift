//
//  LocationManager.swift
//  Find me
//
//  Created by Евгений Полтавец on 14/12/2024.
//

import SwiftUI
import MapKit
import CoreLocation

final class LocationManager: NSObject, ObservableObject, CLLocationManagerDelegate {
    
    static let sherad = LocationManager()
    
    var locationManager = CLLocationManager()
    
    
    private var lastKnownLocation: CLLocationCoordinate2D?
    private var isSend: Bool = false
    
    @Published var userLatitude: Double = 0.0
    @Published var userLongitude: Double = 0.0
    @Published var currentLocation: CLLocationCoordinate2D? = nil
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationError: Error?
    
    @Published var errorMessage: String = ""
    @Published var distance: String = ""
    @Published var timeTo: String = ""
    @Published var isShowAlert: Bool = false
    
    
    @Published var userRoute: MKRoute?
    
    @AppStorage("isButtonPressed", store: UserDefaults(suiteName: "group.findme.com"))
    var isButtonPressed: Bool = false
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = false
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        locationManager.distanceFilter = 5
    }
    
    deinit {
        locationManager.delegate = nil
        locationManager.stopUpdatingLocation()
    }
    
    func startUpdate() {
        guard isButtonPressed else { return }
        Task {
//            await AudioRecorderViewModel.shared.startRecordsLoop()
            locationManager.startUpdatingLocation()            
        }
        print("Start")
    }
    
    
    func stopUpdate() {
        guard !isButtonPressed else { return }
        Task {
//            await AudioRecorderViewModel.shared.stopRecording()
            await updateLocation(user: FindMeViewModel.shared.modelFindMeUser, isOn: false)
            locationManager.stopUpdatingLocation()
        }
        print("Stop")
    }
    
    func requestAuth() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    @MainActor
    func fetchCurrentUserCoordinate(user: FindMeUser) async -> CLLocationCoordinate2D? {
        do {
            let location = try await FireBaseManager.sherad.fetchFriendLocation(friendId: user.id)
            return location
        } catch {
            print("Error fetchAllRegistersFindMeUsers", error.localizedDescription)
            isShowAlert = true
            errorMessage = error.localizedDescription
            return nil
        }
    }
    
    func updateLocation(user: FindMeUser, isOn: Bool) async {
        guard userLatitude != 0.0,  userLongitude != 0.0 else { return }
        
        var updateUser = user
        updateUser.latitude = userLatitude
        updateUser.longitude = userLongitude
        updateUser.isOn = isOn
        print("BOOL", isOn)
        for userId in await FindMeViewModel.shared.myfriend {
            await FireBaseManager.sherad.updateLocationUser(user: updateUser)
            await FireBaseManager.sherad.updateLocationForMyFriend(id: userId.id, user: updateUser)
        }
    }
   
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.last {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.currentLocation = location.coordinate
                self.userLatitude = location.coordinate.latitude
                self.userLongitude = location.coordinate.longitude
                if self.isLocationSignificantlyChanged(newLocation: location.coordinate) {
                    self.lastKnownLocation = location.coordinate
                    Task {
                        if self.isButtonPressed {
                            await self.updateLocation(user: FindMeViewModel.shared.modelFindMeUser, isOn: true)
                            self.isSend = false
                        } else if !self.isSend {
                            self.isSend = true
                            await self.updateLocation(user: FindMeViewModel.shared.modelFindMeUser, isOn: false)
                        }
                    }
                }
            }
        }
    }
    
    private func isLocationSignificantlyChanged(newLocation: CLLocationCoordinate2D) -> Bool {
        guard let lastLocation = lastKnownLocation else { return true }
        let deltaLatitude = abs(newLocation.latitude - lastLocation.latitude)
        let deltaLongitude = abs(newLocation.longitude - lastLocation.longitude)
        return deltaLatitude > 0.0005 || deltaLongitude > 0.0005
    }
    
    func getDirections(from userLocation: CLLocationCoordinate2D, to friendLocation: CLLocationCoordinate2D) {
        let userPlacemark = MKPlacemark(coordinate: userLocation)
        let friendPlacemark = MKPlacemark(coordinate: friendLocation)
        
        let request = MKDirections.Request()
        request.source = MKMapItem(placemark: userPlacemark)
        request.destination = MKMapItem(placemark: friendPlacemark)
        request.transportType = .automobile
        
        let directions = MKDirections(request: request)
        
        directions.calculate { response, error in
            if let error = error {
                self.isShowAlert = true
                self.errorMessage = "Your friend is too far away from you and it is not possible to make a route you can see where he is on the map."
                print("Error calculating directions: \(error.localizedDescription)")
                self.stopUpdate()
                return
            }
            
            if let route = response?.routes.first {
                print("Distance: \(route.distance) meters")
                print("Estimated time: \(route.expectedTravelTime) seconds")
                
                DispatchQueue.main.async {
                    self.distance = String(format: "Distance: %.2f km", route.distance / 1000)
                    self.timeTo = String(format: "Time to: %.0f minute", route.expectedTravelTime / 60)
                    self.userRoute = route
                }
            }
        }
    }
    
    private func calculateRoute(request: MKDirections.Request) async throws -> MKRoute {
        try await withCheckedThrowingContinuation { continuation in
            let directions = MKDirections(request: request)
            directions.calculate { response, error in
                if let error = error {
                    self.isShowAlert = true
                    self.errorMessage = error.localizedDescription
                    continuation.resume(throwing: error)
                } else if let route = response?.routes.first {
                    continuation.resume(returning: route)
                } else {
                    continuation.resume(throwing: NSError(domain: "RouteError", code: 1, userInfo: [NSLocalizedDescriptionKey: "No route found"]))
                }
            }
        }
    }
    
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        self.authorizationStatus = status
    }
    
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        self.locationError = error
        isShowAlert = true
        errorMessage = "\(error)"
        print("Failed to find user's location: \(error.localizedDescription)")
    }
    
    func calculateDistance(to friendLocation: CLLocationCoordinate2D) -> CLLocationDistance? {
        guard let currentLocation = currentLocation else { return nil }
        let current = CLLocation(latitude: currentLocation.latitude, longitude: currentLocation.longitude)
        let friend = CLLocation(latitude: friendLocation.latitude, longitude: friendLocation.longitude)
        return current.distance(from: friend)
    }
}

extension CLLocationCoordinate2D: Equatable {
    public static func == (lhs: CLLocationCoordinate2D, rhs: CLLocationCoordinate2D) -> Bool {
        lhs.latitude == rhs.latitude && lhs.longitude == rhs.longitude
    }
}
