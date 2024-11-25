//
//  SettingsView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-25.
//

import SwiftUI

@MainActor
final class SettingsViewModel: ObservableObject {
    
    func logOut() throws {
        try AuthenticationManager.shared.signOut()
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
        }
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
    }
}
