//
//  FeedLoader.swift
//  EssentialFeed
//
//  Created by Amir on 8/10/23.
//

import Foundation

public protocol FeedLoader {
    typealias Result = Swift.Result<[FeedImage], Error>
    func load(with completion: @escaping (Result) -> Void)
}
