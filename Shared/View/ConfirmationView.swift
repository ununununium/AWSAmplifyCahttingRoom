//
//  ConfirmationView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI

struct ConfirmationView: View {
    var username: String
    @EnvironmentObject var sessionManager : SessionManager
    @State var confirmationCode: String = ""
    
    var body: some View{
        Form{
            Section{
                TextField("Please Enter Your Confirmation Code", text:$confirmationCode)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
            }
            Section{
                Button("Confirm", action:{
                    sessionManager.confirm(username: username, code: confirmationCode)
                })
            }
            
            
        }
    }
}

struct ConfirmationView_Previwes: PreviewProvider{
    
    
    static var previews: some View{
        ConfirmationView(username: "hhhhh")
    }
}
