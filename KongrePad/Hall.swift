//
//  Hall.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

class Hall : Codable, Identifiable{
    var id: Int?
    var meeting_id: Int?
    var code: String?
    var title: String?
    var show_on_session: Int?
    var show_on_ask_question: Int?
    var show_on_view_program: Int?
    var show_on_send_mail: Int?
    var status: Int?
}

class HallsJSON : Codable, Identifiable{
    
    var data: [Hall]?
    var errors: [String]?
    var status: Bool?
}
