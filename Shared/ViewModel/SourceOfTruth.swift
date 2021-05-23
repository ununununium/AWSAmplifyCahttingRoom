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
    
    
    func send(_ message: Message){
        let token = Amplify.API.mutate(request: .create(message))
            .resultPublisher
            .sink { completion in
                if case let .failure(error) = completion{
                    print("fail to create graphql", error)
                }
            }
            receiveValue: { result in
                switch result{
                
                case .failure(let graphQLError):
                    print(graphQLError)
                    
                case .success:
                    print("Success")
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
                
                self.messages = messages.sorted(by: {$0.creationDate < $1.creationDate})
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
                    self.messages.append(message)
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
                    print("delet success")
                }
            }
        
        tokens.insert(token)

        
    }
    
}
