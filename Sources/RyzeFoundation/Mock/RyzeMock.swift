//
//  RyzeMock.swift
//  Ryze
//
//  Created by Rafael Escaleira on 25/04/25.
//

public protocol RyzeMock {
    static var mock: Self { get }
    static var mocks: [Self] { get }
}

extension RyzeMock {
    public static var mocks: [Self] {
        (1...10).map { _ in
            mock
        }
    }
}
