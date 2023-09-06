//
//  UIRefreshControlTestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Amir on 9/7/23.
//

import Foundation
import UIKit

private extension UIRefreshControl {
    func simulatePullToRefresh() {
        allTargets.forEach { target in
            actions(forTarget: target, forControlEvent:
                    .valueChanged)?.forEach {
                        (target as NSObject).perform(Selector($0))
            }
        }
    }
}
