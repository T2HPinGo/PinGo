//
//  DateTimePickerViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 8/27/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import JTCalendar

class DateTimePickerViewController: UIViewController {
    //MARK: - Outlets and Variables
    
    @IBOutlet weak var popupView: UIView!
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    @IBOutlet weak var displayView: UIView!
    @IBOutlet weak var previousMonthLabel: UILabel!
    @IBOutlet weak var nextMonthLabel: UILabel!
    @IBOutlet weak var timePicker: UIDatePicker!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var confirmButton: UIButton!
    
    
    var calendarManager = JTCalendarManager()
    
    var todayDate = NSDate()
    var datesSelected: [NSDate] = []
    var chosenDate: NSDate? //save the chosen date
    var chosenTime: NSDate? //save the chosen time
    var months: [NSDate] = [] //this is use to display the value of next month and previous month in the menu bar
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self  //if you dont't add this, the gradient view will not show up
    }
    
    //MARK: Load Views
    override func viewDidLoad() {
        super.viewDidLoad()
        
        calendarManager.delegate = self
        
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(todayDate)
        
        setupAppearance()
        
        //add gesture so user can close the popup by tapping out side the popup view
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self //if dont add this line, it's just going to dismiss the popup anywhere user taps
        view.addGestureRecognizer(gestureRecognizer)
        
        //initially make the time picker invisible and confirmButton
        timePicker.hidden = true
        confirmButton.hidden = true
    }
    
    func close() {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        popupView.layer.cornerRadius = 10
        popupView.layer.masksToBounds = true
        view.backgroundColor = UIColor.clearColor()
        
        //close button
        closeButton.layer.cornerRadius = closeButton.frame.size.width / 2
        closeButton.layer.masksToBounds = true
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.borderWidth = 2
        
        //confirm button
        confirmButton.layer.cornerRadius = 10
        confirmButton.backgroundColor = AppThemes.appColorTheme
        confirmButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        confirmButton.titleLabel?.font = AppThemes.helveticaNeueLight15
        
        //calendar
        calendarMenuView.backgroundColor = UIColor.whiteColor()
        calendarContentView.backgroundColor = UIColor.whiteColor()
        displayView.backgroundColor = AppThemes.appColorTheme
        
        //setUp monthLabel
        previousMonthLabel.textColor = UIColor.lightGrayColor()
        previousMonthLabel.font = AppThemes.oswaldRegular14
        previousMonthLabel.textAlignment = .Left
        
        nextMonthLabel.textColor = UIColor.lightGrayColor()
        nextMonthLabel.font = AppThemes.oswaldRegular14
        nextMonthLabel.textAlignment = .Right
    }
    
    //MARK: - Actions
    
    @IBAction func onClose(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

//MARK: - JTCalendarDelegate
extension DateTimePickerViewController: JTCalendarDelegate {
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        let dayViewJT = dayView as! JTCalendarDayView
        let normalDateTextColor = UIColor.blackColor()
        let selectedDateTextColor = UIColor.whiteColor()
        dayViewJT.textLabel.font = AppThemes.oswaldRegular13

        //appearance for today date
        if calendarManager.dateHelper.date(todayDate, isTheSameDayThan: dayViewJT.date) {
            dayViewJT.circleView.hidden = false
            dayViewJT.circleView.backgroundColor = isInDatesSelected(todayDate) ? AppThemes.appColorTheme : AppThemes.backgroundColorGray
            dayViewJT.textLabel.textColor = isInDatesSelected(todayDate) ? selectedDateTextColor : normalDateTextColor
        } else if isInDatesSelected(dayViewJT.date) {
            //appearance for selected dates
            dayViewJT.circleView.hidden = false
            dayViewJT.circleView.backgroundColor =  AppThemes.appColorTheme
            dayViewJT.circleView.layer.cornerRadius = dayViewJT.circleView.frame.width / 2
            dayViewJT.textLabel.textColor = selectedDateTextColor
        } else if calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayViewJT.date) {
            //appearance for dates in the same month
            dayViewJT.circleView.hidden = true
            dayViewJT.dotView.backgroundColor = UIColor.redColor()
            dayViewJT.textLabel.textColor = normalDateTextColor
        } else {
            //appearance for dates that from other months
            dayViewJT.circleView.hidden = true
            dayViewJT.textLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        let dayViewJT = dayView as! JTCalendarDayView
        
        //if the currently selected date is already in the datesSelected array, then remove it from the array
        if isInDatesSelected(dayViewJT.date) {
            let index = datesSelected.indexOf(dayViewJT.date)
            datesSelected.removeAtIndex(index!)
            calendarManager.reload()
            
            //also remove it from the eventTimeArrays
//            let dateString = getStringFromDateMonthDayYear(dayViewJT.date)
//            eventTimes.removeValueForKey(dateString)
            
            //remove the circle view from the deseleted date
            dayViewJT.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
            UIView.animateWithDuration(0.3, animations: {
                dayViewJT.circleView.transform = CGAffineTransformIdentity
            })
        } else {
            datesSelected.append(dayViewJT.date)
            
            calendarManager.reload()
            dayViewJT.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
            UIView.animateWithDuration(0.3, animations: {
                dayViewJT.circleView.transform = CGAffineTransformIdentity
            })
        }
        
        //load the previous/next page if touch a day from another month
        if !calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayViewJT.date) {
            //if the day selected is from next month then load next month
            if calendarContentView.date.compare(dayViewJT.date) == .OrderedAscending {
                calendarContentView.loadNextPageWithAnimation()
            } else {
                calendarContentView.loadPreviousPageWithAnimation()
            }
        }
        
        //make the time picker visible when at least one date has been selected
        if datesSelected.count == 0 {
            timePicker.hidden = true
            confirmButton.hidden = true
        } else {
            timePicker.hidden = false
            confirmButton.hidden = false
        }
        
        //asign selected date for chosenDate
        if let date = datesSelected.first {
            chosenDate = date
            print(chosenDate)
        }
        //update the numberofDatesSelectedLabel
        //updateNumbersOfDatesSelected()
    }
    
    //format the month label of menu view
    func calendarBuildMenuItemView(calendar: JTCalendarManager!) -> UIView! {
        let label = UILabel.init(frame: .zero)
        label.textAlignment = .Center
        label.textColor = AppThemes.appColorTheme
        label.font = AppThemes.oswaldRegular17
        
        return label
        
        //        let frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.calendarMenuView.frame.height)
        //        let menuView = CalendarMenuView(frame: frame)
        //
        //        menuView.labelLeft.textAlignment = .Left
        //        menuView.labelLeft.font = AppThemes.TitleFontSmallOswald
        //        menuView.labelLeft.textColor = AppThemes.TextColorGray
        //        menuView.labelLeft.backgroundColor = UIColor.greenColor()
        //
        //        menuView.labelMidle.textAlignment = .Center
        //        menuView.labelMidle.font = AppThemes.TitleFontSmallOswald
        //        menuView.labelMidle.textColor = AppThemes.TextColorRed
        //        menuView.labelMidle.backgroundColor = UIColor.redColor()
        //
        //        menuView.labelRight.textAlignment = .Right
        //        menuView.labelRight.font = AppThemes.TitleFontSmallOswald
        //        menuView.labelRight.textColor = AppThemes.TextColorGray
        //        menuView.labelRight.backgroundColor = UIColor.blueColor()
        
        //        return menuView
    }
    
    
    
    //format od the text of menuView
    func calendar(calendar: JTCalendarManager!, prepareMenuItemView menuItemView: UIView!, date: NSDate!) {
        guard let view = menuItemView as? UILabel else {
            return
        }
        
        months.append(date)
        
        view.text = getStringFromDate(date, withFormat: DateStringFormat.MMM_yyyy).uppercaseString
        
        while months.count == 3 {
            
            previousMonthLabel.text = getStringFromDate(months[0], withFormat: DateStringFormat.MMM).uppercaseString
            nextMonthLabel.text = getStringFromDate(months[2], withFormat: DateStringFormat.MMM).uppercaseString
            months.removeAll() //remove everything from this array so when user swipe to a different month, this does not add up
            break
        }
    }
    
    //MARK: - Helpers
    
    //check if a selected dats is in the datesSelected array
    func isInDatesSelected(date: NSDate) -> Bool {
        for dateSelected in datesSelected {
            if calendarManager.dateHelper.date(dateSelected, isTheSameDayThan: date) {
                return true
            }
        }
        return false
    }
}


//MARK: - EXTENSION: Animations for Popup View
extension DateTimePickerViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController,
                                                          presentingViewController presenting: UIViewController,
                                                                                   sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationViewController(presentedViewController: presented, presentingViewController: presenting)
    }
    
    func animationControllerForPresentedController(presented: UIViewController,
                                                   presentingController presenting: UIViewController,
                                                                        sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HBounceAnimationController()
    }
    
    func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return T2HRotateOutAnimationController()
    }
}

extension DateTimePickerViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(gestureRecognizer: UIGestureRecognizer, shouldReceiveTouch touch: UITouch) -> Bool {
        //return true if user touch any where but the popupView
        return touch.view === self.view
    }
}
