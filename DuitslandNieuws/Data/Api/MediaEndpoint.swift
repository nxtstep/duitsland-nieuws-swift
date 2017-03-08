//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import Moya

enum MediaEndpoint {
    case media(id: String)
}

private extension String {
    var urlEscaped: String {
        return self.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!
    }
}

extension MediaEndpoint: TargetType {
    var baseURL: URL {
        return URL(string: "http://duitslandnieuws.nl/wp-json/wp/v2/")!
    }
    var path: String {
        switch self {
        case .media(let id):
            return "media/\(id)"
        default:
            return ""
        }
    }
    var method: Moya.Method {
        return .get
    }
    var parameters: [String: Any]? {
        return nil
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
