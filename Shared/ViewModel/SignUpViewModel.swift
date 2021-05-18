//
//  UserViewModel.swift
//  Chach
//
//  Created by Yuting Zhong on 5/15/21.
//

import Foundation
import Combine


class SignUpViewModel: ObservableObject{
    
    @Published var username  = ""
    @Published var email  = ""
    @Published var password  = ""
    
    @Published var emailValidationStatus = ""
    @Published var passwordValidationStatus = ""
    @Published var usernameValidationStatus = ""
 
    init() {
        validateEmail()
        validateUsername()
        validatePassword()
    }
    
    func validateEmail(){
        
        func isValidEmail(_ email: String) -> Bool {
            let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

            let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
            return emailPred.evaluate(with: email)
        }
        
        $email
            .map({(isValidEmail($0) ? "🟢":"🔴")})
            .assign(to: &$emailValidationStatus)
    }
    
    func validateUsername(){
        $username
            .map({$0.count > 3 ? "🟢":"🔴"})
            .assign(to: &$usernameValidationStatus)
    }
    
    func validatePassword(){
        $password
            .map({$0.count >= 8 ? "🟢":"🔴"})
            .assign(to: &$passwordValidationStatus)
    }
    
    func isSignUpInputsValid() -> Bool {
        return emailValidationStatus == "🟢" && passwordValidationStatus == "🟢" && usernameValidationStatus == "🟢"
    }
        
}

