//
//  SessionView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI
import Amplify
import Dispatch
import UIKit
import Combine
import AWSS3StoragePlugin  // Imports the Amplify plugin interface
import AWSS3               // Imports the AWSS3 client escape hatch
import AWSCognitoAuthPlugin


struct SessionView: View {
    let user: AuthUser
    @EnvironmentObject var sessionManager : SessionManager
    
    var body: some View{
        
        NavigationView {
            
            List{
                NavigationLink(destination: PhotoUploadingView()) {
                    Text("PhotoUploadingView")
                }
                NavigationLink(destination: PhotoUploadingView()) {
                    Text("PhotoUploadingView")
                }
                
            }
            .navigationTitle("All Views")
            .toolbar{
                
                ToolbarItem(placement: .navigationBarLeading) {
                    Text("Hello, \(user.username) 🐙")
                }
                
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action:{sessionManager.signOut()}){
                        Text("Sign Out").foregroundColor(.red)
                    }
                }
                
            }
        }
        
    }
    
    
}


struct SessionView_Previews: PreviewProvider{
    private struct DummyUser :AuthUser{
        let userId: String = "1"
        let username: String = "Jack"
    }
    
    static var previews : some View{
        SessionView(user: DummyUser())
    }
}
