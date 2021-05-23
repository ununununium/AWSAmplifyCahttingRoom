//
//  ChattingView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/22/21.
//

import Foundation
import SwiftUI
import Combine

struct ChattingView: View{
    @State var text = ""
    @ObservedObject var sot = SourceOfTruth()
    
    let currentUser = "pppMMM"
    
    init(){
        sot.getMessages()
        sot.observeMessages()
    }
    
    var body: some View{
        VStack{
            
            ScrollView{

                ScrollViewReader { value in
                    LazyVStack  {
                        ForEach(sot.messages){
                            message in

                            MessageRow(
                                message: message,
                                isCurrentUser: message.senderName == currentUser
                            )
                        }.onAppear {
                            if let tmp = sot.messages.last {
                                print("====>" + tmp.body)
                            }else{
                                print("====> mmmm")
                            }

                            value.scrollTo(sot.messages.count-1)
                        }
                    }
                }
            }
            HStack{
                TextField("Enter message", text:$text)
                Button("Send", action:{didTapSend()})
                    .padding()
                    .foregroundColor(.white)
                    .background(Color.blue)
            }
            
        }
    }
    
    func didTapSend(){
        print(text)
        let message = Message(senderName: currentUser, body: text,
                              creationDate: Int(Date().timeIntervalSince1970))
        sot.send(message)
        
        text.removeAll()
        self.hideKeyboard()
    }
}


struct ChattinView_Previews: PreviewProvider {
    static var previews: some View{
        ChattingView()
    }
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

