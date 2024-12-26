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
    
//    func signInApple() async throws {
//        let helper = await SignInAppleHelper()
//        let tokens = try await helper.startSignInWithAppleFlow()
//        let authDataResult = try await AuthenticationManager.shared.signInWithApple(tokens: tokens)
//        let user = DBUser(auth: authDataResult)
//        try await UserManager.shared.createNewUser(user: user)
//    }
    
}

struct ReauthView: View {
    
    @Environment(\.colorScheme) private var colorScheme
    
    @StateObject private var vm = ReAuthViewModel()
    
    @Binding var showReauthView: Bool
    @Binding var isReauthenticated: Bool
    
    var body: some View {
        VStack {
//            NavigationLink {
//                //SignInEmailView(showSignInView: $showSignInView)
//            } label: {
//                Text("Sign In With Email")
//                    .font(.headline)
//                    .foregroundStyle(.white)
//                    .frame(height: 55)
//                    .frame(maxWidth: .infinity)
//                    .background(.blue)
//                    .clipShape(.rect(cornerRadius: 10))
//            }
            
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
            
//            Button(action: {
//                Task {
//                    do {
//                        //try await vm.signInApple()
//                        //showSignInView = false
//                    } catch {
//                        print(error)
//                    }
//                }
//            }, label: {
//                SignInWithAppleButtonViewRepresentable(type: .default, style: colorScheme == .dark ? .white : .black)
//                    .allowsHitTesting(false)
//            })
//            .frame(height: 55)
            
            Spacer()
        }
        .padding()
        .navigationTitle("Reauthenticate")
    }
}

#Preview {
    NavigationStack {
        ReauthView(showReauthView: .constant(false), isReauthenticated: .constant(false))
    }
}
