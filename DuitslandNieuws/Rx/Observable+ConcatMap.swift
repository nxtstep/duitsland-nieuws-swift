//
// Created by Arjan Duijzer on 15/03/2017.
// Copyright (c) 2017 SuperSimple.io. All rights reserved.
//

import RxSwift

extension ObservableType {

    /**
    Projects each element of an observable sequence to an observable sequence and concatenates the resulting observable sequences into one observable sequence.

    - seealso: [concat operator on reactivex.io](http://reactivex.io/documentation/operators/concat.html)

    - returns: An observable sequence that contains the elements of each observed inner sequence, in sequential order.
    */
    public func concatMap<O: ObservableConvertibleType>(_ selector: @escaping (E) throws -> O) -> Observable<O.E> {
        return self.asObservable().map(selector).concat()
    }
}
