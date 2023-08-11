//
//  CXTestCase+MemoryLeakTrack.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/11/23.
//

import XCTest

extension XCTestCase {
    internal func trackForMemoryLeaks(_ instance: AnyObject, file: StaticString = #file, line: UInt = #line) {
        addTeardownBlock { [weak instance] in
            XCTAssertNil(instance, "Instance should have been deallocated. Potential memory leak.", file: file,
                         line: line)
        }
    }
}
