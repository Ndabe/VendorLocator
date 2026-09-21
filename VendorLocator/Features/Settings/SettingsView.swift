//
//  SettingsView.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import SwiftUI

struct SettingsView: View {
    @State private var viewModel = SettingsViewModel(tokenStore: KeychainTokenStore())
    
    var body: some View {
        Form {
            Section("Session Token") {
                Group {
                    if viewModel.isTokenVisible {
                        TextField("Session token", text: $viewModel.token)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("Session token", text: $viewModel.token)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                    }
                }
                
                Toggle("Show token", isOn: $viewModel.isTokenVisible)
                
                Button("Save Token") {
                    viewModel.saveToken()
                }
                .disabled(viewModel.token.isEmpty)
                
                Button("Clear Token", role: .destructive) {
                    viewModel.clearToken()
                }
                .disabled(viewModel.token.isEmpty)
            }
            
            if let message = viewModel.message {
                Section {
                    Text(message)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .navigationTitle("Settings")
        .onAppear {
            viewModel.loadToken()
        }
    }
}
