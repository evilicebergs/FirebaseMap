//
//  ProfileView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-12-09.
//

import SwiftUI
import PhotosUI

struct ProfileView: View {
    
    @StateObject private var vm = ProfileViewModel()
    @Binding var showSignInView: Bool
    @State private var selectedItem: PhotosPickerItem? = nil
    
    @State private var selectedPhoto: UIImage? = nil
    
    let preferenceOptions: [String] = ["Sports", "Movies", "Books"]
    
    private func preferenceIsSelected(option: String) -> Bool {
        vm.user?.preferences?.contains(option) == true
    }
    
    var body: some View {
        List {
            if let user = vm.user {
                
                if let photo = selectedPhoto {
                    Image(uiImage: photo)
                        .resizable()
                        .scaledToFill()
                        .clipShape(.rect(cornerRadius: 10))
                        .padding()
                }
                
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

                PhotosPicker(selection: $selectedItem, matching: .images, photoLibrary: .shared()) {
                    Text("Select a  photo")
                }
                
                if let data = vm.user?.profileImageUrl, let url = URL(string: data) {
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(width: 150)
                            .clipShape(.rect(cornerRadius: 10))
                        
                    } placeholder: {
                        ProductsView()
                            .frame(width: 150)
                    }
                }
                
                if vm.user?.profileImagePath != nil {
                    Button("Delete image") {
                        Task {
                            try await vm.deleteProfileImage()
                        }
                        
                    }
                }
                
            }
        }
        .onChange(of: selectedItem, { oldValue, newValue in
            if let newValue {
                Task {
                    vm.saveProfileImage(item: newValue)
                    try await vm.saveImageToFileManager(item: newValue)
                    selectedPhoto = try? await vm.displayPhoto(item: newValue)
                }
            }
        })
        .onAppear {
            Task {
                do {
                    try await vm.loadCurrentUser()
                    selectedPhoto = vm.loadImage()
                    if let user = vm.user {
                        CrashManager.shared.setUserId(userId: user.userId)
                        CrashManager.shared.setIsPremiumValue(isPremium: user.isPremium ?? false)
                    }
                } catch {
                    CrashManager.shared.sendNonFatal(error: error)
                }
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
