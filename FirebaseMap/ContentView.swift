//
//  ContentView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2024-11-24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

//add an alert to LOG OUT and DELETE ACCOUNT buttons, also add reauthentication
//fix a bug with dissapearing premium status while logging into account
