//
//  PinGoClient.swift
//  PinGo
//®
//  Created by Hien Quang Tran on 8/14/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import Foundation
import Alamofire

class PinGoClient {
    class func uploadImage(imageResource: ImageResource, image: UIImage, uploadType: String){
        Alamofire.upload(
            .POST,
            "\(API_URL)\(PORT_API)/v1/images/\(uploadType)",
            multipartFormData: { multipartFormData in
                if let imageData = UIImageJPEGRepresentation(image, 0.5) {
                    multipartFormData.appendBodyPart(data: imageData, name: "imageUpload", fileName: "fileName.jpg", mimeType: "image/jpeg")
                }
                
            },
            encodingCompletion: { encodingResult in
                switch encodingResult {
                case .Success(let upload, _, _):
                    upload.responseJSON { response in
                        print(response)
                        let JSON = response.result.value as? [String:AnyObject]
                        print(JSON!["url"])
                        imageResource.imageUrl = JSON!["url"] as? String
                        print(imageResource.imageUrl)
                    }
                case .Failure(let encodingError):
                    print(encodingError)
                }
            }
        )
    }

}
