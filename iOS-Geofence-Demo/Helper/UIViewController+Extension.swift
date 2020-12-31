//
//  UIViewController+Extension.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 31/12/2020.
//

import UIKit

extension UIViewController {
    func showAlert(withTitle title: String?, message: String?) {
      let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
      let action = UIAlertAction(title: "OK", style: .cancel, handler: nil)
      alert.addAction(action)
      present(alert, animated: true, completion: nil)
    }
}
