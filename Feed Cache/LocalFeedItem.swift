//
//  LocalFeedItem.swift
//  EssentialFeed
//
//  Created by Amir on 8/17/23.
//

import Foundation

public struct LocalFeedItem: Equatable {
    
    public let id: UUID
    public let description: String?
    public let location: String?
    public let imageURL: URL
    
}
