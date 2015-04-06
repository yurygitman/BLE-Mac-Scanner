//
//  ViewController.swift
//  MacAppIntro
//
//  Created by GrownYoda on 4/6/15.
//  Copyright (c) 2015 yuryg. All rights reserved.
//

import Cocoa
import CoreBluetooth

class ViewController: NSViewController, CBCentralManagerDelegate, CBPeripheralDelegate, NSTableViewDataSource {

    // 
    var starterArray:[AnyObject] = NSLocale.preferredLanguages()
    
    //  
    var myArray = ["One","Two","Three","Four"]

    //  BLE Stuff
    let myCentralManager = CBCentralManager()
    var peripheralArray = [CBPeripheral]() // create now empty array.

    var fullPeripheralArray = [("UUIDString","RSSI", "Name")]
    
    var myPeripheralDictionary:[String:(String, String, String)] = ["UUIDString":("UUIDString","RSSI", "Name")]
    
    var cleanAndSortedArray = [("UUIDString","RSSI", "Name")]

    
    
    //  UI Stuff
    @IBOutlet weak var inputText: NSTextField!
    @IBOutlet weak var outputText: NSTextField!
    @IBOutlet weak var labelStatus: NSTextField!
    @IBOutlet weak var tableView: NSTableView!
    
    
    @IBAction func scanButtonCell(sender: NSButtonCell) {
        
        println("sender.state" + String(sender.state) + "\r")
        
        if sender.state == 1{
            updateStatusLabel("Scannning")
            myCentralManager.scanForPeripheralsWithServices(nil, options: nil )   // call to scan for services

            
        } else {
            updateStatusLabel("Not Scanning")
            myCentralManager.stopScan()
        }
        
        
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override var representedObject: AnyObject? {
        didSet {
        // Update the view, if already loaded.
        }
    }

    
    // NSTableView
    
    func numberOfRowsInTableView(tableView: NSTableView) -> Int {
        return fullPeripheralArray.count
    }
    
    
    
    func tableView(tableView: NSTableView, objectValueForTableColumn tableColumn: NSTableColumn?, row: Int) -> AnyObject? {

        if tableColumn?.identifier == "first" {
            let myString = cleanAndSortedArray[row].0
            return myString
        }
        if tableColumn?.identifier == "second"{
            let myString = "\(cleanAndSortedArray[row].1)"
            return myString
        }
      
        if tableColumn?.identifier == "third"{
            let myString = "\(cleanAndSortedArray[row].2)"
            return myString

        }
    
            
            
        else{
            return "not id'ed"
        }
    }
    
//        
//        if tableColumn == 0 {
//          return myArray[row]
//        }  else {
//            let reverseArray = myArray.reverse()
//            return reverseArray[row]
//        }
//    }
    
    
    //MARK  CoreBluetooth Stuff
    
    
    
    // Put CentralManager in the main queue
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        myCentralManager = CBCentralManager(delegate: self, queue: dispatch_get_main_queue())
        
    }
    

    

    
    func centralManagerDidUpdateState(central: CBCentralManager!) {
        
        println("centralManagerDidUpdateState")
        
        /*
        typedef enum {
        CBCentralManagerStateUnknown  = 0,
        CBCentralManagerStateResetting ,
        CBCentralManagerStateUnsupported ,
        CBCentralManagerStateUnauthorized ,
        CBCentralManagerStatePoweredOff ,
        CBCentralManagerStatePoweredOn ,
        } CBCentralManagerState;
        */
        switch central.state{
        case .PoweredOn:
            updateStatusLabel("poweredOn")
            
            
        case .PoweredOff:
            updateStatusLabel("Central State PoweredOFF")
            
        case .Resetting:
            updateStatusLabel("Central State Resetting")
            
        case .Unauthorized:
            updateStatusLabel("Central State Unauthorized")
            
        case .Unknown:
            updateStatusLabel("Central State Unknown")
            
        case .Unsupported:
            updateStatusLabel("Central State Unsupported")
            
        default:
            updateStatusLabel("Central State None Of The Above")
            
        }
    }
    
    func updateStatusLabel(passedString: String ){
        labelStatus.stringValue = passedString
    }


func updateOutputText(passedString: String ){
       outputText.stringValue  = passedString + "\r" + outputText.stringValue
    }

    
    func centralManager(central: CBCentralManager!, didDiscoverPeripheral peripheral: CBPeripheral!, advertisementData: [NSObject : AnyObject]!, RSSI: NSNumber!) {
    
        // Refresh Entry or Make an New Entry into Dictionary
        let myUUIDString = peripheral.identifier.UUIDString
        let myRSSIString = String(RSSI.intValue)
        var myNameString = peripheral.name
        
        
        let myTuple = (myUUIDString, myRSSIString, "\(myNameString)")
        myPeripheralDictionary[myTuple.0] = myTuple
        
        // Clean Array
        fullPeripheralArray.removeAll(keepCapacity: false)
        
        // Tranfer Dictionary to Array
        for eachItem in myPeripheralDictionary{
                fullPeripheralArray.append(eachItem.1)
        }
        
        // Sort Array by RSSI
        //from http://www.andrewcbancroft.com/2014/08/16/sort-yourself-out-sorting-an-array-in-swift/
        cleanAndSortedArray = sorted(fullPeripheralArray,{
            (str1: (String,String,String) , str2: (String,String,String) ) -> Bool in
            return str1.1.toInt() > str2.1.toInt()
        })
        

        

        
        updateOutputText("\r")
        updateOutputText("UUID: \(peripheral)")
        updateOutputText("RSSI: \(RSSI)")
        updateOutputText("Name: \(peripheral.identifier.UUIDString)")

        tableView.reloadData()
        
        }
    
    


}

