//
//  VendorLocatorApp.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

@main
struct VendorLocatorApp: App {
    private let dependencies = AppDependencies()
    
    init() {
        GoogleSDKConfiguration.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView(dependencies: dependencies)
        }
    }
}
