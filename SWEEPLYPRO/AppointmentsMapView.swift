//
//  AppointmentsMapView.swift
//  SWEEPLYPRO
//
//  Created on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct AppointmentsMapView: View {
    // For now, we'll just accept an array of appointments but not use it
    // This will be implemented later
    let appointments: [Appointment]
    
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Using UIViewRepresentable for native MapKit behavior
            MapViewRepresentable(region: $region, showsUserLocation: true)
                .edgesIgnoringSafeArea(.all)
            
            // Center on me button
            VStack {
                HStack {
                    Spacer()
                    Button(action: centerOnUserLocation) {
                        Image(systemName: "location.fill")
                            .font(.system(size: 22))
                            .foregroundColor(Color(hex: "#246BFD"))
                            .padding(12)
                            .background(Circle().fill(Color.white))
                            .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                    }
                    .padding(.trailing, 16)
                    .padding(.top, 16)
                }
                Spacer()
            }
        }
        .onAppear {
            // Center map on user's location when available
            if let location = locationManager.location {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        }
        .onChange(of: locationManager.location) { newLocation in
            // Update region when location changes, but only on first location update
            if let location = newLocation, locationManager.initialLocationSet == false {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
                locationManager.initialLocationSet = true
            }
        }
    }
    
    private func centerOnUserLocation() {
        if let location = locationManager.location {
            withAnimation {
                region = MKCoordinateRegion(
                    center: location.coordinate,
                    span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
                )
            }
        } else {
            // If location is not available, request permission
            locationManager.requestLocationPermission()
        }
    }
}

// UIViewRepresentable wrapper for MKMapView
struct MapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var showsUserLocation: Bool
    
    // Create the MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.region = region
        
        // Enable all standard gestures
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = true
        mapView.isRotateEnabled = true
        mapView.isPitchEnabled = true
        
        return mapView
    }
    
    // Update the view when SwiftUI state changes
    func updateUIView(_ view: MKMapView, context: Context) {
        // Only update region if it's significantly different to avoid interrupting user interactions
        if shouldUpdateRegion(view.region, newRegion: region) {
            view.setRegion(region, animated: true)
        }
    }
    
    // Determine if we should update the region
    private func shouldUpdateRegion(_ currentRegion: MKCoordinateRegion, newRegion: MKCoordinateRegion) -> Bool {
        // Calculate distance between centers
        let currentCenter = CLLocation(latitude: currentRegion.center.latitude, longitude: currentRegion.center.longitude)
        let newCenter = CLLocation(latitude: newRegion.center.latitude, longitude: newRegion.center.longitude)
        let distance = currentCenter.distance(from: newCenter)
        
        // Calculate span difference
        let spanDifference = abs(currentRegion.span.latitudeDelta - newRegion.span.latitudeDelta) + 
                            abs(currentRegion.span.longitudeDelta - newRegion.span.longitudeDelta)
        
        // Update if significant change
        return distance > 50 || spanDifference > 0.01
    }
    
    // Create coordinator to handle delegate methods
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    // Coordinator class for delegate callbacks
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapViewRepresentable
        private var isUserInteraction = false
        
        init(_ parent: MapViewRepresentable) {
            self.parent = parent
        }
        
        // Called when user begins interaction with the map
        func mapViewWillStartLocatingUser(_ mapView: MKMapView) {
            isUserInteraction = true
        }
        
        // Called when region will change
        func mapView(_ mapView: MKMapView, regionWillChangeAnimated animated: Bool) {
            isUserInteraction = !animated // If not animated, likely user interaction
        }
        
        // Update the binding when the map is moved by user
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Only update the binding if this is from user interaction, not from our own setRegion call
            if isUserInteraction {
                DispatchQueue.main.async {
                    self.parent.region = mapView.region
                }
            }
            isUserInteraction = false
        }
    }
}

// Preview with sample data
#Preview {
    AppointmentsMapView(appointments: [
        Appointment(
            title: "Window Cleaning",
            clientName: "John Smith",
            location: "123 Main St, San Francisco, CA",
            startTime: "7 PM",
            endTime: "8 PM",
            date: 6,
            color: "#246BFD"
        )
    ])
} 