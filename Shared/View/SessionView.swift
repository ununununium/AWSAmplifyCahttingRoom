//
//  SessionView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI
import Amplify

struct SessionView: View {
    let user: AuthUser
    @EnvironmentObject var sessionManager : SessionManager
    var body: some View{
        VStack{
            Spacer()
            Text("Welcome, " + user.username)
            Spacer()
            Button("Sign Out", action:{sessionManager.signOut()})
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
