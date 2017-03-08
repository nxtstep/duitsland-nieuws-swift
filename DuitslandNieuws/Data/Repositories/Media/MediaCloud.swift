//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import RxMoya

class MediaCloud {
    typealias V = Media
    typealias Endpoint = MediaEndpoint

    static let defaultPageSize = 10

    let mediaProvider: RxMoyaProvider<Endpoint>

    required init(provider: RxMoyaProvider<Endpoint>) {
        self.mediaProvider = provider
    }

    func fetch(id: String) -> Observable<V> {
        return mediaProvider.request(.media(id: id))
                .mapObject(Media.self)
    }
}
