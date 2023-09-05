//
//  Survey.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

struct Survey : Codable, Identifiable, Hashable{
    
    var sort_order: Int?
    var id: Int?
    var meeting_id: Int?
    var title: String?
    var description: String?
    var start_at: String?
    var finish_at: String?
    var status: Int?
}

class SurveysJSON : Codable, Identifiable{
    
    var data: [Survey]?
    var errors: [String]?
    var status: Bool?
}

class SurveyJSON : Codable, Identifiable{
    
    var data: Survey?
    var errors: [String]?
    var status: Bool?
}
