//
//  DetailViewController.swift
//  SingleEntrySwift
//
//  Created by Eric Glaenzer on 11/17/14.
// Copyright 2015 Socket Mobile, Inc.
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.

import UIKit

class DetailViewController: UIViewController,ScanApiHelperDelegate {
    let noScannerConnected = "No scanner connected"
    var scanners : [NSString] = []  // keep a list of scanners to display in the status
    var softScanner : DeviceInfo?  // keep a reference on the SoftScan Scanner
    
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var decodedData: UITextField!
    @IBOutlet weak var softScanTrigger: UIButton!

    var detailItem: AnyObject?
    var showSoftScanOverlay = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        softScanTrigger.isHidden = true;

    }
    
    override func viewDidAppear(_ animated: Bool) {
        // if we are showing the SoftScan Overlay view we don't
        // want to push our delegate again when our view becomes active
        if showSoftScanOverlay == false {
            // since we use ScanApiHelper in shared mode, we push this
            // view controller delegate to the ScanApiHelper delegates stack
            ScanApiHelper.shared().push(self)
        }
        showSoftScanOverlay = false
        displayScanners()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        // if we are showing the SoftScan Overlay view we don't
        // want to remove our delegate from the ScanApiHelper delegates stack
        if showSoftScanOverlay == false {
            // remove all the scanner names from the list
            // because in ScanApiHelper shared mode we will receive again
            // the deviceArrival for each connected scanner once this view
            // becomes active again
            scanners = []
            softScanTrigger.isHidden = true;
            ScanApiHelper.shared().pop(self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onSoftScanTrigger(_ sender: AnyObject) {
        if let scanner = softScanner as DeviceInfo! {
            showSoftScanOverlay = true
            ScanApiHelper.shared().postSetTriggerDevice(scanner, action: UInt8(kSktScanTriggerStart), target: self, response: #selector(DetailViewController.onSetTrigger(_:)))
        }
    }
    
    // MARK: - Utility functions
    func displayScanners(){
        if let status = connectionStatus {
            status.text = ""
            for scanner in scanners {
                status.text = status.text! + (scanner as String) + "\n"
            }
            if(scanners.count == 0){
                status.text = noScannerConnected
            }
        }
    }

    func displayErrorAlert(_ result: SKTRESULT, operation : String){
        if result != ESKT_NOERROR {
            let errorTxt = "Error \(result) while doing a \(operation)"
            let alert = UIAlertController(title: "ScanAPI Error", message: errorTxt, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    // MARK: - ScanApi complete callbacks
    
    // display an error message if the setTrigger failed
    // and reset the showSoftScanOverlay
    func onSetTrigger(_ scanObj : ISktScanObject){
        let result = scanObj.msg().result()
        displayErrorAlert(result, operation: "SetTrigger")
        if result != ESKT_NOERROR {
            showSoftScanOverlay = false
        }
    }
    
    // display an error message if the setOverlayView failed
    func onSetOverlayView(_ scanObj: ISktScanObject){
        let result = scanObj.msg().result()
        displayErrorAlert(result, operation: "SetOverlayView")
    }
    
    // MARK: - ScanApiHelperDelegate

    func onDecodedDataResult(_ result: Int, device: DeviceInfo!, decodedData: ISktScanDecodedData!) {
        print("onDecodedDataResult in the detail view")
        if result==ESKT_NOERROR {
            let rawData = decodedData.getData()
            let rawDataSize = decodedData.getSize()
            let data = Data(bytes: UnsafePointer<UInt8>(rawData!), count: Int(rawDataSize))
            print("Size: \(rawDataSize)")
            print("data: \(data)")
            let str = NSString(data: data, encoding: String.Encoding.utf8.rawValue)
            let string = str as! String
            print("Decoded Data \(string)")
            self.decodedData.text = string
        }
    }

    // since we use ScanApiHelper in shared mode, we receive a device Arrival
    // each time this view becomes active and there is a scanner connected
    func onDeviceArrival(_ result: SKTRESULT, device deviceInfo: DeviceInfo!) {
        print("onDeviceArrival in the detail view")
        let name = deviceInfo.getName()
        if(name?.caseInsensitiveCompare("SoftScanner") == ComparisonResult.orderedSame){
            softScanTrigger.isHidden = false;
            softScanner = deviceInfo
            
            // set the Overlay View context to give a reference to this controller
            if let scanner = softScanner as DeviceInfo! {
                let context : NSDictionary = [
                    String(cString: kSktScanSoftScanContext) : self
                ]
                ScanApiHelper.shared().postSetOverlayView(scanner, overlayView: context, target: self, response: #selector(DetailViewController.onSetOverlayView(_:)))
            }
        }
        scanners.append(deviceInfo.getName() as NSString)
        displayScanners()
    }

    func onDeviceRemoval(_ deviceRemoved: DeviceInfo!) {
        print("onDeviceRemoval in the detail view")
        var newScanners : [String] = []
        for scanner in scanners{
            if(scanner as String != deviceRemoved.getName()){
                newScanners.append(scanner as String)
            }
        }
        // if the scanner that is removed is SoftScan then
        // we nil its reference
        if softScanner != nil {
            if softScanner == deviceRemoved {
                softScanner = nil
            }
        }
        scanners=newScanners as [NSString]
        displayScanners()
    }
}
