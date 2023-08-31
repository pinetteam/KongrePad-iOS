//
//  Announcement.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 24.08.2023.
//

class Announcement : Codable, Identifiable{
    
    var id: Int?
    var meeting_id: Int?
    var title: String?
    var status: Int?
}

class AnnouncementsJSON : Codable, Identifiable{
    
    var data: [Announcement]?
    var errors: [String]?
    var status: Bool?
}
