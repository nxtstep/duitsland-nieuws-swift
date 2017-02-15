//
// Created by Arjan Duijzer on 14/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import XCTest
@testable import DuitslandNieuws

class ArticleRepositoryTest: XCTestCase {
    
    func testArticleRepository() {
        let mockCache = MockArticleCache()
        let mockCloud = MockArticleCloud()

        let repo = ArticleRepository(mockCache, mockCloud)
        XCTAssertNotNil(repo)
    }
}
