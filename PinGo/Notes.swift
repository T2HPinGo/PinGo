//
//  Notes.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/9/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//


//Walkthru Screen
//Loading Screen
//random message when loading
//HomeTimelineVC
//      make a popup VC to show ticket detail
//      make user go back to where they left off if app it terminated
//      make a swipe to delete kinda thing
//CreateTicketVC: 
//      make the view slide up when the keyboard appears
//      infinite scrolling for collectionView
//      user able to add video
//      user can add more than 3 pictures
//TicketBiddingVC
//      make the filter slide down from top and block a part of the main view OR add a segment to let user tap to filter
//      discuss if the user is able to edit ticket detail in this step
//      add a timer that check if the system can found any workers
//      what if user cancel the ticket and suddenly lost connection

//WorkerHistoryVC
//      divide the tableView in to sections (last week, last month, last 3 months, later)
//      add popup view to see customer review on each task history

//SetPricePopupVC
//when the worker quit withou bidding, the status automatically set to waiting -> WRONG


//  USing Alamofire

// Example Alamofire register 
//
//let parameters = [
//    "username": usernameTextField.text!,
//    "password": passwordTextField.text!,
//    "email" : emailTextField.text!,
//    "phoneNumber": phoneNumberTextField.text!,
//    "address": addressTextField.text!,
//    "city": cityTextField.text!,
//    "imageUrl": "\((worker?.profileImage?.imageUrl)!)",
//    "width": "\((worker?.profileImage?.width)!)",
//    "height": "\((worker?.profileImage?.height)!)",
//    "isWorker": true
//    
//]
//
//Alamofire.request(.POST, "http://192.168.1.18:3000/v1/register", parameters: parameters as?[String : AnyObject]).responseJSON { response  in
//    print(response)
//    
//}


// Upload file 

//Alamofire.upload(
//    .POST,
//    "http://192.168.1.63:3000/v1/images/ticket",
//    multipartFormData: { multipartFormData in
//        if let imageData = UIImageJPEGRepresentation(image, 0.5) {
//            multipartFormData.appendBodyPart(data: imageData, name: "imageTicket", fileName: "fileName.jpg", mimeType: "image/jpeg")
//        }
//        
//    },
//    encodingCompletion: { encodingResult in
//        switch encodingResult {
//        case .Success(let upload, _, _):
//            upload.responseJSON { response in
//                print(response)
//                let JSON = response.result.value as? [String:AnyObject]
//                //print(JSON!["url"])
//                imageResource.imageUrl = JSON!["url"] as? String
//                print(imageResource.imageUrl)
//            }
//        case .Failure(let encodingError):
//            print(encodingError)
//        }
//    }
//)