//
//  SettingsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-25.
//

import SwiftUI

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
    
}

struct SettingsView: View {
    
    @StateObject private var vm = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            Button {
                do {
                    try vm.logOut()
                    showSignInView = true
                } catch {
                    print(error)
                }
            } label: {
                Text("Log Out")
            }
            if vm.authProviders.contains(.email) {
                emailSection
            }
            
            if vm.authUser?.isAnonymous == true {
                anonymousSection
            }
        }
        .onAppear(perform: {
            vm.loadAuthProviders()
            vm.loadAuthUser()
        })
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}

extension SettingsView {
    private var emailSection: some View {
        Section {
            Button {
                Task {
                    do {
                        try await vm.resetPassword()
                        print("Password Reset!")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Reset Password")
            }
            
            Button {
                Task {
                    do {
                        try await vm.updatePassword()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Password")
            }
            
            Button {
                Task {
                    do {
                        try await vm.updateEmail()
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Update Email")
            }
        } header: {
            Text("Email Functions")
        }
    }
}

extension SettingsView {
    private var anonymousSection: some View {
        Section {
            
            Button {
                Task {
                    do {
                        try await vm.linkGoogleAccount()
                        print("google linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Google Account")
            }
            
            Button {
                Task {
                    do {
                        try await vm.linkAppleAccount()
                        print("apple linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Apple Account")
            }
            
            Button {
                Task {
                    do {
                        try await vm.linkEmailAccount()
                        print("email linked")
                    } catch {
                        print(error)
                    }
                }
            } label: {
                Text("Link Email Account")
            }

            
        } header: {
            Text("Create Account")
        }
    }
}
