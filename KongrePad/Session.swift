//
//  Session.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 1.09.2023.
//

class Session : Codable, Identifiable{
    
    var id: Int?
    var program_id: Int?
    var speaker_id: Int?
    var document_id: Int?
    var sort_order: Int?
    var code: String?
    var title: String?
    var speaker_name: String?
    var description: String?
    var start_at: String?
    var finish_at: String?
    var on_air: Int?
    var questions_allowed: Int?
    var questions_limit: Int?
    var question_auto_start: Int?
    var status: Int?
}



class SessionJSON : Codable, Identifiable{
    var data: Session?
    var errors: [String]?
    var status: Bool?
}
