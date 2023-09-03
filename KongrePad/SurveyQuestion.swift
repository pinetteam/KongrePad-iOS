//
//  SurveyQuestion.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 2.09.2023.
//

class SurveyQuestion : Codable, Identifiable{
    
    var sort_order: Int?
    var id: Int?
    var survey_id: Int?
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
