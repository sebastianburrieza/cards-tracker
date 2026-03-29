//  NavigationType.swift
//  Created by Sebastian Burrieza on 01/04/2026.

import UIKit

public enum NavigationType {
    case push(_ animated: Bool)
    case present(_ style: UIModalPresentationStyle, _ animated: Bool)
    case presentWithAutomaticModal(_ animated: Bool)
    case setRoot
}
