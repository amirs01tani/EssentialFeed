//
//  FeedItemMapper.swift
//  EssentialFeed
//
//  Created by Amir on 8/9/23.
//

import Foundation

internal class FeedItemMapper {
    
    private struct Root: Decodable {
        public let items: [Item]
        var feed: [FeedItem] {
            return items.map { $0.item }
        }
    }

    private struct Item: Decodable {
        let id: UUID
        let description: String?
        let location: String?
        let image: URL
        
        var item: FeedItem {
            return FeedItem(id: id, description: description, location: location, imageURL: image)
        }
        
    }

    internal static func map(_ data: Data, from response: HTTPURLResponse) -> RemoteFeedLoader.Result {
        guard response.statusCode == 200,
              let root = try? JSONDecoder () . decode (Root.self, from: data) else {
            return .failure(RemoteFeedLoader.Error.invalidData)
        }
        return .success(root.feed)
    }
    
}

