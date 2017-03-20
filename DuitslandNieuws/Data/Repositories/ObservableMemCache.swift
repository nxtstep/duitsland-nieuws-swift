//
// Created by Arjan Duijzer on 15/02/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import Foundation
import RxSwift
import OrderedDictionary

public protocol Identifiable {
    associatedtype K: Hashable

    var key: K { get }
}

public protocol Cache {
    associatedtype E: Identifiable

    func get(_ id: E.K) -> Observable<E>

    func list(_ page: Int, pageSize size: Int) -> Observable<[E]>

    func listAll() -> Observable<[E]>

    func save(_ value: E) -> Observable<E>

    func save(_ values: [E]) -> Observable<[E]>

    func delete(id: E.K) -> Observable<E>

    func delete(_ value: E) -> Observable<E>

    func deleteAll() -> Observable<[E]>
}

public struct ObservableMemCache<Element:Identifiable>: Cache {

    public init(values dict: [Element.K: Element]) {
        self.cache = AnyMutableWrapper(OrderedDictionary(dict))
    }

    public init() {
        self.cache = AnyMutableWrapper(OrderedDictionary())
    }

    public init(_ elements: [Element]) {
        let sequence = elements.flatMap {
            (key: $0.key, value: $0)
        }
        self.cache = AnyMutableWrapper(OrderedDictionary(sequence))
    }

    internal func generateKey(_ value: Element) -> Observable<Element.K> {
        return Observable.just(value.key)
    }

    public func get(_ id: Element.K) -> Observable<Element> {
        return Observable.just(self.cache.value)
                .filter {
                    $0[id] != nil
                }
                .map {
                    $0[id]!
                }
    }

    public func list(_ page: Int, pageSize size: Int) -> Observable<[Element]> {
        return Observable.just(self.cache.value)
                .filter {
                    $0.isNotEmpty
                }
                .filter {
                    (page + 1) * size <= $0.count
                }
                .map {
                    $0.orderedValues
                }
                .map {
                    Array($0[(page * size) ..< ((page + 1) * size)])
                }
    }

    public func listAll() -> Observable<[Element]> {
        return Observable.just(self.cache.value)
                .filter {
                    $0.isNotEmpty
                }
                .flatMap {
                    Observable.from($0.orderedValues)
                }
                .toArray()
    }

    public func save(_ value: Element) -> Observable<Element> {
        return generateKey(value)
                .zip(with: Observable.just(value)) {
                    ($0, $1)
                }
                .map { pair in
                    self._save(pair.1, for: pair.0)
                }
    }

    public func save(_ values: [Element]) -> Observable<[Element]> {
        return Observable.from(values)
                .flatMap {
                    self.save($0)
                }
                .toArray()
    }

    public func delete(id: Element.K) -> Observable<Element> {
        return self.get(id)
                .map { _ in
                    self._delete(id: id)!
                }
    }

    public func delete(_ value: Element) -> Observable<Element> {
        return self.generateKey(value)
                .flatMap {
                    self.delete(id: $0)
                }
    }

    public func deleteAll() -> Observable<[Element]> {
        return listAll()
                .flatMap {
                    Observable.from($0)
                }
                .flatMap {
                    self.delete($0)
                }
                .toArray()
    }

    internal func clear() {
        cache.value.removeAll()
    }

    fileprivate func _delete(id: Element.K) -> Element? {
        return cache.value.removeValue(forKey: id)
    }

    fileprivate func _save(_ value: Element, for key: Element.K) -> Element {
        cache.value[key] = value
        return value
    }

    internal let cache: AnyMutableWrapper<OrderedDictionary<Element.K, Element>>
}

