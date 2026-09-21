//
//  PlaceSearching.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation
import GooglePlaces

struct PlaceSuggestion: Identifiable, Equatable {
    let id: String
    let name: String
    let address: String?
}

enum PlaceSearchError: LocalizedError {
    case missingPlaceDetails
    
    var errorDescription: String? {
        switch self {
        case .missingPlaceDetails:
            "That place does not include the details needed to add it as a vendor."
        }
    }
}

@MainActor
protocol PlaceSearching {
    func search(query: String) async throws -> [PlaceSuggestion]
    func vendor(for suggestion: PlaceSuggestion) async throws -> Vendor
}

@MainActor
final class GooglePlacesService: PlaceSearching {
    func search(query: String) async throws -> [PlaceSuggestion] {
        let request = GMSAutocompleteRequest(query: query)
        
        return try await withCheckedThrowingContinuation { continuation in
            GMSPlacesClient.shared().fetchAutocompleteSuggestions(from: request) {
                suggestions,
                error in
                if let error {
                    continuation.resume(throwing: error)
                    return
                }
                
                let results = (suggestions ?? []).compactMap { suggestion -> PlaceSuggestion? in
                    guard let place = suggestion.placeSuggestion else { return nil }
                    
                    return PlaceSuggestion(
                        id: place.placeID,
                        name: place.attributedPrimaryText.string,
                        address: place.attributedSecondaryText?.string
                    )
                }
                continuation.resume(returning: results)
            }
        }
    }
    
    func vendor(for suggestion: PlaceSuggestion) async throws -> Vendor {
        let placeProperties: [String] = [
            GMSPlaceProperty.name.rawValue,
            GMSPlaceProperty.formattedAddress.rawValue,
            GMSPlaceProperty.coordinate.rawValue
        ]
        let request = GMSFetchPlaceRequest(
            placeID: suggestion.id,
            placeProperties: placeProperties,
            sessionToken: nil
        )
        
        let place: GMSPlace = try await withCheckedThrowingContinuation {
            (continuation: CheckedContinuation<GMSPlace, Error>) in
            GMSPlacesClient.shared().fetchPlace(with: request) { place, error in
                if let error {
                    continuation.resume(throwing: error)
                } else if let place {
                    continuation.resume(returning: place)
                } else {
                    continuation.resume(throwing: PlaceSearchError.missingPlaceDetails)
                }
            }
        }
        
        return Vendor(
            id: suggestion.id,
            name: place.name ?? suggestion.name,
            address: place.formattedAddress ?? suggestion.address ?? "Address unavailable",
            coordinate: Coordinate(
                latitude: place.coordinate.latitude,
                longitude: place.coordinate.longitude
            ),
            isFavorite: false,
            updatedAt: Date()
        )
    }
}
