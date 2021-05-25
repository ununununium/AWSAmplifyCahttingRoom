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

import AWSS3StoragePlugin  // Imports the Amplify plugin interface
import AWSS3               // Imports the AWSS3 client escape hatch

import AWSAPIPlugin

@main
struct ChachApp: App {
    @ObservedObject var sessionManager = SessionManager()
    
    
    
    init() {
        
        
        configTransferUtility()
        
        configureAmpplify()
        sessionManager.getCurrentAuthUser()
    }
    
    
    func configureAmpplify(){
        do {
            
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.add(plugin: AWSS3StoragePlugin())
            
            let models = AmplifyModels()
            try Amplify.add(plugin: AWSAPIPlugin(modelRegistration: models))
            try Amplify.configure()
            print("Amplify configured")
        } catch {
            print("Failed to initialize Amplify with \(error)")
        }
    }
    
    func configTransferUtility(){
        //Setup credentials, see your awsconfiguration.json for the "YOUR-IDENTITY-POOL-ID"
        let credentialProvider = AWSCognitoCredentialsProvider(
            regionType: .USEast1,
            identityPoolId: "us-east-1:3fb1eb0f-6cc8-4027-a464-bca8d6383de6"
        )
        
        //Setup the service configuration
        let configuration = AWSServiceConfiguration(region: .USEast1, credentialsProvider: credentialProvider)
        
        //Setup the transfer utility configuration
        let tuConf = AWSS3TransferUtilityConfiguration()
        //        tuConf.isAccelerateModeEnabled = true
        
        //Register a transfer utility object asynchronously
        AWSS3TransferUtility.register(
            with: configuration!,
            transferUtilityConfiguration: tuConf,
            forKey: "transfer-utility-with-advanced-options"
        ) { (error) in
            if let error = error {
                print("Set up transfer utility error", error)
                //Handle registration error.
            }
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

