//
//  CacheFeedUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/15/23.
//

import XCTest
import EssentialFeed

class LocalFeedLoader {
    
    var store: FeedStore
    private let currentDate: () -> Date
    
    public enum Error: Swift.Error {
        case deletionError
    }
    
    init(store: FeedStore, currentDate: @escaping () -> Date ) {
        self.store = store
        self.currentDate = currentDate
    }
    
    func save(_ items: [FeedItem]) {
        store.deleteCachedFeed(completion: { [unowned self] error in
            if error == nil {
                self.store.insertItems(items, timeStamp: self.currentDate())
            }
        })
    }
}

class FeedStore {
    typealias DeletionCompletion = (Error?) -> Void
    var deleteCachedFeedCallCount = 0
    var insertions = [(items: [FeedItem], timeStamp: Date)]()
    
    private var deletionCompletions = [DeletionCompletion]()
    
    func deleteCachedFeed(completion: @escaping DeletionCompletion) {
        deleteCachedFeedCallCount += 1
        deletionCompletions.append(completion)
    }
    
    func completeDeletion(with error: Error, index: Int = 0) {
        deletionCompletions[index](error)
    }
    
    func completeDeletionsuccessfully(index: Int = 0) {
        deletionCompletions[index](nil)
    }
    
    func insertItems(_ items: [FeedItem], timeStamp: Date) {
        insertions.append((items: items, timeStamp: timeStamp))
    }
}

final class CacheFeedUseCaseTests: XCTestCase {
// first thing in recepie is delete the old cache
// we did not delete the cached feed upon creation
    func test() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.deleteCachedFeedCallCount, 0)
    }
// request cache deletion on save
    
    func test_save_requestCacheDeletion() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        sut.save(item)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
    
    func test_save_doesNotRequestCacheInsetionOnDeleteError() {
        let (sut, store) = makeSUT()
        let item = [uniqueItem(), uniqueItem()]
        let deletionError = LocalFeedLoader.Error.deletionError
        sut.save(item)
        store.completeDeletion(with: deletionError)
        XCTAssertEqual(store.deleteCachedFeedCallCount, 1)
    }
// redundant
//    func test_save_requestNewCacheInsertionOnsuccessfulDeletion() {
//        let (sut, store) = makeSUT()
//        let item = [uniqueItem(), uniqueItem()]
//        sut.save(item)
//        store.completeDeletionsuccessfully()
//        XCTAssertEqual(store.insertCallCount, 1)
//    }
    
    func test_save_requestNewCacheInsertionWithTimeStampOnsuccessfulDeletion() {
        let timeStamp = Date()
        let (sut, store) = makeSUT(currentDate: { timeStamp })
        let item = [uniqueItem(), uniqueItem()]
        sut.save(item)
        store.completeDeletionsuccessfully()
        
        XCTAssertEqual(store.insertions.first?.items, item)
        XCTAssertEqual(store.insertions.first?.timeStamp, timeStamp)
        
    }
    
    // Mark: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStore) {
        let store = FeedStore()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func uniqueItem() -> FeedItem {
        return FeedItem(id: UUID(), description: "any", location: "any", imageURL: anyURL())
    }
    
    private func anyURL() -> URL {
        return URL(string: "http://any-url.com")!
    }
}


