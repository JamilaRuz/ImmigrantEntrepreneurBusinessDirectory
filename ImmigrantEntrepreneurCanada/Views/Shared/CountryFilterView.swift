//
//  CountryFilterView.swift
//  ImmigrantEntrepreneurCanada
//
//  Created by Jamila Ruzimetova on 10/6/24.
//

import SwiftUI

struct CountryFilterView: View {
    @Binding var selectedCountry: String?
    let availableCountries: [String]
    @Environment(\.dismiss) private var dismiss
    @State private var searchText = ""
    
    var filteredCountries: [String] {
        if searchText.isEmpty {
            return availableCountries
        } else {
            return availableCountries.filter { $0.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        NavigationView {
            VStack {
                // Search bar
                TextField("Search countries", text: $searchText)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal)
                    .padding(.top)
                
                if availableCountries.isEmpty {
                    VStack(spacing: 20) {
                        Image(systemName: "globe")
                            .font(.system(size: 50))
                            .foregroundColor(.orange1)
                        
                        Text("No countries available")
                            .font(.headline)
                        
                        Text("No entrepreneurs have added their country of origin yet")
                            .font(.subheadline)
                            .multilineTextAlignment(.center)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    // Country list
                    List {
                        // Option to clear selection
                        Button(action: {
                            selectedCountry = nil
                            dismiss()
                        }) {
                            HStack {
                                Text("Show All Countries")
                                    .foregroundColor(.orange1)
                                Spacer()
                                if selectedCountry == nil {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(.orange1)
                                }
                            }
                        }
                        
                        // List of countries
                        ForEach(filteredCountries, id: \.self) { country in
                            Button(action: {
                                selectedCountry = country
                                dismiss()
                            }) {
                                HStack {
                                    Text(country)
                                    Spacer()
                                    if selectedCountry == country {
                                        Image(systemName: "checkmark")
                                            .foregroundColor(.orange1)
                                    }
                                }
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Filter by Country")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

#Preview {
    CountryFilterView(
        selectedCountry: .constant("United States"),
        availableCountries: ["Mexico", "United States", "Canada"]
    )
} 