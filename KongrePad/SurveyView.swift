//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct SurveyView : View {
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @State var survey: Survey?
    @Binding var surveyId: Int
    @Binding var popUp: Bool
    @Binding var popUpText: String
    @State var questions: [SurveyQuestion]?
    @State var error = ""
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                    VStack(alignment: .center){
                        HStack(alignment: .top){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.bgBlue)
                                .background(
                                    Circle().fill(AppColors.logoutButtonBlue)
                                )
                                .padding(5)
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }.frame(width: screen_width*0.1)
                            Text("\(survey?.title ?? "")")
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.85, height: screen_height*0.1)
                                .background(AppColors.sendMailBlue)
                                .multilineTextAlignment(.center)
                        }
                        .frame(width: screen_width)
                        .background(AppColors.sendMailBlue)
                        .overlay(Divider().background(.white), alignment: .bottom)
                        ScrollView(.vertical){
                            VStack(alignment: .leading, spacing: 20){
                                ForEach(self.questions ?? []){question in
                                    Text(question.question ?? "").bold()
                                    VStack(alignment: .leading){
                                        ForEach(question.options ?? []){option in
                                            HStack{
                                                Button(action:{
                                                    self.changeSelectedOption(item: question, optionId: option.id!)
                                                }){
                                                    Image(systemName: option.id == question.selectedOptionId ? "circle.fill" : "circle")
                                                    Text(option.option ?? "").foregroundColor(Color.black).multilineTextAlignment(.leading)
                                                }
                                                Spacer()
                                            }
                                        }
                                    }
                                    Divider()
                                }
                            }.padding()
                        }.frame(width: screen_width*0.9, height: screen_height*0.75)
                            .background(Color.white)
                            .cornerRadius(20)
                        Spacer()
                        ZStack(alignment: .center){
                            Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                            VStack{
                                Text(error).padding().foregroundColor(Color.red)
                                Text("Cevapları Gönder")
                                    .foregroundColor(Color.white)
                                    .padding().background(Color.green)
                                    .cornerRadius(10)
                                    .onTapGesture {
                                        sendAnswers()
                                    }
                            }
                        }
                    }.background(AppColors.bgBlue)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getMeeting()
                getSurvey()
                getQuestions()
        }
    }
    
        func getMeeting(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/meeting") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let meeting = try JSONDecoder().decode(MeetingJSON.self, from: data)
                DispatchQueue.main.sync {
                    self.meeting = meeting.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getQuestions(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/survey/\(self.surveyId)/question") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let questions = try JSONDecoder().decode(SurveyQuestionsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.questions = questions.data!
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    
    func getSurvey(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/survey/\(self.surveyId)") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let survey = try JSONDecoder().decode(SurveyJSON.self, from: data)
                DispatchQueue.main.async {
                    self.survey = survey.data!
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func sendAnswers(){
        var flag = false
        var selectedOptions: Array<Int> = []
        questions?.forEach{question in
            if let optionId = question.selectedOptionId{
                selectedOptions.append(optionId)
            } else {
                self.error = "Bütün soruları cevaplamanız gerekiyor"
                flag = true
            }
        }
        if flag{
            return
        }
        
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/survey/\(surveyId)/vote") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        var body: [String: String]
        do{
            
            let encoder = JSONEncoder()
            let optionsData = try encoder.encode(selectedOptions)
            let string : String? = String(data: optionsData, encoding: .utf8)
            body = ["options": string!]
        } catch {
            self.error = "Bir hata meydana geldi"
            return
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(ScoreGamePointsResponseJSON.self, from: data)
                if (response.status != true){
                    self.error = response.errors![0]
                    return
                }
                self.popUpText = "Yanıtlarınız gönderildi"
                self.popUp = true
                DispatchQueue.main.async {
                    pm.wrappedValue.dismiss()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func changeSelectedOption(item: SurveyQuestion, optionId: Int) {
        if let index = questions!.firstIndex(where: { $0.id == item.id }) {
            questions![index].selectedOptionId = optionId
            }
        }
}
