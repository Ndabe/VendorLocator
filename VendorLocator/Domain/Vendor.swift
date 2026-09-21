//
//  Vendor.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation

nonisolated struct Vendor: Identifiable, Codable, Equatable, Sendable {
    let id: String
    let name: String
    let address: String
    let coordinate: Coordinate
    var isFavorite: Bool
    let updatedAt: Date
}

nonisolated struct Coordinate: Codable, Equatable, Sendable {
    let latitude: Double
    let longitude: Double
    
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }
}
