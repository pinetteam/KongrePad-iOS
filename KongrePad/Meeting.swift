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
    var session_hall_count: Int?
    var session_first_hall_id: Int?
    var question_hall_count: Int?
    var question_first_hall_id: Int?
    var program_hall_count: Int?
    var program_first_hall_id: Int?
    var mail_hall_count: Int?
    var mail_first_hall_id: Int?
}

class MeetingJSON : Codable, Identifiable{
    
    var data: Meeting?
    var errors: [String]?
    var status: Bool?
}
