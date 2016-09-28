//
//  ScanApiHelperExtension.swift
//  SingleEntrySwift
//
//
//  This file is just an example to show how to extend ScanApiHelper
//  using swift to send a get or set property
//
//
//  Created by Eric Glaenzer on 9/22/16.
//  Copyright © 2016 Socket Mobile, Inc. All rights reserved.
//

import Foundation

extension ScanApiHelper
{
    // this makes the scanner vibrate if vibrate mode is supported by the scanner
    func postSetDataConfirmationOkDevice(_ device: DeviceInfo, target: NSObject, response :Selector){
        let deviceHandle = device.getSktScanDevice()
        let scanObj = SktClassFactory.createScanObject()
        scanObj?.property().setID(kSktScanPropIdDataConfirmationDevice)
        scanObj?.property().setType(kSktScanPropTypeUlong)
        scanObj?.property().setUlong(SKTDATACONFIRMATION(0, UInt8(kSktScanDataConfirmationRumbleGood), UInt8(kSktScanDataConfirmationBeepGood), UInt8(kSktScanDataConfirmationLedGreen)))
        let getCommand = false // this is a Set property command
        let command = CommandContext(param: getCommand, scanObj: scanObj, scanDevice: deviceHandle, device: device, target: target, response: response)
        
        addCommand(command)
        
    }
}
