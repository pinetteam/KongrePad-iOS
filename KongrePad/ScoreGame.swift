//
//  ScoreGame.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 3.09.2023.
//
class ScoreGame : Codable, Identifiable{
    
    var id: Int?
    var meeting_id: Int?
    var logo: String?
    var start_at: String?
    var finish_At: String?
    var title: String?
    var status: Int?
}

class ScoreGameJSON : Codable, Identifiable{
    
    var data: ScoreGame?
    var errors: [String]?
    var status: Bool?
}
