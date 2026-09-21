//
//  AppDependencies.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/21.
//

import Foundation

struct AppDependencies {
    let vendorLoader: any VendorLoading
    
    init(bundle: Bundle = .main) {
        if let endpointString = bundle.object(
            forInfoDictionaryKey: "VendorAPIEndpoint"
        ) as? String,
           let endpoint = URL(string: endpointString),
           endpoint.scheme != nil {
            vendorLoader = URLSessionVendorLoader(
                endpoint: endpoint,
                tokenStore: KeychainTokenStore()
            )
        } else {
            vendorLoader = LocalVendorLoader()
        }
    }
}
