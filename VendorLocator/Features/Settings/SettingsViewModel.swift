//
//  SettingsViewModel.swift
//  VendorLocator
//
//  Created by Ndabenhle Langa on 2026/09/20.
//

import Foundation
import Observation

@MainActor
@Observable
final class SettingsViewModel {
    private let tokenStore: any TokenStoring
    
    var token = ""
    var isTokenVisible = false
    var message: String?
    
    init(tokenStore: any TokenStoring) {
        self.tokenStore = tokenStore
    }
    
    func loadToken() {
        do {
            token = try tokenStore.readToken() ?? ""
        } catch {
            message = error.localizedDescription
        }
    }
    
    func saveToken() {
        do {
            try tokenStore.save(token: token)
            message = "Session token saved securely."
        } catch {
            message = error.localizedDescription
        }
    }
    
    func clearToken() {
        do {
            try tokenStore.clearToken()
            token = ""
            isTokenVisible = false
            message = "Session token cleared."
        } catch {
            message = error.localizedDescription
        }
    }
}
