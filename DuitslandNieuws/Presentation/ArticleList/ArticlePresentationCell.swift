//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import UIKit

class ArticlePresentationCell: UITableViewCell {
    var article: ArticlePresentation! {
        didSet {
            self.textLabel?.text = article.title
        }
    }
}
