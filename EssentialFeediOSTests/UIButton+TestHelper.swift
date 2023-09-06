//
//  UIButton+TestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Amir on 9/7/23.
//

import Foundation
import UIKit

private extension UIButton {
    func simulateTap() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent: .touchUpInside)?.forEach {
                (target as NSObject).perform(Selector($0))
            }
        }
    }
}
