//
//  PlaceSearchViewModel.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation
import Observation

@MainActor
@Observable
final class PlaceSearchViewModel {
    private let service: any PlaceSearching
    
    private(set) var suggestions: [PlaceSuggestion] = []
    private(set) var isSearching = false
    private(set) var errorMessage: String?
    
    init(service: any PlaceSearching) {
        self.service = service
    }
    
    func search(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            suggestions = []
            errorMessage = nil
            return
        }
        
        isSearching = true
        errorMessage = nil
        
        do {
            suggestions = try await service.search(query: query)
        } catch {
            suggestions = []
            errorMessage = error.localizedDescription
        }
        
        isSearching = false
    }
    
    func vendor(for suggestion: PlaceSuggestion) async -> Vendor? {
        do {
            return try await service.vendor(for: suggestion)
        } catch {
            errorMessage = error.localizedDescription
            return nil
        }
    }
}
