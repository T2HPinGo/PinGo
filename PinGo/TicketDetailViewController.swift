//
//  TicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController {
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    var ticket: Ticket!
    
    var imageUrls: [String]! //store image urls

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        imageUrls = ticket.getImagesArray()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewImageSegue" {
            if let indexPaths = collectionView.indexPathsForSelectedItems() {
                let navigation = segue.destinationViewController as! UINavigationController
                let ticketPhotoViewController = navigation.topViewController as! TicketPhotoViewController
                let index = indexPaths[0].row
                ticketPhotoViewController.imageUrl = imageUrls[index]
            }
        }
    }
    
}

extension TicketDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return imageUrls.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("TicketImageCell", forIndexPath: indexPath) as! TicketImageCell
        cell.imageUrl = imageUrls[indexPath.row]
        return cell
    }
    
    
}


