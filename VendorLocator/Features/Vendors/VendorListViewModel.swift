//
//  VendorListViewModel.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation
import Observation

@MainActor
@Observable
final class VendorListViewModel {
    enum LoadState: Equatable {
        case idle
        case loading
        case loaded
        case failed(String)
    }
    
    private let loader: any VendorLoading
    
    private(set) var vendors: [Vendor] = []
    private(set) var loadState: LoadState = .idle
    var selectedVendor: Vendor?
    
    init(loader: any VendorLoading) {
        self.loader = loader
    }
    
    func loadVendors() async {
        guard loadState != .loading else { return }
        
        loadState = .loading
        
        do {
            vendors = try await loader.loadVendors()
            loadState = .loaded
        } catch {
            loadState = .failed(error.localizedDescription)
        }
    }
    
    func toggleFavorite(for vendor: Vendor) {
        guard let index = vendors.firstIndex(where: { $0.id == vendor.id }) else {
            return
        }
        
        vendors[index].isFavorite.toggle()
    }
    
    func select(_ vendor: Vendor) {
        selectedVendor = vendor
    }
    
    func add(_ vendor: Vendor) {
        guard !vendors.contains(where: { $0.id == vendor.id }) else {
            select(vendor)
            return
        }
        
        vendors.append(vendor)
        select(vendor)
    }
}
