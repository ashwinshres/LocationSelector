//
//  ViewController.swift
//  Location Selector
//
//  Created by Insight Workshop on 2/16/19.
//  Copyright © 2019 InsightWorkshop. All rights reserved.
//

import UIKit
import GooglePlaces

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func openMapSelector(_ sender: UIButton) {
        if let mapSelectorVC = UIStoryboard(name: "LocationSelector", bundle: nil).instantiateViewController(withIdentifier: "LocationSelectorViewController") as? LocationSelectorViewController {
            mapSelectorVC.dataSource = self
            mapSelectorVC.delegate = self
            navigationController?.pushViewController(mapSelectorVC, animated: true)
        }
    }
    
}

extension ViewController: MapViewControllerDelegate, MapViewControllerDataSource {
    
    func appName() -> String {
        return "My App"
    }
    
    func didSelect(location: GMSPlace) {
        print(location.formattedAddress)
    }
    
    func didClickClose(viewController: LocationSelectorViewController) {
        viewController.navigationController?.popViewController(animated: true)
    }
    
    func themeColor() -> UIColor {
        return .red
    }
    
}

