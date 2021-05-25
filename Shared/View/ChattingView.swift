//
//  ChattingView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/22/21.
//

import Foundation
import SwiftUI
import Combine

import Amplify

struct ChattingView: View{
    @State var text = ""
    @ObservedObject var sot = SourceOfTruth()
    
    
    let currentUser = Amplify.Auth.getCurrentUser()?.username
    
//    @State private var scp: ScrollViewProxy?
    
    init(){
        
        sot.getMessages()
        sot.observeMessages()
        
    }
    
    var body: some View{
        
        
        VStack{
            ScrollView(.vertical){
                ScrollViewReader { value in
                    VStack {
                        ForEach(sot.messages, id:\.id){
                            message in
                            
                            MessageRow(
                                message: message,
                                isCurrentUser: message.senderName == currentUser
                            ).id(message.id)
                        }.onAppear(){
                            DispatchQueue.main.async {
                                withAnimation {
                                    value.scrollTo(sot.messages.last?.id)
                                }
                            }
                        }
                    }
                }
            }.onTapGesture {
                hideKeyboard()
            }
            
            
            VStack {
                HStack{
                    TextField("Enter message", text:$text)
                        .padding(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(Color.black, lineWidth: 3)
                        )


                    Button("Send", action:{didTapSend()})
                        .padding()
                        .foregroundColor(.white)
                        .background(Color.blue)
                        .cornerRadius(10)

                }.padding(8)
                .padding(.bottom, 30)

            }

            

  
            
       
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationTitle("Chatting Room")
        .toolbar{
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action:{sot.deleteAllMessages()}){
                    Text("Delete All")
                }
            }
            

        }
        
    }
    
    func didTapSend(){
        print(text)
        var message = Message(senderName: currentUser ?? "Unknow User", body: text,
                              creationDate: Int(Date().timeIntervalSince1970))
        sot.send(&message)
        
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

