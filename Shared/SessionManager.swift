//
//  SessionManager.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//
import Combine
import Amplify
import Dispatch

enum AuthState {
    case signUp
    case login
    case confirmCode(username: String)
    case session(user: AuthUser)
}

final class SessionManager: ObservableObject{
    @Published var authState: AuthState = .login
    
    
    func getCurrentAuthUser(){
        if let user = Amplify.Auth.getCurrentUser(){
            authState = .session(user: user)
        }else{
            authState = .login
        }
    }
    
    func showSignUp(){
        authState = .signUp
    }
    
    func showLogin(){
        authState = .login
    }
    
    func signUp(username: String, email:String, password:String){
        let attributes = [AuthUserAttribute(.email, value: email)]
        let options = AuthSignUpRequest.Options(userAttributes: attributes)
        _ = Amplify.Auth.signUp(
            username: username,
            password: password,
            options: options
        ){[weak self] result in
            switch result {
            
            case .success(let signUpResult):
                print("Sign up result:" ,signUpResult)
                
                switch signUpResult.nextStep {
                case .done:
                    print("Finished Sign Up")
                case .confirmUser(let details,_):
                    
                    print(details ?? "no details")
                    DispatchQueue.main.async{
                        self?.authState = .confirmCode(username: username)
                    }
                    
                }
            
            case .failure(let error):
                print("Sign Up Error",error)
            }
        }
    }
    
    func confirm(username: String, code: String){
        _ = Amplify.Auth.confirmSignUp(for: username, confirmationCode: code){
            [weak self]result in
            switch result{
            case.failure(let error):
                print("failed to confirm code: ",error)
      
            case .success(let confirmationResult):
                print(confirmationResult)
                DispatchQueue.main.async{
                    self?.showLogin()
                }
            }
        }
    }
    
    func login(username: String, password: String){
        _ = Amplify.Auth.signIn(
            username: username,
            password: password
        ){[weak self] result in
            switch result{
            case .failure(let error):
                print("Login error ", error)
            case .success(let signInResult):
                print(signInResult)
                if signInResult.isSignedIn{
                    DispatchQueue.main.async {
                        self?.getCurrentAuthUser()
                    }
                }
            }
            
        }
    }
    
    func signOut(){
        _ = Amplify.Auth.signOut(){
            [weak self] result in
            switch result{
            case .failure(let error):
                print("failed sign out, ", error)
            case .success:
                DispatchQueue.main.async {
                    self?.getCurrentAuthUser()
                }
            }
        }
    }
    
    
    
}
