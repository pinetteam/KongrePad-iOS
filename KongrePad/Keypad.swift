//
//  Keypad.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 6.09.2023.
//

struct Keypad : Codable, Identifiable {
    
    var id: Int?
    var sort_order: Int?
    var session_id: Int?
    var code: String?
    var title: String?
    var keypad: String?
    var voting_started_at: String?
    var voting_finished_at: String?
    var options: [KeypadOption]?
    var on_vote: Int?
}

class KeypadsJSON : Codable, Identifiable{
    
    var data: [Keypad]?
    var errors: [String]?
    var status: Bool?
}

class KeypadJSON : Codable, Identifiable{
    
    var data: Keypad?
    var errors: [String]?
    var status: Bool?
}
