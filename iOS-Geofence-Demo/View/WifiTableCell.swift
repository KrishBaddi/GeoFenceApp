//
//  WifiTableCell.swift
//  iOS-Geofence-Demo
//
//  Created by Kaodim MacMini on 01/01/2021.
//

import Foundation
import UIKit

class WifiTableCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var icon: UIImageView!

    override func awakeFromNib() {
        self.accessoryType = .none
    }

    func configureCell(_ title: String) {
        self.title.text = title
        self.icon.image = UIImage.init(systemName: "wifi")
    }
}
