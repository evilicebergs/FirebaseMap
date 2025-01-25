//
//  CrashView.swift
//  FirebaseMap
//
//  Created by Artem Golovchenko on 2025-01-21.
//

import SwiftUI
import FirebaseCrashlytics

final class CrashManager {
    
    static let shared = CrashManager()
    private init() { }
    
    func setUserId(userId: String) {
        Crashlytics.crashlytics().setUserID(userId)
    }
    
    func setValue(value: String, key: String) {
        Crashlytics.crashlytics().setCustomValue(value, forKey: key)
    }
    
    func setIsPremiumValue(isPremium: Bool) {
        setValue(value: isPremium.description.lowercased(), key: "user_is_premium")
    }
    
    func addLog(messsage: String) {
        Crashlytics.crashlytics().log(messsage)
    }
    
    func sendNonFatal(error: Error) {
        Crashlytics.crashlytics().record(error: error)
    }
    
}

struct CrashView: View {
    var body: some View {
        ZStack {
            Color.gray.opacity(0.6).ignoresSafeArea()
            
            VStack {
                Button {
                    CrashManager.shared.addLog(messsage: "button1 clicked")
                    
                    let myString: String? = nil
                    
//                    guard let myString else {
//                        CrashManager.shared.sendNonFatal(error: URLError(.dataNotAllowed))
//                        return
//                    }
                    
                    //let string2 = myString
                } label: {
                    Text("Click Me 1")
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(color: .black, radius: 3)
                }
                
                Button {
                    CrashManager.shared.addLog(messsage: "button2 clicked")
                    
                    fatalError("This was a fatal error")
                } label: {
                    Text("Click Me 2")
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(color: .black, radius: 3)
                }
                
                Button {
                    CrashManager.shared.addLog(messsage: "button3 clicked")
                    
//                    let array: [String] = []
//                    let item = array[0]
                } label: {
                    Text("Click Me 3")
                        .foregroundStyle(.black)
                        .padding()
                        .background(Color.white)
                        .clipShape(.rect(cornerRadius: 15))
                        .shadow(color: .black, radius: 3)
                }

            }
        }
        .onAppear {
            CrashManager.shared.setUserId(userId: "ABC123")
            
            CrashManager.shared.setIsPremiumValue(isPremium: true)
            
            CrashManager.shared.addLog(messsage: "crash view appeared on user's screen.")
        }
    }
}

#Preview {
    CrashView()
}
