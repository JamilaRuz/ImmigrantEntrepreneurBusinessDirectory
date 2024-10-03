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
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    @State private var annotations: [CompanyAnnotation] = []

    var body: some View {
      VStack {
        Map(coordinateRegion: $region, annotationItems: annotations) { annotation in
          MapMarker(coordinate: annotation.coordinate, tint: .red)
        }
        .onAppear {
          geocodeAddress()
        }
      }
      .frame(maxWidth: .infinity, maxHeight: .infinity)
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

            let annotation = CompanyAnnotation(
                coordinate: location.coordinate,
                title: company.name,
                subtitle: company.address
            )

            region = MKCoordinateRegion(
                center: location.coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
            )
            annotations = [annotation]
        }
    }
}

struct CompanyAnnotation: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
}

#Preview {
    MapView(company: createStubCompanies()[0])
}
