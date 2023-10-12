//
//  Program.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 1.09.2023.
//

class ProgramDay : Codable, Identifiable{
    var day: String?
    var programs: [Program]?
}

class Program : Codable, Identifiable{
    
    var id: Int?
    var hall_id: Int?
    var sort_order: Int?
    var code: String?
    var title: String?
    var description: String?
    var logo: String?
    var start_at: String?
    var finish_at: String?
    var type: String?
    var on_air: Int?
    var status: Int?
    var chairs: [Participant]?
    var sessions: [Session]?
    var debates: [Debate]?
}

class ProgramsJson : Codable, Identifiable{
    
    var data: [ProgramDay]?
    var errors: [String]?
    var status: Bool?
}
