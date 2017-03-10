//
//  UILabel+HTML.swift
//  DuitslandNieuws
//
//  Created by Arjan Duijzer on 10/03/2017.
//  Copyright © 2017 SuperSimple.io. All rights reserved.
//

import UIKit

extension UILabel {
    func setText(html: String, encoding: String.Encoding) {
        if let attributedText = try? NSAttributedString(html: html,
                encoding: encoding,
                font: self.font,
                textColor: self.textColor,
                alignment: self.textAlignment) {
            self.attributedText = attributedText
        } else {
            self.text = nil
        }
    }
}
