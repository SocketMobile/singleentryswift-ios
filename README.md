# SingleEntrySwift for iOS
This simple iOS app is a sample code for using ScanAPI SDK with a Swift
application.

## Prerequisites
This SDK uses CocoaPods. If it needs to be installed please check the CocoaPods
website for the most current instructions:
https://cocoapods.org/

Of course the Socket ScanAPI SDK is also required for this example to work.

## Documentation
The ScanAPI documentation can be found at:
http://www.socketmobile.com/docs/default-source/developer-documentation/scanapi.pdf?sfvrsn=2

## Installation
In order to get this application compiling and working out of the box, it is
recommended to unzip the ScanApiSDK-10.x.x.zip file at the same root as the
clone of this app, otherwise the relative path set in the project Podfile must
be updated to the actual location of the extracted SDK zip file.

ie:
```
/Documents
        /SingleEntrySwift
        /ScanApiSDK-10.x.x
```
Edit the SingleEntrySwift/Podfile and make sure the ScanAPI version matches with
the one that has been unzipped.

From a Terminal window, type:
```sh
 pod install
```
in the SingleEntrySwift directory.

Load the SingleEntrySwift workspace (NOT PROJECT) in Xcode and compile and run.

To recap:
```sh
cd ~/Documents
unzip ScanApiSDK-10.2.x.zip -d ScanApiSDK-10.2.x
git clone git@github.com:socketmobile/singleentryswift-ios.git SingleEntrySwift
cd SingleEntrySwift
nano Podfile
pod install
```
## IMPORTANT NOTES
In Xcode the debug information format in the build options is set by default to
'DWARF with DSYM file'. This is causing numerous warnings. It is recommended to
set it back to 'DWARF' instead.

## Description
SingleEntrySwift displays a scanner connection status. When a scanner is
connected, its friendly name is displayed.
The edit box receives the decoded data from the scanner.


## Implementation
Since the ScanApiHelper is written in Objective-C, a bridging header file is
required in order to add ScanAPI into a Swift project.
This header file should contain only one line to include ScanApiHelper:
```Xcode
#import "ScanApiHelper.h"
```
In this simple example the ScanApiHelper is "attached" to the main view
controller. This main view controller derives from the ScanApiHelperDelegate
protocol and implements some of the delegate methods.

### ScanApiHelper shared feature
As a showcase, this particular example shows the ScanApiHelper shared feature.
The purpose of this feature is to share ScanApiHelper across the view hierarchy
without the need to pass between the views an explicit reference to
ScanApiHelper.
When a view using ScanApiHelper is active, it pushes itself as delegate using
the ScanApiHelper pushDelegate method which makes this view active to receive
notification from ScanApiHelper. The first notification received in
deviceArrival even though other views have already received this notification.
This indicates there is a scanner connected to the device. Once the view becomes
inactive, then it should call the ScanApiHelper popDelegate to remove itself
from receiving notification. At this point the prior view that had pushed its
delegate becomes the one receiving the notifications.  

### main view controller viewDidLoad
This handler opens ScanApiHelper just after pushing the delegate to itself
requiring the MainViewController to derive from the ScanApiHelperDelegate
protocol.
It starts a timer that will consume the asynchronous events coming from ScanApi.

### ScanApiHelperDelegate onScanApiInitializeConplete
This notification is received only when ScanApiHelper open is complete.
From that point on, ScanApiHelper is ready to send a receive to/from ScanApi.

### onDeviceArrival
This ScanApiHelperDelegate method is called when a scanner is successfully
detected on the host. The scanner can be SoftScan or any other Socket Mobile
scanners supported by ScanAPI.

### onDeviceRemoval
When a scanner is no longer available (disconnected), this delegate is invoked.

### onDecodedData(Result)
There are actually 2 onDecodedData delegates defined in ScanApiHelperDelegate.
The second one has the result as arguments and is the recommended one to use.

# ScanApiHelper
ScanApiHelper is provided as source code. It provides a set of very basic
features like enabling disabling barcode symbologies.

If a needed feature is not implemented by ScanApiHelper, the recommendation is
to create an extension of ScanApiHelper and copy paste a feature similar from
ScanApiHelper to the extended one.

Following this recommendation will prevent to loose the modifications at the
next update.
