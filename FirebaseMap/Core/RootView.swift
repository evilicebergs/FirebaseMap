//
//  RootView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-25.
//

import SwiftUI

struct RootView: View {
    
    @State private var showSignInView = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                TabbarView(showSignInView: $showSignInView)
            }
        }
        .onAppear(perform: {
            let authUser = try? AuthenticationManager.shared.getAuthenticatedUser()
            self.showSignInView = authUser == nil
        })
        .fullScreenCover(isPresented: $showSignInView) {
            NavigationStack {
                AuthenticationView(showSignInView: $showSignInView)
            }
        }
    }
}

#Preview {
    RootView()
}
