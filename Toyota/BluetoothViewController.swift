//
//  BluetoothViewController.swift
//  Toyota
//
//  Created by Reynald Marquez-Gragasin on 5/30/25.
//

import UIKit
//import CoreBluetooth


class BluetoothViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
        
//        var bleManager = BLEManager()

        var headingTitle = UILabel()
    
        var tableView: UITableView = {
            let table = UITableView()
            table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
            return table
        }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        headingTitle = UILabel(frame: CGRect(x: 0, y: 60, width: view.frame.width, height: 40))
        headingTitle.text = "   Bluetooth Chat"
        headingTitle.textColor = .blue
        headingTitle.backgroundColor = UIColor.systemGray5
        headingTitle.font = UIFont(name: "Arial", size: 20)
        view.addSubview(headingTitle)
        
        tableView.frame = CGRect(x: 0, y: 110, width: view.frame.width, height: view.frame.height)
                                               
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return peripherals.count
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DeviceCell", for: indexPath)
//        let peripheral = peripherals[indexPath.row]
//        cell.textLabel?.text = peripheral.name ?? "Unknown Device"
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let selectedPeripheral = peripherals[indexPath.row]
//        connectPeripheral(peripheral: selectedPeripheral)
    }


}

