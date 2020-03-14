/*
© Copyright 2020, Little Green Viper Software Development LLC

LICENSE:

MIT License

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy,
modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF
CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

Little Green Viper Software Development LLC: https://littlegreenviper.com
*/

import Foundation
import CoreBluetooth

/// This is the UUID we use for our "Magic 8-Ball" Service
internal let _static_ITCB_SDK_8BallServiceUUID = CBUUID(string: "8E38140A-27BE-4090-8955-4FC4B5698D1E")
/// This is the UUID for the "Question" String Characteristic
internal let _static_ITCB_SDK_8BallService_Question_UUID = CBUUID(string: "BDD37D7A-F66A-47B9-A49C-FE29FD235A77")
/// This is the UUID for the "Answer" String Characteristic
internal let _static_ITCB_SDK_8BallService_Answer_UUID = CBUUID(string: "349A0D7B-6215-4E2C-A095-AF078D737445")

/* ###################################################################################################################################### */
// MARK: - Main SDK Interface Base Class -
/* ###################################################################################################################################### */
/**
 This is an internal-scope extension of the public SDK class, containing the actual implementations that fulfill the protocol contract.
 
 Internal-scope methods and properties are indicated by a leading underscore (_) in the name.
 */
extension ITCB_SDK {    
    /* ################################################################## */
    /**
      Any error condition associated with this instance. It may be nil.
     */
    var _error: ITCB_Errors? { nil }
    
    /* ################################################################## */
    /**
     This is a base class cast of the manager object that wil be attached to this instance.
     */
    var managerInstance: CBManager! {
        _managerInstance as? CBManager
    }

    /* ################################################################## */
    /**
     This is true, if Core Bluetooth reports that the device Bluetooth interface is powered on and available for use.
     */
    var _isCoreBluetoothPoweredOn: Bool {
        guard let manager = managerInstance else { return false }
        return .poweredOn == manager.state
    }
    
    /* ################################################################## */
    /**
      This adds the given observer to the list of observers for this SDK object. If the observer is already registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to add.
     - returns: The newly-assigned UUID. Nil, if the observer was not added.
     */
    func _addObserver(_ inObserver: ITCB_Observer_Protocol) -> UUID! {
        if !isObserving(inObserver) {
            observers.append(inObserver)
            observers[observers.count - 1].uuid = UUID()    // This assigns a concrete UUID for use in comparing for removal and testing.
            return observers[observers.count - 1].uuid
        }
        return nil
    }
    
    /* ################################################################## */
    /**
     This removes the given observer from the list of observers for this SDK object. If the observer is not registered, nothing happens.
     
     - parameter inObserver: The Observer Instance to remove.
     */
    func _removeObserver(_ inObserver: ITCB_Observer_Protocol) {
        // There's a number of ways to do this. This way works fine.
        for index in 0..<observers.count where inObserver.uuid == observers[index].uuid {
            observers.remove(at: index)
            return
        }
    }
    
    /* ################################################################## */
    /**
     This checks the given observer, to see if it is currently observing this SDK instance.
     
     - parameter inObserver: The Observer Instance to check.
    
     - returns: True, if the observer is currently in the list of SDK observers.
     */
    func _isObserving(_ inObserver: ITCB_Observer_Protocol) -> Bool {
        for observer in observers where inObserver.uuid == observer.uuid {
            return true
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     This sends an error message to all registered observers.
     
     - parameter error: The error that we are sending.
     */
    func _sendErrorMessageToAllObservers(error inError: ITCB_Errors) {
        observers.forEach {
            $0.errorOccurred(inError, sdk: self)
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - General Device Base Class -
/* ###################################################################################################################################### */
/**
 This is the genaral base class for Central and Peripheral devices.
 */
internal class ITCB_SDK_Device {
    /// The name property to conform to the protocol.
    public var name: String = ""
    
    /// The error property to conform to the protocol.
    public var error: ITCB_Errors!
    
    /// This is an internal stored property that is used to reference a Core Bluetooth peer instance (either a Central or Peripheral), associated with this device.
    internal var _peerInstance: CBPeer!
    
    /* ################################################################## */
    /**
     This is a "faux Equatable" method. It allows us to compare something that is expressed only as a protocol instance with ourselves, without the need to be Equatable.
     
     - parameter inDevice: The device that we are comparing.
     
     - returns: True, if we are the device.
     */
    public func amIThisDevice(_ inDevice: ITCB_Device_Protocol) -> Bool {
        if let device = inDevice as? ITCB_SDK_Device {
            return device === self
        }
        
        return false
    }
    
    /* ################################################################## */
    /**
     This allows the user of an SDK to reject a connection attempt by another device (either a question or an answer).
     
     - parameter inReason: The reason for the rejection. It may be nil. If nil, .unkownError is assumed, with no error associated value.
     */
    public func rejectConnectionBecause(_ inReason: ITCB_RejectionReason! = .unknown(nil)) {
        /* ########### */
        // TODO: Put code in here to handle rejection.
        /* ########### */
    }
}
