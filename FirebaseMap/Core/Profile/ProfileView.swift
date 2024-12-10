//
//  ProfileView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthenticationManager.shared.getAuthenticatedUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
    }
    
    func togglePremiumStatus() async {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        try? await UserManager.shared.updateUserPremiumStatus(isPremium: !currentValue, userId: user.userId)
        self.user = try? await UserManager.shared.getUser(userId: user.userId)
    }
    
}

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        List {
            if let user = vm.user {
                Text("UserId: \(user.userId)")
                Text("\(user.name ?? "No name")")
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                    Task {
                        await vm.togglePremiumStatus()
                    }
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }

                
            }
        }
        .onAppear {
            Task {
                try? await vm.loadCurrentUser()
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }

            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
