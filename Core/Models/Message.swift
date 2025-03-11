//
//  Message.swift
//  Squad
//
//  Created by Abdinoor Abdinoor on 10/25/24.
//

import Foundation

extension Message: Equatable {
    static func == (lhs: Message, rhs: Message) -> Bool {
        lhs.id == rhs.id
    }
}

struct Message: Identifiable, Codable {
    let id: UUID
    let content: String
    let timestamp: Date
    let type: MessageType
    let sender: MessageSender
    var attachments: [Attachment]?
    var locationContext: LocationContext?
    
    enum MessageType: Codable {
        case text
        case media(MediaType)
        case location
        case link(LinkType)
    }
    
    enum MediaType: Codable {
        case image
        case video
        case audio
    }
    
    enum LinkType: Codable {
        case tiktok
        case youtube
        case website
    }
    
    enum MessageSender: Codable, Equatable {
        case user
        case ai(UUID)
        case squad(UUID)
    }
    
    struct Attachment: Codable {
        let id: UUID
        let url: URL
        let type: MediaType
        let thumbnail: URL?
    }
    
    struct LocationContext: Codable {
        let coordinates: Coordinates
        let placeName: String
        let placeType: String
        let duration: TimeInterval
    }
    
    struct Coordinates: Codable {
        let latitude: Double
        let longitude: Double
    }
}
