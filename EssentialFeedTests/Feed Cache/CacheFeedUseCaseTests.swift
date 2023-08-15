//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/15/23.
//

import XCTest

class LocalFeedLoader {
    
    var store: FeedStore
    
    init(store: FeedStore) {
        self.store = store
    }
}

class FeedStore {
    var deleteCachedFeedCallCount = 0
}

final class CacheFeedUseCaseTests: XCTestCase {
// first thing in recepie is delete the old cache
// we did not delete the cached feed upon creation
    func test() {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }

}
