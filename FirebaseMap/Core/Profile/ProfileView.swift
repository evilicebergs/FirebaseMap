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
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        Task {
            try await UserManager.shared.updateUserPremiumStatus(isPremium: !currentValue, userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addUserPreference(text: String) {
        guard let user else { return }
        Task {
            try await UserManager.shared.addUserPreference(userId: user.userId, preference: text)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func addFavouriteMovie() {
        guard let user else { return }
        let movie = Movie(id: "1", title: "Avatar 2", isPopular: true)
        Task {
            try await UserManager.shared.addFavouriteMovie(userId: user.userId, movie: movie)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    func removeFavouriteMovie() {
        guard let user else { return }
        Task {
            try await UserManager.shared.removeFavouriteMovie(userId: user.userId)
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
}

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(option: String) -> Bool {
        vm.user?.preferences?.contains(option) == true
    }
    
    var body: some View {
        List {
            if let user = vm.user {
                Text("UserId: \(user.userId)")
                Text("\(user.name ?? "No name")")
                if let isAnonymous = user.isAnonymous {
                    Text("Is Anonymous: \(isAnonymous.description.capitalized)")
                }
                
                Button {
                        vm.togglePremiumStatus()
                } label: {
                    Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                }
                VStack {
                    HStack {
                        ForEach(preferenceOptions, id: \.self) { option in
                            Button {
                                if preferenceIsSelected(option: option) {
                                    vm.removeUserPreference(text: option)
                                } else {
                                    vm.addUserPreference(text: option)
                                }
                            } label: {
                                Text(option)
                            }
                            .font(.headline)
                            .buttonStyle(.borderedProminent)
                            .tint(preferenceIsSelected(option: option) ? .green : .red)
                        }
                    }
                    
                    Text("User Preferences: \((user.preferences ?? []).joined(separator: ", "))")
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                Button {
                    if user.favouriteMovie == nil {
                        vm.addFavouriteMovie()
                    } else {
                        vm.removeFavouriteMovie()
                    }
                } label: {
                    Text("Favourite Movie: \(user.favouriteMovie?.title ?? "")")
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
    //NavigationStack {
    RootView()
        //ProfileView(showSignInView: .constant(false))
    //}
}
