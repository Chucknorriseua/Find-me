//
//  MapView.swift
//  Find me
//
//  Created by Евгений Полтавец on 27/12/2024.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    var userLocation: CLLocationCoordinate2D
    var friendLocation: CLLocationCoordinate2D
    var route: MKRoute?
    @Binding var zoomFriend: Bool

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.showsUserLocation = true
        mapView.delegate = context.coordinator
        return mapView
    }

    func updateUIView(_ uiView: MKMapView, context: Context) {
        uiView.removeOverlays(uiView.overlays)
      
        let userCLLocation = CLLocation(latitude: userLocation.latitude, longitude: userLocation.longitude)
        let friendCLLocation = CLLocation(latitude: friendLocation.latitude, longitude: friendLocation.longitude)

        let distance = userCLLocation.distance(from: friendCLLocation)

        let region: MKCoordinateRegion
        if distance > 50000 {
            region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 50000, longitudinalMeters: 50000)
        } else {
            region = MKCoordinateRegion(center: userLocation, latitudinalMeters: 1000, longitudinalMeters: 1000)
        }

        uiView.setRegion(region, animated: true)

        let friendAnnotation = MKPointAnnotation()
        friendAnnotation.coordinate = friendLocation
        friendAnnotation.title = "Friend"
        uiView.addAnnotation(friendAnnotation)

        if let route = route {
            uiView.addOverlay(route.polyline)
        }

        if zoomFriend {
            fitMapToUserAndFriend(mapView: uiView, userLocation: userLocation, friendLocation: friendLocation)
            DispatchQueue.main.async {
                zoomFriend = true
            }
        }
    }
    
    func fitMapToUserAndFriend(mapView: MKMapView, userLocation: CLLocationCoordinate2D, friendLocation: CLLocationCoordinate2D) {
        let userPoint = MKMapPoint(userLocation)
        let friendPoint = MKMapPoint(friendLocation)

        let userRect = MKMapRect(origin: userPoint, size: MKMapSize(width: 0, height: 0))
        let friendRect = MKMapRect(origin: friendPoint, size: MKMapSize(width: 0, height: 0))

        let mapRect = userRect.union(friendRect)
        let edgePadding = UIEdgeInsets(top: 50, left: 50, bottom: 50, right: 50)

        DispatchQueue.main.async {
            mapView.setVisibleMapRect(mapRect, edgePadding: edgePadding, animated: true)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView

        init(_ parent: MapView) {
            self.parent = parent
        }

        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if let polyline = overlay as? MKPolyline {
                let renderer = MKPolylineRenderer(polyline: polyline)
                renderer.strokeColor = .blue
                renderer.lineWidth = 3.0
                return renderer
            }
            return MKOverlayRenderer(overlay: overlay)
        }
    }
}
