//
//  ContentView.swift
//  Shared
//
//  Created by Yuting Zhong on 5/15/21.
//

import SwiftUI
import Amplify
import AWSCognitoAuthPlugin
import Combine





struct ContentView: View {
    @ObservedObject private var userViewModel = UserViewModel()
    @State private var showSheet = false
    @State private var signUpClicked = false
    
    var body: some View {
        
        
        NavigationView{
            Form{
                    Section{
                      
                        HStack {
                            TextField("Enter Your Email Here", text: $userViewModel.email)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            Text(userViewModel.emailValidationStatus)
                        }
                        
                      
                    }
                    Section{
                        HStack {
                            TextField("Enter Your Username Here", text: $userViewModel.username)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Text(userViewModel.usernameValidationStatus)
                        }
                    }
                    Section{
                        HStack {
                            TextField("Enter Your Password Here", text: $userViewModel.password)
                                .autocapitalization(.none)
                                .disableAutocorrection(true)
                            
                            Text(userViewModel.passwordValidationStatus)
                        }
                    }
                    
                    Section{
                        
                        HStack {
                            Button(action: {_=userViewModel.signUp(); signUpClicked.toggle()} ){
                                Text("Sign Up")
                            }.disabled(!userViewModel.isSignUpInputsValid())
                            Spacer()
                            
                            if(signUpClicked && !userViewModel.confirmationMessageDidSend){
                                ProgressView()
                            }
                        }
                       
                    }
            }
        }.environmentObject(userViewModel)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}





struct ConfirmCodeView: View {
    
    @EnvironmentObject var userViewModel: UserViewModel
    
    
    var body: some View {
        Form{
            Section{
                TextField("Enter Your Confirmation Code Here", text: $userViewModel.confirmationCode)
            }
            
            Section{
                Button(action: {_ = userViewModel.confirmSignUp()} ){
                    Text("Confirm")
                }
            }
        }
    }
}
