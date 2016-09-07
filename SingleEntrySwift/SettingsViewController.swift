//
//  SettingsViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 10/27/15.
//  Copyright © 2015 Socket Mobile, Inc. All rights reserved.
//

import UIKit

class SettingsViewController: UIViewController, ScanApiHelperDelegate{
    var detailItem: AnyObject?

    @IBOutlet weak var softscan: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ScanApiHelper.sharedScanApiHelper().pushDelegate(self)
        // Do any additional setup after loading the view.
        
        // retrieve the current status of SoftScan
        ScanApiHelper.sharedScanApiHelper().postGetSoftScanStatus(self, response: #selector(SettingsViewController.onGetSoftScanStatus(_:)))
    }

    override func viewDidDisappear(animated: Bool) {
        ScanApiHelper.sharedScanApiHelper().popDelegate(self)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func changeSoftScan(sender: AnyObject) {
        if(!softscan.on){
            print("disabling SoftScan...")
            ScanApiHelper.sharedScanApiHelper().postSetSoftScanStatus(UInt8(kSktScanDisableSoftScan), target: self, response: #selector(SettingsViewController.onSetSoftScanStatus(_:)))
        }
        else{
            print("enabling SoftScan...")
            ScanApiHelper.sharedScanApiHelper().postSetSoftScanStatus(UInt8(kSktScanEnableSoftScan), target: self, response: #selector(SettingsViewController.onSetSoftScanStatus(_:)))
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
    
    // MARK: - ScanApiHelper results
    func onGetSoftScanStatus(scanObj: ISktScanObject!) {
        print("onGetSoftScanStatus received!")
        let result = scanObj.Msg().Result()
        print("Result:", result)
        if(result == ESKT_NOERROR){
            let status = Int(scanObj.Property().getByte())
            print("receive SoftScan status:",status)
            if ( status == kSktScanEnableSoftScan){
                softscan.on = true
            }
            else{
                softscan.on = false
                if(status == kSktScanSoftScanNotSupported){
                    ScanApiHelper.sharedScanApiHelper().postSetSoftScanStatus(UInt8(kSktScanSoftScanSupported), target: self, response: #selector(SettingsViewController.onSetSoftScanStatus(_:)))
                }
            }
        }
    }
    
    func onSetSoftScanStatus(scanObj: ISktScanObject){
        
    }
    
    // MARK: - ScanApiHelper Delegates
    /**
    * called each time a device connects to the host
    * @param result contains the result of the connection
    * @param newDevice contains the device information
    */
    func onDeviceArrival(result: SKTRESULT, device deviceInfo: DeviceInfo!) {
        print("Settings: Device Arrival")
    }
    
    /**
    * called each time a device disconnect from the host
    * @param deviceRemoved contains the device information
    */
    func onDeviceRemoval(deviceRemoved: DeviceInfo!) {
        print("Settings: Device Removal")
    }
    

}
