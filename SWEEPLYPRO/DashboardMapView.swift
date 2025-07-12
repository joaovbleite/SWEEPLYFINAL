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
        VStack(alignment: .leading, spacing: 10) {
            // Section header with "View full map" link
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
            .padding(.horizontal, 8)
            
            // Map container
            ZStack(alignment: .bottomTrailing) {
                // Map view
                MapViewRepresentable(region: $region, showsUserLocation: true)
                    .frame(height: 180)
                    .cornerRadius(12)
                    .shadow(color: Color.black.opacity(0.1), radius: 4, x: 0, y: 2)
                
                // Center on me button
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
            .padding(.horizontal, 8)
        }
        .padding(.vertical, 8)
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal, 8)
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