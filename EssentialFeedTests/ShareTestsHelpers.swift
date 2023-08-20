//
//  ShareTestsHelpers.swift
//  EssentialFeedTests
//
//  Created by Amir on 8/20/23.
//

import Foundation

func anyNSError() -> NSError {
    return NSError(domain: "any error", code: 0)
}

func anyURL() -> URL {
    return URL(string: "http://any-url.com")!
}


