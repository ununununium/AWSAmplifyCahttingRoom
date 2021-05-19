//
//  ChachApp.swift
//  Shared
//
//  Created by Yuting Zhong on 5/15/21.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import AWSS3StoragePlugin



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
            try Amplify.add(plugin: AWSS3StoragePlugin())
            try Amplify.configure()
            print("Amplify configured")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
    
    
    var body: some Scene {
        WindowGroup {
            switch sessionManager.authState{
            case .login:
                LoginView()
                    .environmentObject(sessionManager)
                    .transition(AnyTransition.scale.animation(.spring()))
            case .signUp:
                SignUpView()
                    .environmentObject(sessionManager)
                    .transition(AnyTransition.scale.animation(.easeOut(duration: 0.5)))
            case .confirmCode(username: let username):
                ConfirmationView(username: username)
                    .environmentObject(sessionManager)
                    .transition(AnyTransition.scale.animation(.spring()))
            case .session(user: let user):
                SessionView(user: user)
                    .environmentObject(sessionManager)
                    .transition(AnyTransition.scale.animation(.spring()))
            }
        }
    }
}

