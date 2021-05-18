//
//  SignUpView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI
import Combine


struct SignUpView: View {
    @EnvironmentObject var sessionManager : SessionManager
    @ObservedObject var signUpModelView = SignUpViewModel()
    
    var status = ""
    init(){

    }

    
    var body: some View{
        Form{
            Section{
                HStack {
                    TextField("Enter Your Email Here",
                              text: $signUpModelView.email)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Text(signUpModelView.emailValidationStatus)
                }
            }
            
            Section{
                HStack {
                    TextField("Enter Your Username Here",
                              text: $signUpModelView.username)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Text(signUpModelView.usernameValidationStatus)
                }
            }
            
            Section{
                HStack {
                    TextField("Enter Your Password Here",
                              text: $signUpModelView.password)
                        .autocapitalization(.none)
                        .disableAutocorrection(true)
                    Text(signUpModelView.passwordValidationStatus)
                }
            }
            
            Section{
                Button("Sign Up",action:{
                        sessionManager.signUp(
                            username: signUpModelView.username,
                            email: signUpModelView.email,
                            password: signUpModelView.password)
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

