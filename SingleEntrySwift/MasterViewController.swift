//
//  MasterViewController.swift
//  SingleEntrySwift
//
//  IN ORDER TO USE SCANAPIHELPER IN YOUR SWIFT CODE, YOU WILL NEED TO ADD:
//  #import "ScanApiHelper.h"
//  IN YOUR SWIFT BRIDGING HEADER .H FILE
//  AND MAKE SURE THIS BRIDGING HEADER .H FILE IS SET IN YOUR PROJECT SETTINGS:
//  "OBJECTIVE C BRIDGING HEADER"
//
//  DON'T FORGET TO ADD com.socketmobile.chs in the Supported external accessory protocols
//  IN THE PROJECT INFO
//  AND TO ADD THE FOLLOWING FRAMEWORKS:
//  ExternalAccessory.framework
//  AudioToolbox.framework
//  AVFoundation.framework
//  And of course libScanAPI.a
//
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
//
//
import UIKit


class MasterViewController: UITableViewController,ScanApiHelperDelegate {

    var detailViewController: DetailViewController? = nil
    var objects = NSMutableArray()

    // ScanAPI Helper members initialization
    // WE WANT TO SHARE SCANAPIHELPER WITH ANOTHER VIEW
    // SO WE USE THE SHARED SCANAPIHELPER STATIC METHOD
    // OTHERWISE WE COULD HAVE JUST USE:
    // scanApiHelper = ScanApiHelper()
    // IF WE DON'T NEED ScanApiHelper IN OTHER VIEWS
    var scanApiHelper = ScanApiHelper.sharedScanApiHelper()
    var scanApiHelperConsumer = NSTimer()


    override func awakeFromNib() {
        super.awakeFromNib()
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            self.clearsSelectionOnViewWillAppear = false
            self.preferredContentSize = CGSize(width: 320.0, height: 600.0)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        // setup ScanAPI
        scanApiHelperConsumer=NSTimer.scheduledTimerWithTimeInterval(0.2, target: self, selector: Selector("onScanApiHelperConsumer"), userInfo: nil, repeats: true)
        // there is now a stack of delegates the last push is the
        // delegate active, when a new view requiring notifications from the
        // scanner, then push its delegate and pop its delegate when the
        // view is done
        scanApiHelper.pushDelegate(self)
        scanApiHelper.open()

        // add SingleEntry item from the begining in the main list
        objects.insertObject("SingleEntry", atIndex: 0);
        let indexPath=NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)


    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    func insertNewObject(sender: AnyObject) {
        objects.insertObject(NSDate(), atIndex: 0)
        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
        self.tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                if let object = objects[indexPath.row] as? NSString {
                    let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController
                    controller.detailItem = object
                    controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
                    controller.navigationItem.leftItemsSupplementBackButton = true
                }
            }
        }
    }

    // MARK: - Table View

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return objects.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("Cell", forIndexPath: indexPath) as UITableViewCell

        var description = "dont know"
        if let object = objects[indexPath.row] as? NSString {
            description=object as String;
        }
        cell.textLabel?.text = description
        return cell
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return false
    }

    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            objects.removeObjectAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
        }
    }

    // MARK: - ScanApiHelper Consumer
    func onScanApiHelperConsumer(){
        scanApiHelper.doScanApiReceive()
    }

    // MARK: - ScanApiHelperDelegate

    func onDeviceArrival(result: SKTRESULT, device deviceInfo: DeviceInfo!) {
        print("Main view device arrival:\(deviceInfo.getName())")
    }

    func onDeviceRemoval(deviceRemoved: DeviceInfo!) {
        print("Main view device removal:\(deviceRemoved.getName())")
    }

    // if the onDecodedDataResult is used then this onDecodedData
    // won't be called by ScanApiHelper.
//    func onDecodedData(device: DeviceInfo!, decodedData: ISktScanDecodedData!) {
//        let rawData = decodedData.getData()
//        let rawDataSize = decodedData.getDataSize()
//        let data = NSData(bytes: rawData, length: Int(rawDataSize))
//        let str = NSString(data: data, encoding: NSUTF8StringEncoding)
//        let string = str as String
//        println("Decoded Data \(string)")
//    }

    // This is the new onDecodedDataResult to retrieve the decoded data received
    // from the scanner. This one has a result field that should be checked before
    // using the decoded data. It would be set to ESKT_CANCEL if the user
    // taps on the cancel button in the SoftScan View Finder
    func onDecodedDataResult(result: Int, device: DeviceInfo!, decodedData: ISktScanDecodedData!) {
        if result==ESKT_NOERROR {
            let rawData = decodedData.getData()
            let rawDataSize = decodedData.getDataSize()
            let data = NSData(bytes: rawData, length: Int(rawDataSize))
            print("Size: \(rawDataSize)")
            print("data: \(data)")
            let str = NSString(data: data, encoding: NSUTF8StringEncoding)
            let string = str as! String
            print("Decoded Data \(string)")
        }
    }

    func onError(result: SKTRESULT) {
        print("Receive a ScanApi error: \(result)")
    }

    func onErrorRetrievingScanObject(result: SKTRESULT) {
        print("Receive a ScanApi error while retrieving a ScanObject: \(result)")
    }

    func onScanApiInitializeComplete(result: SKTRESULT) {
        print("Result of ScanAPI initialization: \(result)")
    }

    func onScanApiTerminated() {
        print("ScanAPI has terminated")
    }
}
