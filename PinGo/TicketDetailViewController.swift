//
//  TicketDetailViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/21/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class TicketDetailViewController: UIViewController {
    
    @IBOutlet weak var categoryIconView: UIView!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    @IBOutlet weak var ticketTitleLabel: UILabel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var bidButton: UIButton!
    
    var colorTheme: UIColor!
    
    var ticket: Ticket!
    
    var imageUrls: [String]! //store image urls

    override func viewDidLoad() {
        super.viewDidLoad()

        collectionView.dataSource = self
        collectionView.delegate = self
        
        imageUrls = ticket.getImagesArray()
        configureLabels()
        setupAppearance()
    }
    
    func setupAppearance() {
        bidButton.layer.cornerRadius = 5
        bidButton.layer.borderColor = colorTheme.CGColor
        bidButton.layer.borderWidth = 1.0
        bidButton.tintColor = colorTheme
        
        categoryIconView.layer.cornerRadius = categoryIconView.frame.width / 2
        categoryIconView.backgroundColor = colorTheme
    }
    
    func configureLabels() {
        ticketTitleLabel.text = ticket.title
        descriptionLabel.text = ticket.descriptions != "" ? ticket.descriptions : "No description"

    }
    
    // MARK: - Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewImageSegue" {
            if let indexPaths = collectionView.indexPathsForSelectedItems() {
                let pageViewController = segue.destinationViewController as! PhotoSlidePageViewController
                pageViewController.imageUrls = self.imageUrls
                pageViewController.index = indexPaths.first?.item
            }
        }
    }
    
    @IBAction func unwindFromPhotoView(sender: UIStoryboardSegue) {
        
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


