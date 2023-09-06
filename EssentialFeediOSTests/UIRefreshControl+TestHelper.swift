//
//  UIRefreshControlTestHelper.swift
//  EssentialFeediOSTests
//
//  Created by Amir on 9/7/23.
//

import Foundation
import UIKit

extension UIRefreshControl {
    func simulatePullToRefresh() {
        simulate(event: .valueChanged)
    }
}
