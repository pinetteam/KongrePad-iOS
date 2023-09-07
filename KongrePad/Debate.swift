//
//  Debate.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 28.08.2023.
//



struct Debate : Codable, Identifiable {
    var id: Int?
    var sort_order: Int?
    var program_id: Int?
    var code: String?
    var title: String?
    var description: String?
    var voting_started_at: String?
    var voting_finished_at: String?
    var teams: [DebateTeam]?
    var on_vote: Int?
    var status: Int?
}

class DebatesJSON : Codable, Identifiable{
    
    var data: [Debate]?
    var errors: [String]?
    var status: Bool?
}

class DebateJSON : Codable, Identifiable{
    
    var data: Debate?
    var errors: [String]?
    var status: Bool?
}
