//
//  Meeting.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 22.08.2023.
//

class Participant : Codable {
    var id: Int?
    var meeting_id: Int?
    var username: String?
    var title: String?
    var first_name: String?
    var last_name: String?
    var identification_number: String?
    var organisation: String?
    var email: String?
    var phone_country_id: Int?
    var phone: String?
    var password: String?
    var last_login_ip: String?
    var last_login_agent: String?
    var last_login_datetime: String?
    var last_activity: String?
    var type: String?
    var enrolled: Int?
    var gdpr_consent: Int?
    var status: Int?
}

