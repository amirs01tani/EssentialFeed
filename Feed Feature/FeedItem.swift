//
//  FeedItem.swift
//  EssentialFeed
//
//  Created by Amir on 8/7/23.
//

import Foundation

public struct RootItem: Codable,Equatable {
    public let items: [FeedItem]
}

public struct FeedItem: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
    public init(id: UUID, description: String?, location: String?, imageURL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.imageURL = imageURL
    }
}

extension FeedItem: Codable {
    private enum CodingKeys: String, CodingKey
    {
        case id
        case description
        case location
        case imageURL = "image"
    }
}
