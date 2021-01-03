//
//  UIView+AutoLayout.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 30/12/2020.
//

import UIKit
import Foundation

public extension UIViewController {
    var safeTopAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.topAnchor
    }

    var safeBottomAnchor: NSLayoutYAxisAnchor {
        return view.safeAreaLayoutGuide.bottomAnchor
    }

    var safeLeadingAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.leadingAnchor
    }

    var safeTrailingAnchor: NSLayoutXAxisAnchor {
        return view.safeAreaLayoutGuide.trailingAnchor
    }
}
