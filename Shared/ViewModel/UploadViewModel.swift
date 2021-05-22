//
//  UploadViewModel.swift
//  Chach
//
//  Created by Yuting Zhong on 5/18/21.
//

import Combine
import Amplify
import Dispatch
import Foundation
import SwiftUI
import UIKit

import AWSS3StoragePlugin  // Imports the Amplify plugin interface
import AWSS3               // Imports the AWSS3 client escape hatch
import AWSCognitoAuthPlugin
import AWSPluginsCore

class UploadViewModel : ObservableObject{
    @Published var fileStatus:String = ""
    @Published var uploadingProgress:Progress?
    @Published var paused = false
    
    var uploadingOperation:StorageUploadDataOperation?
    
    var tokens:Set<AnyCancellable> = []
    
    
    func pauseResumeUploading(){
        guard let currOp = self.uploadingOperation else{return}
        paused = !paused
        if paused{
            currOp.pause()
            print("=======================")
            print("paused")
        }else{
            currOp.resume()
            print("=======================")
            print("resumed")
        }
    }
    
    
    func uploadFile(_ image:UIImage){
        guard let imageData = image.jpegData(compressionQuality: 1.0) else{return}
        
//        let fileKey = UUID().uuidString + ".jpg"
        let fileKey = "test002.jpg"
        
        
        let storageOperation = Amplify.Storage.uploadData(key:fileKey, data: imageData)
        self.uploadingOperation = storageOperation
        
        let progressSink = storageOperation.progressPublisher.sink {
            progress in
            print("Progress: \(progress)")
            DispatchQueue.main.async{
                self.uploadingProgress = progress

            }
        }
        let resultSink = storageOperation.resultPublisher.sink {
            if case let .failure(storageError) = $0 {
                print("Failed: \(storageError.errorDescription). \(storageError.recoverySuggestion)")
                
                DispatchQueue.main.async {
                    self.fileStatus = "❌Failed"
                }
                
            }
        }
        receiveValue: { data in
            print("Completed: \(data)")
            
            DispatchQueue.main.async {
                self.fileStatus = "✅Success"
            }
        }
        
        tokens.insert(progressSink)
        tokens.insert(resultSink)
    }
    
    func uploadWithTransferUtility(_ image:UIImage){
        guard let imageData = image.jpegData(compressionQuality: 1.0) else{return}
//        var id = ""
//
//        Amplify.Auth.fetchAuthSession { result in
//            do {
//                    let session = try result.get()
//
//                    // Get user sub or identity id
//                    if let identityProvider = session as? AuthCognitoIdentityProvider {
//                        let usersub = try identityProvider.getUserSub().get()
//                        let identityId = try identityProvider.getIdentityId().get()
//                        id = identityId;
//                        print("User sub - \(usersub) and identity id \(identityId)")
//                    }
//
//
//                } catch {
//                    print("Fetch auth session failed with error - \(error)")
//                }
//        }
        let fileKey = "public/test002.jpg"
        

          let expression = AWSS3TransferUtilityUploadExpression()
             expression.progressBlock = {(task, progress) in
                DispatchQueue.main.async(execute: {
                    self.uploadingProgress = progress
               })
          }

          var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
          completionHandler = { (task, error) -> Void in
             DispatchQueue.main.async(execute: {
                if let error = error {
                    NSLog("Failed with error: \(error)")
                }
                else if(self.uploadingProgress!.fractionCompleted != 1.0) {
                    NSLog("Error: Failed. != 1.0 ")
                } else {
                    NSLog("Success.")
                }
             })
          }

          let transferUtility = AWSS3TransferUtility.default()

          transferUtility.uploadData(imageData,
               bucket: "chachbucket32916-dev",
               key: fileKey,
               contentType: "image/jpg",
               expression: expression,
               completionHandler: completionHandler).continueWith {
                  (task) -> AnyObject? in
                      if let error = task.error {
                         print("Error: \(error.localizedDescription)")
                      }

                      if let _ = task.result {
                         // Do something with uploadTask.
                      }
                      return nil;
              }
    }
    
    
    func restart() {
        print("==>repeat clicked")
        
        let fileKey = "public/test002.jpg"
        
        let transferUtility = AWSS3TransferUtility.s3TransferUtility(forKey: fileKey)
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in DispatchQueue.main.async(execute: {
//                if let error = error {
//                    NSLog("Failed with error: \(error)")
//                }
//                else if(self.progressView.progress != 1.0) {
//                    NSLog("Error: Failed.")
//                } else {
//                    NSLog("Success.")
//                }
            })
        }

        
        let uploadTasks = transferUtility!.getUploadTasks().result
        
        
        for task in uploadTasks! {
            let t = task as! AWSS3TransferUtilityUploadTask
            t.setCompletionHandler(completionHandler)
            t.setProgressBlock{
                (task, progress) in
                DispatchQueue.main.async(execute: {
                    self.uploadingProgress = progress
                })
                
            }
        }
    }
}
