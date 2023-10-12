//
//  SurveyQuestion.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

struct SurveyQuestion : Codable, Identifiable{
    
    var id: Int?
    var sort_order: Int?
    var survey_id: Int?
    var selected_option: Int?
    var question: String?
    var options: [SurveyOption]?
    var status: Int?
}

class SurveyQuestionsJSON : Codable, Identifiable{
    
    var data: [SurveyQuestion]?
    var errors: [String]?
    var status: Bool?
}

class SurveyQuestionJSON : Codable, Identifiable{
    
    var data: SurveyQuestion?
    var errors: [String]?
    var status: Bool?
}
