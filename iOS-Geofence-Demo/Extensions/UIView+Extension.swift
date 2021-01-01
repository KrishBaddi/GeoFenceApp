//
//  UIView+Extension.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation
import UIKit

extension UIView {
    func animShow() {
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveLinear],
            animations: {
                self.center.y += self.bounds.height
                self.layoutIfNeeded()
            }, completion: { _ in
            })
        self.isHidden = false
    }

    func animHide() {
        UIView.animate(withDuration: 1, delay: 0, options: [.curveLinear],
            animations: {
                self.center.y -= self.bounds.height
                self.layoutIfNeeded()

            }, completion: { (_ completed: Bool) -> Void in
                self.isHidden = true
            })
    }


    func showHideView() {
        self.animShow()

        DispatchQueue.main.asyncAfter(deadline: .now() + 4) {
            self.animHide()
        }
    }
}
