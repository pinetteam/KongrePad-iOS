//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct SurveyView : View {
    @Environment(\.presentationMode) var pm
    @EnvironmentObject var alertManager: AlertManager
    @State var survey: Survey?
    @Binding var surveyId: Int
    @State var questions: [SurveyQuestion]?
    @State var error = ""
    @State var isLoading = true
    @State var isSending = false
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
                            }
                        Spacer()
                        Text("\(survey?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.sendMailBlue)
                    .overlay(Divider().background(.white), alignment: .bottom)
                    if !isLoading{
                    ScrollView(.vertical){
                        VStack(alignment: .leading, spacing: 20){
                            ForEach(self.questions ?? []){question in
                                Text(question.question ?? "").bold()
                                VStack(alignment: .leading){
                                    ForEach(question.options ?? []){option in
                                        HStack{
                                            Button(action:{
                                                if self.survey?.is_completed == false{
                                                    self.changeSelectedOption(item: question, optionId: option.id!)
                                                }
                                            }){
                                                Image(systemName: option.id == question.selected_option ? "circle.fill" : "circle")
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
                } else {
                                   ProgressView()
                                       .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                       .frame(width: screen_width, height: screen_height*0.7)
                                       .background(.white)
                           }
                        Spacer()
                        ZStack(alignment: .center){
                            Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                            VStack{
                                Text(error).padding().foregroundColor(Color.red)
                                if !isSending {
                                    if !(self.survey?.is_completed ?? true){
                                        Text("Cevapları Gönder")
                                            .foregroundColor(Color.white)
                                            .padding().background(Color.green)
                                            .cornerRadius(10)
                                            .onTapGesture {
                                                sendAnswers()
                                            }
                                    } else {
                                        Text("Bu Anketi Zaten Cevapladınız")
                                            .foregroundColor(Color.white)
                                            .padding().background(Color.green)
                                            .cornerRadius(10)
                                    }
                                } else {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                        .frame(width: screen_width*0.3, height: screen_height*0.05)
                                        .background(Color.green)
                                        .cornerRadius(10)
                                }
                            }
                        }
                    }.background(AppColors.bgBlue)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getSurvey()
                getQuestions()
        }
    }
    func getQuestions(){
        self.isLoading = true
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
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }
    
    
    func changeSelectedOption(item: SurveyQuestion, optionId: Int) {
        if let index = questions!.firstIndex(where: { $0.id == item.id }) {
            questions![index].selected_option = optionId
            }
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
        self.isSending = true
        var flag = false
        var selectedOptions: Array<Int> = []
        questions?.forEach{question in
            if let optionId = question.selected_option{
                selectedOptions.append(optionId)
            } else {
                DispatchQueue.main.async {
                    self.isSending = false
                }
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
            DispatchQueue.main.async {
                self.isSending = false
            }
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
                    DispatchQueue.main.async {
                        self.isSending = false
                    }
                    self.error = response.errors![0]
                    return
                }
                alertManager.present(text: "Yanıtlarınız gönderildi") 
                DispatchQueue.main.async {
                    pm.wrappedValue.dismiss()
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.isSending = false
            }
        }.resume()
    }
}
