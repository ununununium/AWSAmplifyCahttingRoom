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

class UploadViewModel : ObservableObject{
    @Published var fileStatus:String = ""
    @Published var uploadingProgress:Progress?
    @Published var paused = false
    
    var uploadingOperation:StorageUploadDataOperation?
    
    var tokens:Set<AnyCancellable> = []
    
    init(){
        pauseResumeUploading()
    }
    
    func pauseResumeUploading(){
        
        let t = $paused.sink{
            val in
            
            guard let currOp = self.uploadingOperation else{return}
            
            if val {
                currOp.pause()
                print("=======================")
                print("paused")
            }else{
                currOp.resume()
                print("=======================")
                print("resumed")
            }
        }
        tokens.insert(t)
    }
    
    
    func uploadFile(_ image:UIImage){
        guard let imageData = image.jpegData(compressionQuality: 1.0) else{return}
        
        let fileKey = UUID().uuidString + ".jpg"
        
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
}
