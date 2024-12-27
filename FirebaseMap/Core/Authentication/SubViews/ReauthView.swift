//
//  ReauthView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-26.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

final class ReAuthViewModel: ObservableObject {
    
    func reAuthGoogle() async throws {
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        try await AuthenticationManager.shared.reAuthUserWithGoogle(tokens: tokens)
    }
    
    func reauthEmail(email: String, password: String) async throws {
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
    
    func reAuthApple() async throws {
        let helper = await SignInAppleHelper()
        let tokens = try await helper.startSignInWithAppleFlow()
        try await AuthenticationManager.shared.reAuthUserWithApple(tokens: tokens)
    }
    
}

struct ReauthView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var vm = ReAuthViewModel()
    
    @Binding var showReauthView: Bool
    @Binding var isReauthenticated: Bool
    
    @State private var showAlertEmail: Bool = false
    
    @State private var textPass: String = ""
    @State private var textEmail: String = ""
    
    let providers: [AuthProviderOption]
    
    var body: some View {
        VStack {
            Text("Choose Your Provider")
                .font(.title2)
            if providers.contains(.email) {
                Button {
                    showAlertEmail = true
                } label: {
                    Text("Reauthenticate With Email")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(height: 55)
                        .frame(maxWidth: .infinity)
                        .background(.blue)
                        .clipShape(.rect(cornerRadius: 10))
                }
                .alert("Enter Your Email and Password", isPresented: $showAlertEmail) {
                    TextField("Email...", text: $textEmail)
                        .keyboardType(.emailAddress)
                    TextField("Password...", text: $textPass)
                        .textContentType(.password)
                    Button("Verify") {
                        Task {
                            try? await vm.reauthEmail(email: textEmail, password: textPass)
                            textPass = ""
                            textEmail = ""
                            isReauthenticated = true
                            showReauthView = false
                        }
                    }
                    
                    Button(role: .cancel) { } label: {
                        Text("Cancel")
                    }
                }
            }
            
            if providers.contains(.google) {
                GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                    Task {
                        do {
                            try await vm.reAuthGoogle()
                            isReauthenticated = true
                            showReauthView = false
                        } catch {
                            print(error)
                        }
                    }
                }
            }
            
            if providers.contains(.apple) {
                Button(action: {
                    Task {
                        do {
                            try await vm.reAuthApple()
                            isReauthenticated = true
                            showReauthView = false
                        } catch {
                            print(error)
                        }
                    }
                }, label: {
                    SignInWithAppleButtonViewRepresentable(type: .default, style: colorScheme == .dark ? .white : .black)
                        .allowsHitTesting(false)
                })
                .frame(height: 55)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Reauthenticate")
    }
}

#Preview {
    NavigationStack {
        ReauthView(showReauthView: .constant(false), isReauthenticated: .constant(false), providers: [.google])
    }
}
