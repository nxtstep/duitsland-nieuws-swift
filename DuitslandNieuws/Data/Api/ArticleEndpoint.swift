//
// Created by Arjan Duijzer on 03/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import Moya

enum ArticleEndpoint {
    case article(id: String)
    case list(page: Int, size: Int)
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

extension ArticleEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "http://duitslandnieuws.nl/wp-json/wp/v2/")!
    }
    var path: String {
        switch self {
        case .article(let id):
            return "posts/\(id)"
        case .list(_, _):
            return "posts"
        }
    }
    var method: Moya.Method {
        return .get
    }
    var parameters: [String: Any]? {
        switch self {
        case .list(let page, let size):
            return ["page": page, "per_page": size]
        default:
            return nil
        }
    }
    var parameterEncoding: ParameterEncoding {
        return URLEncoding.default
    }
    var sampleData: Data {
        return Data()
    }
    var task: Task {
        return Task.request
    }
    var validate: Bool {
        return false
    }
}