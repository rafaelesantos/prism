//
//  PrismMock.swift
//  Prism
//
//  Created by Rafael Escaleira on 25/04/25.
//

/// A protocol for generating test data (mocks).
public protocol PrismMock {
    static var mock: Self { get }
    static var mocks: [Self] { get }
}

extension PrismMock {
    public static var mocks: [Self] {
        (1...10).map { _ in
            mock
        }
    }
}
