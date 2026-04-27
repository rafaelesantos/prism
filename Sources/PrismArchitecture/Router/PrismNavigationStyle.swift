//
//  PrismNavigationType.swift
//  Prism
//
//  Created by Rafael Escaleira on 03/04/25.
//

/// Estilos de navegação: push, modal e full-screen.
public enum PrismNavigationStyle: Sendable, Codable {
    case push
    case present
    case full
}
