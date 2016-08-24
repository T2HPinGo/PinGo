//
//  PhotoSlidePageViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/24/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit

class PhotoSlidePageViewController: UIPageViewController {

    var imageUrls: [String]!
    
    var index: Int!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Set the data source to itself
        dataSource = self
        
        if let startingViewController = viewControllerAtIndex(index) {
            setViewControllers([startingViewController], direction: .Forward, animated: true, completion:  nil)
        }

    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

extension PhotoSlidePageViewController: UIPageViewControllerDataSource {
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerAfterViewController viewController: UIViewController) ->UIViewController? {
            var index = (viewController as! TicketPhotoViewController).index
            index += 1
            return viewControllerAtIndex(index)
    }
    
    func pageViewController(pageViewController: UIPageViewController,
                            viewControllerBeforeViewController viewController: UIViewController) ->
        UIViewController? {
            var index = (viewController as! TicketPhotoViewController).index
            index -= 1
            return viewControllerAtIndex(index)
    }
    
    func viewControllerAtIndex(index: Int) -> TicketPhotoViewController? {
        if index == NSNotFound || index < 0 || index >= imageUrls.count {
            return nil
        }
        
        // Create a new view controller and pass suitable data.
        if let pageContentViewController =
            storyboard?.instantiateViewControllerWithIdentifier("TicketPhotoViewController") 
                as? TicketPhotoViewController {
            pageContentViewController.imageUrl = imageUrls[index]
            pageContentViewController.index = index
            return pageContentViewController
        }
        return nil }
}
