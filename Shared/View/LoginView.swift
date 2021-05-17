//
//  LoginView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI

struct LoginView: View {
    @EnvironmentObject var sessionManager : SessionManager
    @State var username = ""
    @State var password = ""
    
    
    var body: some View{
        
        VStack {
            Form{
                Section{
                    TextField("Username", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
                
                Section{
                    SecureField("Password", text: $password)
                }
                
                Section{
                    Button("Login", action:{sessionManager
                            .login(username: username,
                                   password: password
                            )})
                }
                
            }
            
            Spacer()
            
            
            Button("Do not have an account ? Sign Up", action :{sessionManager.showSignUp()})
            
        }
    }
}

struct LoginView_Preview : PreviewProvider{
    static var previews: some View {
        LoginView()
    }
}
