//
//  SettingsViewModel.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    @Published var authUser: AuthDataResultModel? = nil
    
    func loadAuthUser() {
        self.authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
    }
    
    func loadAuthProviders() {
        if let providers = try? AuthenticationManager.shared.getProviders() {
            authProviders = providers
        }
        print(authProviders)
    }
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        let tempUser = try AuthenticationManager.shared.getAuthenticatedUser()
        
        guard let email = tempUser.email else {
            print("Can't Find User Email: \(URLError(.fileDoesNotExist))")
            return
        }
        try await AuthenticationManager.shared.resetPassword(email: email)
    }
    
    func updateEmail() async throws {
        let email = "hello123@gmail.com"
        try await AuthenticationManager.shared.updateEmail(email: email)
    }
    
    func updatePassword() async throws {
        let password = "hello123"
        try await AuthenticationManager.shared.updatePassword(password: password)
    }
    
    func linkGoogleAccount() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        
        authUser = try await AuthenticationManager.shared.linkGoogle(tokens: tokens)
    }
    
    func linkAppleAccount() async throws {
        let helper = SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        
        authUser = try await AuthenticationManager.shared.linkApple(token: tokens)
    }
    
    func linkEmailAccount() async throws {
        let email = "helloqw@gmail.com"
        let password = "Hello123"
        
        authUser = try await AuthenticationManager.shared.linkEmail(email: email, password: password)
    }
    
    func deleteUserAccount() async throws {
        try await AuthenticationManager.shared.deleteAccount()
    }
    
}
