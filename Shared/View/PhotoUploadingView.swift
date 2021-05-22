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
import Combine
import AWSS3StoragePlugin  // Imports the Amplify plugin interface
import AWSS3               // Imports the AWSS3 client escape hatch
import AWSCognitoAuthPlugin


struct PhotoUploadingView: View {

    
    @State var shouldShowImagePicker = false
    @State var image: UIImage?
    
    @ObservedObject var uploadViewModel = UploadViewModel()
    
    
    var body: some View{
        VStack{

            
            Spacer(minLength: 20)
            
            if let image = self.image {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
            }
            
            

            if let fileStatus = uploadViewModel.fileStatus{
                Text(fileStatus)
            }
            
            
            
            HStack {
                Button(action: {shouldShowImagePicker.toggle()}, label: {
                    Image(systemName: "camera")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                
                Button(action: {uploadViewModel.uploadFile(self.image!)}, label: {
                    Image(systemName: "icloud.and.arrow.up")
                        .font(.largeTitle)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }).disabled(self.image == nil)
                
                Button(action: {uploadViewModel.pauseResumeUploading()}, label: {
                    let name = uploadViewModel.paused ? "play.circle":"pause.circle"
                    Image(systemName: name)
                        .font(.largeTitle)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                }).disabled(uploadViewModel.uploadingOperation == nil)
                
                
                Button(action: {uploadViewModel.uploadWithTransferUtility(self.image!)}, label: {
                    let name = "icloud.and.arrow.up"
                    Image(systemName: name)
                        .font(.largeTitle)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                
                
                Button(action: uploadViewModel.restart, label: {
                    let name = "repeat"
                    Image(systemName: name)
                        .font(.largeTitle)
                        .padding()
                        .background(Color.purple)
                        .foregroundColor(.white)
                        .clipShape(Circle())
                })
                
                
            }
            
            

            
            if let progress = uploadViewModel.uploadingProgress{
                ProgressView(progress)
            }
        
            
     
            Spacer()
            
    
                
                
        }
        .sheet(isPresented: $shouldShowImagePicker, content: {
            ImagePicker(image: $image)
        })
        
    }
    
    
}


struct PhotoUploadingView_Previews: PreviewProvider{
    private struct DummyUser :AuthUser{
        let userId: String = "1"
        let username: String = "Jack"
    }
    
    static var previews : some View{
        PhotoUploadingView()
    }
}
