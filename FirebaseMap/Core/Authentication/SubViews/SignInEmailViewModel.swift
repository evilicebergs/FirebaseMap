//
//  SignInEmailViewModel.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import Foundation

//final means that you can't inherit from it
@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email Or Password Found")
            return
        }
        
        let authDataResult = try await AuthenticationManager.shared.createUser(email: email, password: password)
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
    }
    
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email Or Password Found")
            return
        }
        
        try await AuthenticationManager.shared.signInUser(email: email, password: password)
    }
}
