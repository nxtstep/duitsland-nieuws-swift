//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import UIKit
import AlamofireImage

class ArticlePresentationCell: UITableViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var excerptLabel: UILabel!
    @IBOutlet var thumbnailImageView: UIImageView!

    var article: ArticlePresentation! {
        didSet {
            self.titleLabel.setText(html: article.title, encoding: .isoLatin1)
            self.dateLabel.text = article.pubDate
            self.excerptLabel.setText(html: article.excerpt, encoding: .isoLatin1)
            
            guard let imageUrl = article.imageUrl, let url = URL(string: imageUrl) else {
                self.thumbnailImageView.image = nil
                return
            }

            self.thumbnailImageView.af_setImage(withURL: url,
                    placeholderImage: nil,
                    filter: AspectScaledToFillSizeFilter(size: self.thumbnailImageView.bounds.size))
        }
    }
}
