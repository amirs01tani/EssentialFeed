//
//  File.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/20/23.
//

import Foundation
import EssentialFeed

func uniqueImage() -> FeedImage {
    return FeedImage(id: UUID(), description: "any", location: "any", URL: anyURL())
}

func uniqueImageFeed() -> (models: [FeedImage], local: [LocalFeedImage]) {
    let models = [uniqueImage(), uniqueImage()]
    let local = models.map { LocalFeedImage(id: $0.id, description: $0.description, location: $0.location, URL: $0.URL) }
    return (models, local)
}

extension Date {
    
    func minusFeedCacheMaxAge() -> Date {
        return self.adding(days: -7)
    }
    
     func adding(days: Int) -> Date {
         return Calendar(identifier: .gregorian).date(byAdding: .day, value: days, to: self)!
     }

     func adding(seconds: TimeInterval) -> Date {
         return self + seconds
     }
 }

