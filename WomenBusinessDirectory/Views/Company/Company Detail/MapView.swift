//
//  MapView.swift
//  WomenBusinessDirectory
//
//  Created by Jamila Ruzimetova on 7/2/24.
//

import SwiftUI
import MapKit

struct MapView: View {
    let company: Company
    @Environment(\.colorScheme) private var colorScheme
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    @State private var annotation: CompanyAnnotation?

    var body: some View {
        VStack(alignment: .leading) {
            Map {
                if let annotation = annotation {
                    Marker(coordinate: annotation.coordinate) {
                        Image(systemName: "mappin.circle.fill")
                            .foregroundStyle(.red)
                    }
                }
            }
            .frame(height: 300)
            .cornerRadius(10)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(colorScheme == .dark ? Color.gray.opacity(0.3) : Color.clear, lineWidth: 1)
            )

            Text(formatFullAddress())
                .font(.subheadline)
                .foregroundColor(colorScheme == .dark ? .gray.opacity(0.9) : .gray)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
        .onAppear {
            geocodeAddress()
        }
    }

    private func formatFullAddress() -> String {
        return "\(company.address), \(company.city)"
    }

    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        let fullAddress = "\(company.address), \(company.city)"
        
        // Skip geocoding if address is empty
        guard !company.address.isEmpty else {
            print("Address is empty, skipping geocoding")
            return
        }
        
        geocoder.geocodeAddressString(fullAddress) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No location found for the address")
                return
            }
            
            // Check for invalid coordinates (NaN or extremely out of range)
            let coordinate = location.coordinate
            guard !coordinate.latitude.isNaN && !coordinate.longitude.isNaN,
                  coordinate.latitude >= -90 && coordinate.latitude <= 90,
                  coordinate.longitude >= -180 && coordinate.longitude <= 180 else {
                print("Invalid coordinates returned from geocoding")
                return
            }

            annotation = CompanyAnnotation(
                coordinate: coordinate,
                title: company.name,
                subtitle: formatFullAddress()
            )

            region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        }
    }
}

struct CompanyAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
}
