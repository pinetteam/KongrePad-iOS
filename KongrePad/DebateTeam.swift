//
//  DebateOption.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 28.08.2023.
//

struct DebateTeam : Codable, Identifiable, Hashable{
    var id: Int?
    var debate_id: Int?
    var code: String?
    var logo_name: String?
    var logo_extension: String?
    var title: String?
    var description: String?
}

