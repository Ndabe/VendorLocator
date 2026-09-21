//
//  ContentView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

enum AppTab: Hashable {
    case vendors
    case map
    case settings
}

struct ContentView: View {
    @State private var selectedTab = AppTab.vendors
    @State private var vendorViewModel: VendorListViewModel

    init(dependencies: AppDependencies = AppDependencies()) {
        _vendorViewModel = State(
            initialValue: VendorListViewModel(loader: dependencies.vendorLoader)
        )
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            NavigationStack {
                VendorListView(
                    viewModel: vendorViewModel,
                    selectedTab: $selectedTab
                )
            }
            .tabItem {
                Label("Vendors", systemImage: "storefront")
            }
            .tag(AppTab.vendors)

            NavigationStack {
                VendorMapView(viewModel: vendorViewModel)
            }
            .tabItem {
                Label("Map", systemImage: "map")
            }
            .tag(AppTab.map)

            NavigationStack {
                SettingsView()
            }
            .tabItem {
                Label("Settings", systemImage: "gear")
            }
            .tag(AppTab.settings)
        }
    }
}

#Preview {
    ContentView()
}
