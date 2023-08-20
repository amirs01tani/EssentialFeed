//
//  FeedCachePolicy.swift
//  EssentialFeed
//
//  Created by Amir on 8/20/23.
//

import Foundation

internal final class FeedCachePolicy {
    private init() {}
    private static let calendar = Calendar(identifier: .gregorian)
    
    private static var maxCachedBufferInDays: Int {
        return 7
    }
    // validations are better to be in domain model to be reusable
    public static func validate(_ timestamp: Date, against date: Date) -> Bool {
        guard let maxCacheAge = calendar.date(byAdding: .day, value: maxCachedBufferInDays, to: timestamp) else {
            return false
        }
        return date < maxCacheAge
    }
}
