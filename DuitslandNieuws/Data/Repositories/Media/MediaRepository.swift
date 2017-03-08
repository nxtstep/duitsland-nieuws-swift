//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class MediaRepository {
    let cache: MediaCache
    let cloud: MediaCloud

    init(_ cache: MediaCache, _ cloud: MediaCloud) {
        self.cache = cache
        self.cloud = cloud
    }

    func get(id: String) -> Observable<Media> {
        return cache.get(id)
                .ifEmpty(switchTo: self.cloud.fetch(id: id))
                .flatMap { [unowned self] in
                    self.cache.save($0)
                }
    }

    func save(media: Media) -> Observable<Media> {
        return cache.save(media)
    }

    func delete(media: Media) -> Observable<Media> {
        return cache.delete(media)
    }

    func clearCaches() -> Observable<Void> {
        return cache.deleteAll().flatMap { _ in Observable.empty() }
    }
}