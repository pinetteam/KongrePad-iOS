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
    @State var surveyId: Int
    @State var questions: [SurveyQuestion]?
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack(alignment: .topLeading){
                        Text("Anket")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width, height: screen_height*0.1).padding()
                            .background(AppColors.bgBlue).multilineTextAlignment(.center)
                            Label("Geri", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                                .font(.system(size: 20))
                                .foregroundColor(Color.blue)
                                .padding(5)
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }
                    }
                    ScrollView(.vertical){
                        VStack(alignment: .center, spacing: 10){
                            ForEach(self.questions ?? []){question in
                                Text(question.question ?? "").bold()
                                VStack(alignment: .leading){
                                    ForEach(question.options ?? []){option in
                                        HStack{
                                            Image(systemName: option.is_selected != false ? "square.fill" : "square")
                                            Text(option.option ?? "")
                                            Spacer()
                                        }
                                    }
                                }
                            }
                        }
                    }.frame(width: screen_width*0.8)
                    Text("Cevapları Gönder").padding().background(Color.green).onTapGesture {
                        sendAnswers()
                    }
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getMeeting()
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
                DispatchQueue.main.async {
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
    
    func sendAnswers(){
    }
}
