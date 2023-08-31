//
//  Meeting.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 22.08.2023.
//

class Meeting : Codable {
    var id: Int?
    var banner_name: String?
    var banner_extension: String?
    var code: String?
    var title: String?
    var start_at: String?
    var finish_at: String?
}

class MeetingJSON : Codable, Identifiable{
    
    var data: Meeting?
    var errors: [String]?
    var status: Bool?
}
