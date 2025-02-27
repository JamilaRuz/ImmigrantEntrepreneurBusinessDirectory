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

            Text(company.address)
                .font(.subheadline)
                .multilineTextAlignment(.leading)
                .padding(.horizontal)
        }
        .onAppear {
            geocodeAddress()
        }
    }

    private func geocodeAddress() {
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(company.address) { placemarks, error in
            if let error = error {
                print("Geocoding error: \(error.localizedDescription)")
                return
            }

            guard let placemark = placemarks?.first,
                  let location = placemark.location else {
                print("No location found for the address")
                return
            }

            annotation = CompanyAnnotation(
                coordinate: location.coordinate,
                title: company.name,
                subtitle: company.address
            )

            region = MKCoordinateRegion(
                center: location.coordinate,
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
