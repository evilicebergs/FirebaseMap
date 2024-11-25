//
//  SignInEmailView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-25.
//

import SwiftUI

//final means that you can't inherit from it
@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signIn() {
        guard !email.isEmpty, !password.isEmpty else {
            print("No Email Or Password Found")
            return
        }
        Task {
            do {
                let userData = try await AuthenticationManager.shared.createUser(email: email, password: password)
                print(userData)
            } catch {
                print("Error: \(error)")
            }
        }
    }
}

struct SignInEmailView: View {
    @StateObject private var vm = SignInEmailViewModel()
    
    var body: some View {
        VStack(alignment: .leading) {
            
            Text("Enter Your Email:")
                .font(.title2)
            TextField("Email...", text: $vm.email)
                .padding()
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 10))
            
            Text("Enter Your Password:")
                .font(.title2)
                .padding(.top, 10)
            SecureField("Password...", text: $vm.password)
                .padding()
                .background(.gray.opacity(0.4))
                .clipShape(.rect(cornerRadius: 10))
            Button {
                vm.signIn()
            } label: {
                Text("Sign In With Email")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .clipShape(.rect(cornerRadius: 15))
                    .padding(.top, 15)
            }
            Spacer()
        }
        .padding()
        .navigationTitle("Sign In With Email")
    }
}

#Preview {
    NavigationStack {
        SignInEmailView()
    }
}
