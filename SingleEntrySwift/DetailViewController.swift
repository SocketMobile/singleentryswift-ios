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
    var scanners : [NSString] = []
    @IBOutlet weak var connectionStatus: UILabel!
    @IBOutlet weak var decodedData: UITextField!

    var detailItem: AnyObject?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        ScanApiHelper.sharedScanApiHelper().pushDelegate(self)
        displayScanners()

    }

    override func viewDidDisappear(animated: Bool) {
        ScanApiHelper.sharedScanApiHelper().popDelegate(self)
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

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

    // MARK: - ScanApiHelperDelegate

    func onDecodedDataResult(result: Int, device: DeviceInfo!, decodedData: ISktScanDecodedData!) {
        print("onDecodedDataResult in the detail view")
        if result==ESKT_NOERROR {
            let rawData = decodedData.getData()
            let rawDataSize = decodedData.getDataSize()
            let data = NSData(bytes: rawData, length: Int(rawDataSize))
            print("Size: \(rawDataSize)")
            print("data: \(data)")
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            let string = str as! String
            print("Decoded Data \(string)")
            self.decodedData.text = string
        }
    }

    func onDeviceArrival(result: SKTRESULT, device deviceInfo: DeviceInfo!) {
        print("onDeviceArrival in the detail view")
        scanners.append(deviceInfo.getName())
        displayScanners()
    }

    func onDeviceRemoval(deviceRemoved: DeviceInfo!) {
        print("onDeviceRemoval in the detail view")
        var newScanners : [String] = []
        for scanner in scanners{
            if(scanner != deviceRemoved.getName()){
                newScanners.append(scanner as String)
            }
        }
        scanners=newScanners
        displayScanners()
    }
}
