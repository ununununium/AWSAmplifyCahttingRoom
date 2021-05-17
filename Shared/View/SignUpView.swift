//
//  SignUpView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI

struct SignUpView: View {
    @EnvironmentObject var sessionManager : SessionManager
    @State var email = ""
    @State var username = ""
    @State var password = ""
    
    
   

    
    var body: some View{
        Form{
            Section{
                HStack {
                    TextField("Enter Your Email Here", text: $email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section{
                HStack {
                    TextField("Enter Your Username Here", text: $username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section{
                HStack {
                    TextField("Enter Your Password Here", text: $password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                }
            }
            
            Section{
                Button("Sign Up",action:{
                        sessionManager.signUp(
                            username: username,
                            email: email,
                            password: password)
                })
            }

        }
    }
}

struct SignUpView_Previews: PreviewProvider{
    
    static var previews: some View{
        SignUpView()
    }
}

