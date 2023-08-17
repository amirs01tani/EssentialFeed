//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Amir on 8/9/23.
//

import Foundation

internal class FeedItemMapper {
    
    private struct Root: Decodable {
        public let items: [RemoteFeedImage]
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) throws -> [RemoteFeedImage] {
        guard response.statusCode == 200,
              let root = try? JSONDecoder().decode(Root.self, from: data) else {
             throw RemoteFeedLoader.Error.invalidData
        }
        return root.items
    }
    
}
