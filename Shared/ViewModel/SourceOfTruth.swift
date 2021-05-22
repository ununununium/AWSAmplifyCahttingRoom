//
//  SourceOfTruth.swift
//  Chach
//
//  Created by Yuting Zhong on 5/22/21.
//

import Foundation
import Amplify


class SourceOfTruth: ObservableObject{
    @Published var messages = [Message]()
    
    
    func send(_ message: Message){
        Amplify.API.mutate(request: .create(message)){
            mutationResult in
            
            switch mutationResult{
            case.failure(let apiError):
                print(apiError)
            case .success(let creationResult):
                
                switch creationResult{
                case .failure(let creationError):
                    print(creationError)
                case .success:
                    print("successfully created message")
                    
                }
            }
        }
    }
    
    func getMessages(){
        Amplify.API.query(request: .list(Message.self)) {
            [weak self] result in
            do{
                let messages = try result.get().get()
                
//                messages.forEach{
//                    m in
//                    self?.delete(m)
//                }
//                
                DispatchQueue.main.async {
                    self?.messages = messages.sorted(by: {$0.creationDate < $1.creationDate})
                }
            }catch{
                print(error)
            }
        }
    }
    
    var subscription: GraphQLSubscriptionOperation<Message>?
    func observeMessages(){
        subscription = Amplify.API.subscribe(
            request: .subscription(of: Message.self, type: .onCreate),
            valueListener:{
                [weak self]subscriptionEvent in
                switch subscriptionEvent{
                case .connection(let connectionState):
                    print("Connection State: ", connectionState)
                case .data(let dataResult):
                    do{
                        let message = try dataResult.get()
                        DispatchQueue.main.async {
                            self?.messages.append(message)
                        }
                        
                    }catch{
                        print(error)
                    }
                    
                }
            },
            completionListener:{
                completion in
                print(completion)
                
            }
        )
    }
    
    func delete(_ message: Message){
        Amplify.API.mutate(request: .delete(message)){
            result in
            print(result)
        }
        
    }
    
}
