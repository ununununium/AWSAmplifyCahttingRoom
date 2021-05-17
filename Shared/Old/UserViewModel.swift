//
//  UserViewModel.swift
//  Chach
//
//  Created by Yuting Zhong on 5/15/21.
//

import Foundation
import Combine

import Amplify
import AWSCognitoAuthPlugin

class UserViewModel: ObservableObject{
    // Input
    @Published var username  = ""
    @Published var email  = ""
    @Published var password  = ""
    
    // Output

    
    @Published var signUpCompleted = false
    
    @Published var deliveryDetails = ""
    
    @Published var confirmationCode = ""
    
    @Published var emailValidationStatus = ""
    @Published var passwordValidationStatus = ""
    @Published var usernameValidationStatus = ""
    @Published var confirmationMessageDidSend = false
    
    private var tokens: Set<AnyCancellable> = []
    
    
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
    
    
    
    
    
    func signUp() -> AnyCancellable {
        
        let userAttributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: userAttributes)
        let sink = Amplify.Auth.signUp(username: username, password: password, options: options)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("An error occurred while registering a user \(authError)")
                }
            }
            receiveValue: { signUpResult in
                if case let .confirmUser(deliveryDetails, _) = signUpResult.nextStep {
                    print("Delivery details \(String(describing: deliveryDetails))")
                    self.confirmationMessageDidSend = true
                } else {
                    print("SignUp Complete")
                }
            }
        tokens.insert(sink)
        return sink
    }

    
    func confirmSignUp() -> AnyCancellable {
        let sink = Amplify.Auth.confirmSignUp(for: username, confirmationCode: confirmationCode)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("An error occurred while confirming sign up \(authError)")
                }
            }
            receiveValue: { _ in
                print("Confirm signUp succeeded")
            }
        tokens.insert(sink)
        return sink
    }
    
    func signIn(username: String, password: String) -> AnyCancellable {
        let sink = Amplify.Auth.signIn(username: username, password: password)
            .resultPublisher
            .sink {
                if case let .failure(authError) = $0 {
                    print("Sign in failed \(authError)")
                }
            }
            receiveValue: { result in
                if case .confirmSignInWithCustomChallenge(_) = result.nextStep {
                    // Ask the user to enter the custom challenge.
                } else {
                    print("Sign in succeeded")
                }
            }
        tokens.insert(sink)
        return sink
    }
        
}

