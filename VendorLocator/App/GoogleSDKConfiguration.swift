//
//  GoogleSDKConfiguration.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import GoogleMaps
import GooglePlaces

enum GoogleSDKConfiguration {
    static func configure() {
        guard let apiKey = Bundle.main.object(
            forInfoDictionaryKey: "GoogleAPIKey"
        ) as? String, !apiKey.isEmpty else {
            return
        }
        
        GMSServices.provideAPIKey(apiKey)
        GMSPlacesClient.provideAPIKey(apiKey)
    }
}
