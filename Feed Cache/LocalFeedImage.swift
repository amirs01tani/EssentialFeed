//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Amir on 8/17/23.
//

import Foundation

public struct LocalFeedImage: Equatable, Codable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let URL: URL
    
    public init(id: UUID, description: String? = nil, location: String? = nil, URL: URL) {
        self.id = id
        self.description = description
        self.location = location
        self.URL = URL
    }
    
    
}
