//
//  Extensions.swift
//  MapRoute
//
//  Created by Meet's Mac on 13/03/24.
//

import UIKit

extension UIViewController{
    
    // Loader start and stop
    func startLoader(){
        loader.frame = CGRectMake(0, 0, 40, 40)
        loader.style = .medium
        loader.color = .black
        loader.center = CGPointMake(self.view.bounds.width / 2, self.view.bounds.height / 2)
        self.view.addSubview(loader)
        
        loader.startAnimating()
    }
    
    func stopLoader(){
        loader.stopAnimating()
        loader.removeFromSuperview()
    }
    
    // show alert message
    func showPopup(message: String){
        self.stopLoader()
        let name = Bundle.main.infoDictionary?[kCFBundleNameKey as String] as? String
        let alert = UIAlertController(title: name, message: message, preferredStyle: .alert)
        let ok_action = UIAlertAction(title: "OK", style: .default)
        alert.addAction(ok_action)
        self.present(alert, animated: true)
    }
}

extension UIColor {
    static func random() -> UIColor {
        return UIColor(
           red:   .random(),
           green: .random(),
           blue:  .random(),
           alpha: 1.0
        )
    }
}

extension CGFloat {
    static func random() -> CGFloat {
        return CGFloat(arc4random()) / CGFloat(UInt32.max)
    }
}
