//
//  VendorListView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

struct VendorListView: View {
    @Bindable var viewModel: VendorListViewModel
    @Binding var selectedTab: AppTab
    
    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle:
                ProgressView("Loading vendors...")
                
            case .loading where viewModel.vendors.isEmpty:
                ProgressView("Loading vendors...")
                
            case .failed(let message) where viewModel.vendors.isEmpty:
                ContentUnavailableView {
                    Label("Unable to Load Vendors", systemImage: "exclamationmark.triangle")
                } description: {
                    Text(message)
                } actions: {
                    Button("Try Again") {
                        Task {
                            await viewModel.loadVendors()
                        }
                    }
                }
                
            default:
                List(viewModel.vendors) { vendor in
                    HStack(spacing: 0) {
                        Button {
                            viewModel.select(vendor)
                            selectedTab = .map
                        } label: {
                            HStack(spacing: 12) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(vendor.name)
                                        .font(.headline)
                                    Text(vendor.address)
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                }
                                
                                Spacer()
                            }
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        
                        Button {
                            viewModel.toggleFavorite(for: vendor)
                        } label: {
                            Image(systemName: vendor.isFavorite ? "heart.fill" : "heart")
                                .foregroundStyle(vendor.isFavorite ? .red : .secondary)
                        }
                        .accessibilityLabel(
                            vendor.isFavorite
                            ? "Remove \(vendor.name) from favourites"
                            : "Add \(vendor.name) to favourites"
                        )
                        .frame(width: 52, height: 52)
                    }
                    .padding(.vertical, 4)
                }
                .refreshable {
                    await viewModel.loadVendors()
                }
                .overlay {
                    if viewModel.loadState == .loading {
                        ProgressView()
                    }
                }
                .overlay(alignment: .top) {
                    if case .failed(let message) = viewModel.loadState,
                       !viewModel.vendors.isEmpty {
                        HStack(spacing: 12) {
                            Label(message, systemImage: "exclamationmark.triangle")
                                .font(.subheadline)
                                .multilineTextAlignment(.leading)
                            
                            Spacer()
                            
                            Button("Retry") {
                                Task {
                                    await viewModel.loadVendors()
                                }
                            }
                            .buttonStyle(.bordered)
                        }
                        .padding()
                        .background(.regularMaterial)
                    }
                }
            }
        }
        .navigationTitle("Vendors")
        .task {
            await viewModel.loadVendors()
        }
    }
}

#Preview {
    @Previewable @State var selectedTab = AppTab.vendors
    VendorListView(
        viewModel: VendorListViewModel(loader: LocalVendorLoader()),
        selectedTab: $selectedTab
    )
}
