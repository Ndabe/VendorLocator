//
//  VendorLoading.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation

protocol VendorLoading {
    func loadVendors() async throws -> [Vendor]
}

enum VendorLoadingError: LocalizedError {
    case missingResource
    case invalidData
    case requestFailed
    case unsuccessfulResponse(Int)
    
    var errorDescription: String? {
        switch self {
        case .missingResource:
            "Vendor data could not be found."
        case .invalidData:
            "Vendor data could not be read."
        case .requestFailed:
            "Vendors could not be loaded. Please try again."
        case .unsuccessfulResponse:
            "The vendor service could not complete the request."
        }
    }
}

struct LocalVendorLoader: VendorLoading {
    func loadVendors() async throws -> [Vendor] {
        guard let url = Bundle.main.url(
            forResource: "vendors",
            withExtension: "json"
        ) else {
            throw VendorLoadingError.missingResource
        }
        
        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Vendor].self, from: data)
        } catch {
            throw VendorLoadingError.invalidData
        }
    }
}

struct URLSessionVendorLoader: VendorLoading {
    let endpoint: URL
    let tokenStore: any TokenStoring
    private let session: URLSession
    
    init(
        endpoint: URL,
        tokenStore: any TokenStoring,
        session: URLSession = .shared
    ) {
        self.endpoint = endpoint
        self.tokenStore = tokenStore
        self.session = session
    }
    
    func loadVendors() async throws -> [Vendor] {
        var request = URLRequest(url: endpoint)
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        if let token = try tokenStore.readToken(), !token.isEmpty {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw VendorLoadingError.requestFailed
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw VendorLoadingError.requestFailed
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw VendorLoadingError.unsuccessfulResponse(httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode([Vendor].self, from: data)
        } catch is DecodingError {
            throw VendorLoadingError.invalidData
        }
    }
}
