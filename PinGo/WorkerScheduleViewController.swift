//
//  WorkerScheduleViewController.swift
//  PinGo
//
//  Created by Hien Quang Tran on 9/6/16.
//  Copyright © 2016 Hien Tran. All rights reserved.
//

import UIKit
import JTCalendar
import Alamofire

class WorkerScheduleViewController: UIViewController {

    //MARK: - Outlets and Variables
    
    @IBOutlet weak var calendarMenuView: JTCalendarMenuView!
    @IBOutlet weak var calendarContentView: JTHorizontalCalendarView!
    
    @IBOutlet weak var previousMonthLabel: UILabel!
    @IBOutlet weak var nextMonthLabel: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    var calendarManager = JTCalendarManager()
    
    var todayDate = NSDate()
    var chosenDate: NSDate? //save the chosen date
    var months: [NSDate] = [] //this is use to display the value of next month and previous month in the menu bar
    
    var ticketList: [Ticket] = []
    var schedule: [NSDate: [Ticket]] = [:]
    var datesScheduled: [NSDate] = []
    
    //MARK: Load Views
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadDataFromAPI()
        
        tableView.delegate = self
        tableView.dataSource = self
        
        //calendar
        calendarManager.delegate = self
        calendarManager.menuView = calendarMenuView
        calendarManager.contentView = calendarContentView
        calendarManager.setDate(todayDate)
        
        setupAppearance()
    }
    
    //MARK: - Helpers
    func setupAppearance() {
        
        //calendar
        calendarMenuView.backgroundColor = UIColor.whiteColor()
        calendarContentView.backgroundColor = UIColor.whiteColor()
        
        //setUp monthLabel
        previousMonthLabel.textColor = UIColor.lightGrayColor()
        previousMonthLabel.font = AppThemes.oswaldRegular14
        previousMonthLabel.textAlignment = .Left
        
        nextMonthLabel.textColor = UIColor.lightGrayColor()
        nextMonthLabel.font = AppThemes.oswaldRegular14
        nextMonthLabel.textAlignment = .Right
    }
    
    func loadDataFromAPI(){
        var parameters = [String : AnyObject]()
        parameters["category"] = Worker.currentUser?.category
        parameters["idWorker"] = Worker.currentUser?.id
        
        Alamofire.request(.POST, "\(API_URL)\(PORT_API)/v1/ticketOnCategory", parameters: parameters).responseJSON { response  in
            if let _ = response.response {
                
                let JSONArrays  = response.result.value!["data"] as! [[String: AnyObject]]
                for JSONItem in JSONArrays {
                    let ticket = Ticket(data: JSONItem)
                    
                    if ticket.status == Status.InService {
                        self.ticketList.append(ticket)
                        self.addSchedule(ticket)
                        self.addDateScheduled(ticket)
                    }
                }
                self.calendarManager.reload() //put here so the the dotViews show up on the calendar after receive data from server
                
            } else {
                let alert = UIAlertController(title: "Network Error", message: "We couldn't load you ticket schedule. Please check your internet connection", preferredStyle: .Alert)
                let action = UIAlertAction(title: "OK", style: .Default, handler: nil)
                alert.addAction(action)
                self.presentViewController(alert, animated: true, completion: nil)
            }
        }
    }
    
    //use this to present data on tableview
    func addSchedule(ticket: Ticket) {
        let date = getDateFromString(ticket.dateBegin, withFormat: DateStringFormat.DD_MMM_YYYY)

        if let dateValid = date {
            //if the key:value pair doesn't exist, create a new one. Otherwise just simply append the ticket to the ticket array corresponding to that date
            if schedule[dateValid] == nil {
                schedule[dateValid] = [ticket]
            } else {
                schedule[dateValid]!.append(ticket)
            }
            
            //sort ticket array so time will be in ascending order
            self.schedule[dateValid] = self.schedule[dateValid]?.sort({ (ticket1, ticket2) -> Bool in
                ticket1.timeBegin < ticket2.timeBegin
            })
        }
    }
    
    //use this to show dot view in calendar
    func addDateScheduled(ticket: Ticket) {
        let date = getDateFromString(ticket.dateBegin, withFormat: DateStringFormat.DD_MMM_YYYY)
        
        if let dateValid = date {
            datesScheduled.append(dateValid)
        }
    }
}

//Mark: -
extension WorkerScheduleViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let chosenDate = chosenDate {
            return schedule[chosenDate]?.count ?? 0
        }
        
        return 0
    }

    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell =  tableView.dequeueReusableCellWithIdentifier("ScheduleCell", forIndexPath: indexPath) as! ScheduleCell
        
        if let chosenDate = chosenDate {
            let ticket = schedule[chosenDate]![indexPath.row]
            cell.timeLabel.text = ticket.timeBegin
            cell.ticketTitleLabel.text = ticket.title
            
            
//            cell.timeLabel.text = ticket.timeBegin.compare(NSDate(timeIntervalSince1970: 0.0)) == NSComparisonResult.OrderedSame  ? "ASAP" : getStringFromDate(time!, withFormat: DateStringFormat.HH_mm)
            return cell
        }
        
        return UITableViewCell()
    }
}

//MARK: - JTCalendarDelegate
extension WorkerScheduleViewController: JTCalendarDelegate {
    func calendar(calendar: JTCalendarManager!, prepareDayView dayView: UIView!) {
        
        let dayViewJT = dayView as! JTCalendarDayView
        let normalDateTextColor = UIColor.blackColor()
        let selectedDateTextColor = UIColor.whiteColor()
        dayViewJT.textLabel.font = AppThemes.oswaldRegular13
        dayViewJT.dotView.hidden = isInDatesScheduled(dayViewJT.date) ? false : true
        
        //appearance for today date
        if calendarManager.dateHelper.date(todayDate, isTheSameDayThan: dayViewJT.date) {
            dayViewJT.circleView.hidden = false
            dayViewJT.circleView.backgroundColor = calendarManager.dateHelper.date(todayDate, isTheSameDayThan: chosenDate) ? AppThemes.appColorTheme : AppThemes.backgroundColorGray
            dayViewJT.dotView.backgroundColor = calendarManager.dateHelper.date(todayDate, isTheSameDayThan: chosenDate) ? selectedDateTextColor : AppThemes.appColorTheme
            //dayViewJT.dotView.hidden = isInDatesScheduled(todayDate) ? false : true
            dayViewJT.textLabel.textColor = calendarManager.dateHelper.date(todayDate, isTheSameDayThan: chosenDate) ? selectedDateTextColor : normalDateTextColor
        } else if calendarManager.dateHelper.date(chosenDate, isTheSameDayThan: dayViewJT.date) {
            //appearance for selected dates
            dayViewJT.circleView.hidden = false
            dayViewJT.circleView.backgroundColor =  AppThemes.appColorTheme
            dayViewJT.circleView.layer.cornerRadius = dayViewJT.circleView.frame.width / 2
            dayViewJT.textLabel.textColor = selectedDateTextColor
            dayViewJT.dotView.backgroundColor = selectedDateTextColor
            //dayViewJT.dotView.hidden = isInDatesScheduled(chosenDate!) ? false : true
        } else if calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayViewJT.date) {
            //appearance for dates in the same month
            dayViewJT.circleView.hidden = true
            dayViewJT.textLabel.textColor = normalDateTextColor
            dayViewJT.dotView.backgroundColor = AppThemes.appColorTheme
            //dayViewJT.dotView.hidden = isInDatesScheduled(dayViewJT.date) ? false : true
        } else {
            //appearance for dates that from other months
            dayViewJT.circleView.hidden = true
            dayViewJT.textLabel.textColor = UIColor.lightGrayColor()
        }
    }
    
    func calendar(calendar: JTCalendarManager!, didTouchDayView dayView: UIView!) {
        let dayViewJT = dayView as! JTCalendarDayView
        
        //if user tap on the date that is already selected, remove the selection
        if !calendarManager.dateHelper.date(chosenDate, isTheSameDayThan: dayViewJT.date) {
            chosenDate = dayViewJT.date
            tableView.reloadData()
        }
        
        // Animation for the circleView
        dayViewJT.circleView.transform = CGAffineTransformScale(CGAffineTransformIdentity, 0.1, 0.1)
        UIView.animateWithDuration(0.3, animations: {
            dayViewJT.circleView.transform = CGAffineTransformIdentity
            self.calendarManager.reload()
        })
        
        //load the previous/next page if touch a day from another month
        if !calendarManager.dateHelper.date(calendarContentView.date, isTheSameMonthThan: dayViewJT.date) {
            //if the day selected is from next month then load next month
            if calendarContentView.date.compare(dayViewJT.date) == .OrderedAscending {
                calendarContentView.loadNextPageWithAnimation()
            } else {
                calendarContentView.loadPreviousPageWithAnimation()
            }
        }
    }
    
    //format the month label of menu view
    func calendarBuildMenuItemView(calendar: JTCalendarManager!) -> UIView! {
        let label = UILabel.init(frame: .zero)
        label.textAlignment = .Center
        label.textColor = AppThemes.appColorTheme
        label.font = AppThemes.oswaldRegular17
        
        return label
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
    
    func isInDatesScheduled(date: NSDate) -> Bool {
        for dateScheduled in datesScheduled {
            if calendarManager.dateHelper.date(dateScheduled, isTheSameDayThan: date) {
                return true
            }
        }
        return false
    }
}


