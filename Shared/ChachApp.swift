//
//  ChachApp.swift
//  Shared
//
//  Created by Yuting Zhong on 5/15/21.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin


@main
struct ChachApp: App {
    @ObservedObject var sessionManager = SessionManager()
    
    init() {
        configureAmpplify()
        sessionManager.getCurrentAuthUser()
    }
    
    
    func configureAmpplify(){
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure()
            print("Amplify configured with auth plugin")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            switch sessionManager.authState{
            case .login:
                LoginView().environmentObject(sessionManager)
            case .signUp:
                SignUpView().environmentObject(sessionManager)
            case .confirmCode(username: let username):
                ConfirmationView(username: username).environmentObject(sessionManager)
            case .session(user: let user):
                SessionView(user: user).environmentObject(sessionManager)
            }
        }
    }
}

