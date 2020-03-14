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

/* ###################################################################################################################################### */
// MARK: - Main SDK Peripheral Variant Computed Properties -
/* ###################################################################################################################################### */
/**
 This is the internal implementation of the SDK for the Peripheral Mode.
 
 **IMPORTANT NOTE:** Peripheral Mode is not supported for WatchOS or TVOS. This file is only included in the iOS and MacOS framework targets.
 */
internal extension ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
     This is a specific cast of the manager object that wil be attached to this instance.
     */
    var peripheralManagerInstance: CBPeripheralManager! {
        managerInstance as? CBPeripheralManager
    }

    /* ################################################################## */
    /**
     We override the typeless stored property with a computed one, and instantiate our manager, the first time through.
     */
    override var _managerInstance: Any! {
        get {
            if nil == super._managerInstance {
                super._managerInstance = CBPeripheralManager()
                peripheralManagerInstance.delegate = self   // TVOS doesn't seem to have a proper delegate initializer, so we have an extra step, here.
            }
            
            return super._managerInstance
        }
        
        set {
            super._managerInstance = newValue
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Instance Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Peripheral {
    /* ################################################################## */
    /**
     This method will load or update a given Service with new or updated Characteristics.
     
     - parameter inMutableServiceInstance: The Service that we are adding the Characteristics to.
     */
    func _setCharacteristicsForThisService(_ inMutableServiceInstance: CBMutableService) {
        let questionProperties: CBCharacteristicProperties = [.writeWithoutResponse]
        let answerProperties: CBCharacteristicProperties = [.read, .notify]
        let permissions: CBAttributePermissions = [.readable, .writeable]

        let questionCharacteristic = CBMutableCharacteristic(type: _static_ITCB_SDK_8BallService_Question_UUID, properties: questionProperties, value: nil, permissions: permissions)
        let answerCharacteristic = CBMutableCharacteristic(type: _static_ITCB_SDK_8BallService_Answer_UUID, properties: answerProperties, value: nil, permissions: permissions)
        
        inMutableServiceInstance.characteristics = [questionCharacteristic, answerCharacteristic]
    }
    
    /* ################################################################## */
    /**
     This sends the "An answer was successfully sent" message to all registered observers.

     - parameters:
        - device: The Central device
        - answer: The answer that was sent
        - toQuestion: The question that was asked
     */
    func _sendSuccessInSendingAnswerToAllObservers(device inDevice: ITCB_Device_Central_Protocol, answer inAnswer: String, toQuestion inToQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.answerSentToDevice(inDevice, answer: inAnswer, toQuestion: inToQuestion)
            }
        }
    }
    
    /* ################################################################## */
    /**
     This sends the "A question was asked" message to all registered observers.
     
     - parameters:
        - device: The Central device
        - question: The question that was asked
     */
    func _sendQuestionAskedToAllObservers(device inDevice: ITCB_Device_Central_Protocol, question inQuestion: String) {
        observers.forEach {
            if let observer = $0 as? ITCB_Observer_Peripheral_Protocol {
                observer.questionAskedByDevice(inDevice, question: inQuestion)
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - CBPeripheralManagerDelegate Methods -
/* ###################################################################################################################################### */
extension ITCB_SDK_Peripheral: CBPeripheralManagerDelegate {
    /* ################################################################## */
    /**
     This method is required by the Core Bluetooth system. It informs the delegate of a state change, in the CB manager instance.
     
     - parameter inPeripheralManager: The Peripheral Manager that experienced the change.
     */
    public func peripheralManagerDidUpdateState(_ inPeripheralManager: CBPeripheralManager) {
        assert(inPeripheralManager === managerInstance)   // Make sure that we are who we say we are...
        // Once we are powered on, we can start advertising.
        if .poweredOn == inPeripheralManager.state {
            // Make sure that we have a true Peripheral Manager (should never fail, but it pays to be sure).
            if let manager = peripheralManagerInstance {
                assert(manager === inPeripheralManager)
                // We create an instance of a mutable Service. This is our primary Service.
                let mutableServiceInstance = CBMutableService(type: _static_ITCB_SDK_8BallServiceUUID, primary: true)
                // We set up empty Characteristics.
                _setCharacteristicsForThisService(mutableServiceInstance)
                // Add it to our manager instance.
                inPeripheralManager.add(mutableServiceInstance)
                // We have our primary Service in place. We can now advertise it. We announce that we can be connected.
                inPeripheralManager.startAdvertising([CBAdvertisementDataServiceUUIDsKey: [mutableServiceInstance.uuid],
                                                      CBAdvertisementDataLocalNameKey: localName
                ])
            }
        }
    }
}

/* ###################################################################################################################################### */
// MARK: - Central Device Base Class -
/* ###################################################################################################################################### */
/**
 We need to keep in mind that Central objects are actually owned by Peripheral SDK instances.
 */
internal class ITCB_SDK_Device_Central: ITCB_SDK_Device, ITCB_Device_Central_Protocol {
    /// This is the Peripheral SDK that "owns" this device.
    internal var owner: ITCB_SDK_Peripheral!
    
    /// This is the Central Core Bluetooth device associated with this instance.
    internal var peripheralDeviceInstance: CBCentral! {
        _peerInstance as? CBCentral
    }

    /* ################################################################## */
    /**
     Send the answer to the Central.

     - parameter inAnswer: The answer.
     - parameter toQuestion: The question that was be asked.
     */
    public func sendAnswer(_ inAnswer: String, toQuestion inToQuestion: String) {
    }
}
