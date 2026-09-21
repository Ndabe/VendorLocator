//
//  VendorDecodingTests.swift
//  VendorLocatorTests
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import XCTest
@testable import VendorLocator

final class VendorDecodingTests: XCTestCase {
    func testDecodesVendorWithCoordinateAndISO8601Date() throws {
        let json = """
        {
          "id": "ven-001",
          "name": "Mr D Pizza - Cape Town CBD",
          "address": "12 Loop St, Cape Town, 8000",
          "coordinate": {
            "lat": -33.918861,
            "lng": 18.423300
          },
          "isFavorite": false,
          "updatedAt": "2025-06-01T12:00:00Z"
        }
        """
        
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        let vendor = try decoder.decode(Vendor.self, from: Data(json.utf8))
        
        XCTAssertEqual(vendor.id, "ven-001")
        XCTAssertEqual(vendor.coordinate.latitude, -33.918861)
        XCTAssertEqual(vendor.coordinate.longitude, 18.423300)
        XCTAssertFalse(vendor.isFavorite)
        XCTAssertEqual(
            vendor.updatedAt,
            ISO8601DateFormatter().date(from: "2025-06-01T12:00:00Z")
        )
    }
}
