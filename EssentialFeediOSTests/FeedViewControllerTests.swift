//
//  EssentialFeediOSTests.swift
//  EssentialFeediOSTests
//
//  Created by Amir on 9/4/23.
//

import XCTest
import UIKit
import EssentialFeed
import EssentialFeediOS

final class FeedViewControllerTests: XCTestCase {

    func test_loadFeedActions_requestFeedFromLoader() {
        let (sut, loader) = makeSUT()
        
        XCTAssertEqual(loader.loadCallCount, 0)
        
        sut.loadViewIfNeeded()
        XCTAssertEqual(loader.loadCallCount, 1)
        
        sut.loadViewIfNeeded()
        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 2)

        sut.simulateUserInitiatedFeedReload()
        XCTAssertEqual(loader.loadCallCount, 3)
    }
    
    func test_loadingFeedIndicator_isVisibleWhileLoadingFeed() {
        let (sut, loader) = makeSUT ()
        sut.loadViewIfNeeded ()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading (at: 0)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
        
        sut.simulateUserInitiatedFeedReload()
        XCTAssertTrue(sut.isShowingLoadingIndicator)
        
        loader.completeFeedLoading (at: 1)
        XCTAssertFalse(sut.isShowingLoadingIndicator)
    }
    
    private func makeSUT(file: StaticString = #file, line: UInt = #line) -> (sut: FeedViewController, loader: LoaderSpy) {
        let loader = LoaderSpy()
        let sut = FeedViewController(loader: loader)
        
        return (sut, loader)
    }
    
    private class LoaderSpy: FeedLoader {
        private var completions = [(FeedLoader.Result) -> Void]()
        
        var loadCallCount: Int {
            return completions.count
        }
        
        func load(with completion: @escaping (FeedLoader.Result) -> Void) {
            completions.append(completion)
        }
        
        func completeFeedLoading(at index: Int) {
            completions[index](.success([]))
        }
        
    }
}

private extension FeedViewController {
    // DSL
    func simulateUserInitiatedFeedReload() {
        refreshControl?.simulatePullToRefresh()
    }
    // DSL
    var isShowingLoadingIndicator: Bool {
        return refreshControl!.isRefreshing == true
    }
}

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

