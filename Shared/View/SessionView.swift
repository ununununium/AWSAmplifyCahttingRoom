//
//  SessionView.swift
//  Chach
//
//  Created by Yuting Zhong on 5/16/21.
//

import Foundation
import SwiftUI
import Amplify
import Dispatch
import UIKit

struct ImagePicker: UIViewControllerRepresentable {
 
    var sourceType: UIImagePickerController.SourceType = .photoLibrary
 
    func makeUIViewController(context: UIViewControllerRepresentableContext<ImagePicker>) -> UIImagePickerController {
 
        let imagePicker = UIImagePickerController()
        imagePicker.allowsEditing = false
        imagePicker.sourceType = sourceType
 
        return imagePicker
    }
 
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: UIViewControllerRepresentableContext<ImagePicker>) {
 
    }
}

struct SessionView: View {
    let user: AuthUser
    @EnvironmentObject var sessionManager : SessionManager
    @State var fileStatus : String?
    @State var isShowPhotoLibrary:Bool = false
    
    var body: some View{
        VStack{
            Spacer()
            Text("Welcome, " + user.username)
            if let fileStatus = self.fileStatus{
                Text(fileStatus)
            }
            Button("Upload File", action:uploadFile)
            Button("Choose Image/Video", action:{isShowPhotoLibrary.toggle()})
            Spacer()
            Button("Sign Out", action:{sessionManager.signOut()})
        }
        .sheet(isPresented: $isShowPhotoLibrary) {
            ImagePicker(sourceType: .photoLibrary)
        }
    }
    
    func uploadFile(){
        let fileKey = "testFile.txt"
        let fileContents = "This is test content \n this is another content"
        let fileData = fileContents.data(using: .utf8)!
        
        Amplify.Storage.uploadData(key: fileKey, data: fileData){
            result in
            switch result{
            case .failure(let storageError):
                print("Failed to upload",storageError)
                
                DispatchQueue.main.async {
                    fileStatus = "❌Failed"
                }
            case .success(let key):
                print("File with key \(key) uploaded")
                DispatchQueue.main.async {
                    fileStatus = "✅Success"
                }
            }
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
