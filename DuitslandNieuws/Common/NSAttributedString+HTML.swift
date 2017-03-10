//
// Created by Arjan Duijzer on 10/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import UIKit

public extension NSAttributedString {

    public convenience init?(html: String, encoding: String.Encoding = .utf8, font: UIFont? = nil, textColor: UIColor? = nil, alignment: NSTextAlignment = NSTextAlignment.natural) throws {
        if html.characters.count == 0 {
            throw NSError(domain: "Parse Error (empty)", code: -1, userInfo: nil)
        }
        let options: [String: Any] = [
                NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                NSCharacterEncodingDocumentAttribute: NSNumber(value: encoding.rawValue)
        ]

        guard let data = html.data(using: encoding, allowLossyConversion: true) else {
            throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
        }

        if let font = font {
            guard let attr = try? NSMutableAttributedString(data: data, options: options, documentAttributes: nil) else {
                throw NSError(domain: "Parse Error", code: 0, userInfo: nil)
            }
            var attrs = attr.attributes(at: 0, effectiveRange: nil)
            attrs[NSFontAttributeName] = font
            if let color = textColor {
                attrs[NSForegroundColorAttributeName] = color
            }
            if (alignment != .natural) {
                let style = NSMutableParagraphStyle()
                style.alignment = alignment
                attrs[NSParagraphStyleAttributeName] = style
            }
            attr.setAttributes(attrs, range: NSRange(location: 0, length: attr.length))
            self.init(attributedString: attr)
        } else {
            try? self.init(data: data, options: options, documentAttributes: nil)
        }
    }
}
