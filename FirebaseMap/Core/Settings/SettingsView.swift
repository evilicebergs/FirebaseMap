//
//  SettingsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-25.
//

import SwiftUI

struct SettingsView: View {
    
    @StateObject private var vm = SettingsViewModel()
    
    @Binding var showSignInView: Bool
    
    @State private var showAlert: Bool = false
    @State var showReauthView: Bool = false
    
    @State var isReauthenticated: Bool = false
    
    var body: some View {
        List {
            Button {
                do {
                    if isReauthenticated {
                        try vm.logOut()
                        showSignInView = true
                    } else {
                        showAlert = true
                    }
                } catch {
                    print(error)
                }
            } label: {
                Text("Log Out")
            }
            .alert(vm.authUser?.isAnonymous ?? true ? "You will lose your account data. To avoid accidental deletion link your account to provider." : "You should reauthenticate your account", isPresented: $showAlert) {
                if vm.authUser?.isAnonymous == true {
                    Button {
                        Task {
                            try? await vm.deleteUserAccount()
                            showSignInView = true
                        }
                    } label: {
                        Text("Delete anyway")
                    }
                } else {
                    Button {
                        showReauthView = true
                    } label: {
                        Text("Reauthenticate")
                    }
                }
                
                Button(role: .cancel) { } label: {
                    Text("Cancel")
                }
            }
            .fullScreenCover(isPresented: $showReauthView) {
                ReauthView(showReauthView: $showReauthView, isReauthenticated: $isReauthenticated, providers: vm.authProviders)
            }
            
            Button(role: .destructive, action: {
                Task {
                    do {
                        if isReauthenticated {
                            try await vm.deleteUserAccount()
                            showSignInView = true
                        } else {
                            showAlert = true
                        }
                    } catch {
                        print(error)
                    }
                }
            }, label: {
                Text("Delete Account")
            })
            
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

