//
//  LoadFeedFromCacheUseCaseTests.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/17/23.
//

import XCTest
import EssentialFeed

final class LoadFeedFromCacheUseCaseTests: XCTestCase {

    func test_doesNotMessageStoreOnCreation() {
        let (_, store) = makeSUT()
        XCTAssertEqual(store.receivedMessages, [])
    }
    
    func test_load_requestsCacheRetrieval() {
        let (sut, store) = makeSUT()
        
        sut.load { _ in }
        
        XCTAssertEqual(store.receivedMessages, [.retrieve])
    }
    
    func test_load_failsOnRetrievalError() {
        let (sut, store) = makeSUT()
        let retrievalError = anyNSError()
        
        let exp = expectation(description: "Wait for retrieve completion")
        var receivedError: Error?
        
        sut.load() { result in
            switch result {
            case .failure(let error):
                receivedError = error
            default:
                XCTFail("Extected error but received \(result)")
            }
            exp.fulfill()
        }
        store.completeRetrieval(with: retrievalError)
        wait (for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedError as NSError?, retrievalError)
    }
    
    func test_load_deliversNoImagesOnEmptyCache() {
        let (sut, store) = makeSUT()
        
        let exp = expectation(description: "Wait for retrieve completion")
        var receivedImages: [FeedImage]?
        
        sut.load() { result  in
            switch result {
            case .success(let images):
                receivedImages = images
            default:
                XCTFail("Extected result but received \(result)")
            }
            exp.fulfill()
        }
        store.completeRetrievalWithEmptyCache()
        wait (for: [exp], timeout: 1.0)
        XCTAssertEqual(receivedImages, [])
    }

    // Mark: - Helpers
    
    private func makeSUT(currentDate: @escaping () -> Date = Date.init, file: StaticString = #file, line: UInt = #line) -> (sut: LocalFeedLoader, store: FeedStoreSpy) {
        let store = FeedStoreSpy()
        let sut = LocalFeedLoader(store: store, currentDate: currentDate)
        trackForMemoryLeaks(sut, file: file, line: line)
        trackForMemoryLeaks(store, file: file, line: line)
        return (sut: sut, store: store)
    }
    
    private func anyNSError() -> NSError {
        return NSError(domain: "any error", code: 0)
    }
    
}
