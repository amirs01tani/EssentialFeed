//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Amir on 9/7/23.
//

import Foundation
import UIKit

extension UIButton {
    func simulateTap() {
        simulate(event: .touchUpInside)
    }
}
