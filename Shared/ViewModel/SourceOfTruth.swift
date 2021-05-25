//
//  SourceOfTruth.swift
//  Chach
//
//  Created by Yuting Zhong on 5/22/21.
//

import Foundation
import Amplify
import Combine

class SourceOfTruth: ObservableObject{
    @Published var messages = [Message]()
    
    var tokens:Set<AnyCancellable> = []
    
    
    func send(_ message: inout Message){
        let m = message
        messages.append(m)
        let token = Amplify.API.mutate(request: .create(message))
            .resultPublisher
            .sink { completion in
                if case let .failure(error) = completion{
                    print("fail to create graphql", error)
                    m.isSent = .fail
                    self.messages = self.messages.sorted(by: {$0.creationDate < $1.creationDate})
                }
            }
            receiveValue: { result in
                switch result{
                
                case .failure(let graphQLError):
                    print(graphQLError)
                    m.isSent = .fail
                    self.messages = self.messages.sorted(by: {$0.creationDate < $1.creationDate})
                    
                case .success:
                    print("Success")
                    DispatchQueue.main.async {
                        m.isSent = .success
                        self.messages = self.messages.sorted(by: {$0.creationDate < $1.creationDate})
                    }

                }
            }
        
        tokens.insert(token)

    }
    
    func getMessages(){

        let token = Amplify.API.query(request: .list(Message.self)).resultPublisher.sink {
            completion in
            if case let .failure(error) = completion{
                print(error)
            }
        } receiveValue: { result in
            switch result{
            case .success(let messages):
                DispatchQueue.main.async {
                    self.messages = messages.sorted(by: {$0.creationDate < $1.creationDate}).map({ message in
                        let loadedMessage = message
                        loadedMessage.isSent = .success
                        return loadedMessage
                    })
                }
            case .failure(let error):
                print(error)
            }
        }
        
        tokens.insert(token)

    }
    
    var subscription: GraphQLSubscriptionOperation<Message>?
    func observeMessages(){
        
        subscription = Amplify.API.subscribe(request: .subscription(of: Message.self, type: .onCreate))
        
        let dataSink = subscription?.subscriptionDataPublisher.sink {
            if case let .failure(apiError) = $0 {
                print("Subscription has terminated with \(apiError)")
            } else {
                print("Subscription has been closed successfully")
            }
        }
        receiveValue: { result in
            switch result {
            
            case .success(let message):
                print("Successfully got todo from subscription: \(message)")
                DispatchQueue.main.async {
                    if(!self.messages.contains(message)){
                        self.messages.append(message)
                    }
                    
                }
            case .failure(let error):
                print("Got failed result with \(error.errorDescription)")
            }
        }
        
        if dataSink != nil{
            tokens.insert(dataSink!)
        }
        
        
    }
    
    func delete(_ message: Message){
        let token = Amplify.API.mutate(request: .delete(message))
            .resultPublisher
            .sink { completion in
                if case let .failure(error) = completion{
                    print("fail to create graphql", error)
                }
            } receiveValue: { result in
                switch result{
                
                case .failure(let error):
                    print(error)
                case .success:

                    DispatchQueue.main.async {
                        self.messages = self.messages.filter { !($0 == message) }

                    }
                    print("delet success")
                }
            }
        
        tokens.insert(token)
    }
    
    func deleteAllMessages(){
        for m in messages{
            delete(m)
        }

    }
}
