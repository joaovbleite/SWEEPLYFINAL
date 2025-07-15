//
//  DashboardMapView.swift
//  SWEEPLYPRO
//
//  Created on 7/12/25.
//

import SwiftUI
import MapKit
import CoreLocation

struct DashboardMapView: View {
    @StateObject private var locationManager = LocationManager()
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), // Default to San Francisco
        span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
    )
    @State private var showFullMap = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Section header with "View full map" link (with padding)
            HStack {
                Text("Today's Route")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(Color(hex: "#0A0A0A"))
                
                Spacer()
                
                Button(action: {
                    showFullMap = true
                }) {
                    HStack(spacing: 4) {
                        Text("View full map")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#246BFD"))
                        
                        Image(systemName: "chevron.right")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(Color(hex: "#246BFD"))
                    }
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
            
            // Map container (full width, no horizontal padding)
            ZStack(alignment: .topTrailing) {
                // Map view - Dashboard specific with zoom only
                DashboardMapViewRepresentable(region: $region, showsUserLocation: true)
                    .frame(height: 280)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Center on me button (top right)
                Button(action: centerOnUserLocation) {
                    Image(systemName: "location.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "#246BFD"))
                        .padding(10)
                        .background(Circle().fill(Color.white))
                        .shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
                }
                .padding(12)
            }
        }
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 2, x: 0, y: 1)
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
        .fullScreenCover(isPresented: $showFullMap) {
            AppointmentsMapView(appointments: [])
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

#Preview {
    DashboardMapView()
}

// Dashboard-specific UIViewRepresentable wrapper for MKMapView (zoom only, no panning)
struct DashboardMapViewRepresentable: UIViewRepresentable {
    @Binding var region: MKCoordinateRegion
    var showsUserLocation: Bool
    
    // Create the MKMapView
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = showsUserLocation
        mapView.region = region
        
        // Enable zoom only, disable panning and other gestures
        mapView.isZoomEnabled = true
        mapView.isScrollEnabled = false  // Disable panning
        mapView.isRotateEnabled = false  // Disable rotation
        mapView.isPitchEnabled = false   // Disable 3D tilt
        
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
        var parent: DashboardMapViewRepresentable
        private var isUserInteraction = false
        
        init(_ parent: DashboardMapViewRepresentable) {
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
        
        // Update the binding when the map is moved by user (zoom only)
        func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
            // Only update the binding if this is from user interaction, not from our own setRegion call
            if isUserInteraction {
                DispatchQueue.main.async {
                    // For dashboard map, only update the zoom level (span), keep the center fixed
                    var newRegion = self.parent.region
                    newRegion.span = mapView.region.span
                    self.parent.region = newRegion
                }
            }
            isUserInteraction = false
        }
    }
} 