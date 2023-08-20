//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/10/23.
//

import Foundation

public enum LoadFeedResult {
    case success([FeedImage])
    case failure(Error)
}

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(with completion: @escaping (LoadFeedResult) -> Void)
}
