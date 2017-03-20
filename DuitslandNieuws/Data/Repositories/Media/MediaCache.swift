//
// Created by Arjan Duijzer on 08/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift

class MediaCache: Cache {
    typealias E = Media

    required init(_ values: [Media]) {
        self.cache = ObservableMemCache(values)
    }

    convenience init() {
        self.init([Media]())
    }

    func get(_ id: E.K) -> Observable<E> {
        return cache.get(id)
    }

    func list(_ page: Int, pageSize size: Int) -> Observable<[E]> {
        return cache.list(page, pageSize: size)
    }

    func listAll() -> Observable<[E]> {
        return cache.listAll()
    }

    func save(_ value: E) -> Observable<E> {
        return cache.save(value)
    }

    func save(_ values: [E]) -> Observable<[E]> {
        return cache.save(values)
    }

    func delete(id: E.K) -> Observable<E> {
        return cache.delete(id: id)
    }

    func delete(_ value: E) -> Observable<E> {
        return cache.delete(value)
    }

    func deleteAll() -> Observable<[E]> {
        return cache.deleteAll()
    }

    fileprivate let cache: ObservableMemCache<E>
}

extension Media: Identifiable {
    var key: String {
        return id
    }
}
