//
//  MessageRow.swift
//  Chach
//
//  Created by Yuting Zhong on 5/22/21.
//

import Foundation
import SwiftUI
import Combine

struct MessageRow:View {
    let message: Message
    let isCurrentUser: Bool
    let id = UUID()
    
    private var iconName:String{
        if let initial = message.senderName.first{
            return initial.lowercased()
        }else{
            return "questionmark"
        }
    }
    
    private var iconColor: Color{
        if isCurrentUser{
            return .blue
        }else{
            return .green
        }
    }
    var body: some View{
        VStack(alignment:.leading){
            HStack(alignment: .top){
                Image(systemName: "\(iconName).circle.fill")
                    .font(.largeTitle)
                    .foregroundColor(iconColor)
                VStack(alignment:.leading){
                    Text(message.senderName)
                        .font(.headline)
                    Text(message.body)
                        .font(.body)
                    
                }
                
            }.padding(.horizontal,16)
            
            Divider().padding(.leading,16)
            
        }
    }
}

struct MessageRow_Previews: PreviewProvider{
    static var previews: some View{
        let msg = Message(senderName: "Jack", body: "This is test body", creationDate: 0)
        MessageRow(message: msg, isCurrentUser: true)
    }
}

extension MessageRow : Identifiable{
    
}
