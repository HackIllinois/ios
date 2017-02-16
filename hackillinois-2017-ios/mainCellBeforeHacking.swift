//
//  mainCellBeforeHacking.swift
//  hackillinois-2017-ios
//
//  Created by Minhyuk Park on 2/5/17.
//  Copyright © 2017 Shotaro Ikeda. All rights reserved.
//

import UIKit

class mainCellBeforeHacking: UITableViewCell {
    
    @IBOutlet weak var hoursLabel: UILabel!
    @IBOutlet weak var minutesLabel: UILabel!
    @IBOutlet weak var secondsLabel: UILabel!
    
    var mTimer = Timer()
    
    var timeRemaining: Int = 0
    var secondsLeft: Int = 0
    var minutesLeft: Int = 0
    var hoursLeft: Int = 0
    
    /* if timer is not invalidated the count down clock will go down by two seconds every second */
    override func prepareForReuse() {
        mTimer.invalidate();
        mTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(mainCell.updateCounter), userInfo: nil, repeats: true);
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }
    
    /* call the updateCounter function every second */
    func timeStart(){
        mTimer = Timer.scheduledTimer(timeInterval: 1, target:self, selector: #selector(mainCell.updateCounter), userInfo: nil, repeats: true)
    }
    
    /* decrement seceonds by one and make sure the timer does not overflow */
    func updateCounter() {
        if(secondsLeft == 1 && minutesLeft == 0 && hoursLeft == 0) {
            mTimer.invalidate()
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            if(appDelegate.funcList["HomeViewRefresh"] != nil) {
                appDelegate.funcList["HomeViewRefresh"]!()
            }
        }else {
            if(secondsLeft == 0){
                secondsLeft = 59
                if(minutesLeft != 0) {
                    minutesLeft -= 1
                }
            }else{
                secondsLeft -= 1
            }
            if(minutesLeft == 0){
                if(hoursLeft != 0) {
                    minutesLeft = 59
                    hoursLeft -= 1
                }
            }
            hoursLabel.text = hoursLeft.description;
            minutesLabel.text = minutesLeft.description;
            secondsLabel.text = secondsLeft.description;
        }
    }
    
    func getHours(timeInSeconds: Int) -> Int{
        let hour = (timeInSeconds / 3600)
        return hour
    }
    
    func getMinutes(timeInSeconds: Int) -> Int{
        let minute = ((timeInSeconds % 3600) / (60))
        return minute
    }
    
    func getSeconds(timeInSeconds: Int) -> Int{
        let second = (timeInSeconds % 60)
        return Int(second)
    }
    
    
}
