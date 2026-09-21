//
//  VendorMapView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

struct VendorMapView: View {
    @Bindable var viewModel: VendorListViewModel
    @State private var isShowingPlaceSearch = false
    
    var body: some View {
        GoogleMapView(
            vendors: viewModel.vendors,
            selectedVendor: viewModel.selectedVendor,
            onVendorSelected: viewModel.select
        )
        .ignoresSafeArea(edges: .bottom)
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            Button {
                isShowingPlaceSearch = true
            } label: {
                Image(systemName: "plus")
            }
            .accessibilityLabel("Add vendor from place search")
        }
        .sheet(isPresented: $isShowingPlaceSearch) {
            NavigationStack {
                PlaceSearchView(vendorViewModel: viewModel)
            }
        }
    }
}
