//
//  TicketPhotoViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketPhotoViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var ticketImageView: UIImageView!
    
    var index = 0
    
    var imageUrl: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        scrollView.delegate = self
        
        //set max and min of zoomable scale for photo
        scrollView.minimumZoomScale = 1.0
        scrollView.maximumZoomScale = 2.0
        
        HandleUtil.loadImageViewWithUrl(imageUrl, imageView: ticketImageView)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func onCancel(sender: UIBarButtonItem) {
        dismissViewControllerAnimated(true, completion: nil)
    }

}

extension TicketPhotoViewController: UIScrollViewDelegate {
    func viewForZoomingInScrollView(scrollView: UIScrollView) -> UIView? {
        return ticketImageView
    }
}
