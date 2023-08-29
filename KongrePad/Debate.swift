//
//  Debate.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 28.08.2023.
//

class Debate : Codable, Identifiable{
    
    var id: Int?
    var program_id: Int?
    var code: String?
    var title: String?
    var description: String?
    var voting_started_at: String?
    var voting_finished_at: String?
    var on_vote: Int?
    var status: Int?
}
