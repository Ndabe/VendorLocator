//
//  PlaceSearchView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

struct PlaceSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @Bindable var vendorViewModel: VendorListViewModel
    @State private var searchViewModel = PlaceSearchViewModel(service: GooglePlacesService())
    @State private var query = ""
    
    var body: some View {
        List {
            if searchViewModel.isSearching {
                HStack {
                    Spacer()
                    ProgressView()
                    Spacer()
                }
            }
            
            if let errorMessage = searchViewModel.errorMessage {
                ContentUnavailableView {
                    Label("Place Search Unavailable", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(errorMessage)
                }
            }
            
            ForEach(searchViewModel.suggestions) { suggestion in
                Button {
                    Task {
                        guard let vendor = await searchViewModel.vendor(for: suggestion) else {
                            return
                        }
                        vendorViewModel.add(vendor)
                        dismiss()
                    }
                } label: {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(suggestion.name)
                            .foregroundStyle(.primary)
                        if let address = suggestion.address {
                            Text(address)
                                .font(.subheadline)
                                .foregroundStyle(.secondary)
                        }
                    }
                }
            }
        }
        .navigationTitle("Add Vendor")
        .searchable(text: $query, prompt: "Search for a place")
        .onChange(of: query) { _, newValue in
            Task {
                await searchViewModel.search(query: newValue)
            }
        }
    }
}
