//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation

struct Article {
    let articleId: String
}

extension Article: Equatable {}
func ==(lhs: Article, rhs: Article) -> Bool {
    return lhs.articleId == rhs.articleId
}