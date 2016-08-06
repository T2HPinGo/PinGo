//
//  CreateTicketViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class CreateTicketViewController: UIViewController {
    //Outlets and Variables
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewHeightConstraints: NSLayoutConstraint!
    
    @IBOutlet weak var chooseCategoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryIconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        collectionView.dataSource = self
//        collectionView.delegate = self
        
        collectionViewHeightConstraints.constant = 0

        //add gesture for
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    //MARK: - Helpers
    func addGesture() {
        //add gesture for chooseCategoryView
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(showCollectionView(_:)))
        gestureRecognizer.cancelsTouchesInView = false
        chooseCategoryView.addGestureRecognizer(gestureRecognizer)
    }
    
    func showCollectionView(gestureRecognizer: UIGestureRecognizer) {
        print("view clicked")
    }

}

extension CreateTicketViewController {
    
}
