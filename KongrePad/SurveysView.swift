//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI

struct SurveysView: View{
    @Environment(\.presentationMode) var pm
    @State var goToSurvey = false
    @State var popUp = false
    @State var popUpText = ""
    @State var meeting: Meeting?
    @State var participant: Participant?
    @State var surveys: [Survey]?
    @State var surveyId = 0
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.blue)
                        .background(
                            Circle().fill(AppColors.buttonLightBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }.frame(width: screen_width*0.1)
                        VStack{
                            Text("ANKETLER")
                                .foregroundColor(Color.white).font(.system(size:20))
                            Text("Anketlerimizi doldurarak bize yardımcı olabilirsiniz")
                                .foregroundColor(Color.white).font(.system(size:15))
                        }
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }
                    Spacer().frame(height: 20)
                    NavigationLink(destination: SurveyView(surveyId: $surveyId, popUp: $popUp, popUpText: $popUpText), isActive: $goToSurvey){
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(Array(self.surveys?.enumerated() ?? [].enumerated()), id: \.element){index, survey in
                                    HStack{
                                        if index%2 == 0{
                                            Text(survey.title!)
                                                .font(.system(size: 20)).bold()
                                                .foregroundColor(Color.white)
                                                .frame(width: screen_width*0.4, height: screen_width*0.4)
                                                .background(survey.is_completed! ? Color.red : AppColors.buttonDarkBlue)
                                                .cornerRadius(20)
                                                .onTapGesture{
                                                    if !survey.is_completed!{
                                                        self.surveyId = survey.id!
                                                        self.goToSurvey = true
                                                    }
                                                }
                                            if(index < surveys!.count - 1){
                                                Text(surveys![index+1].title!)
                                                    .font(.system(size: 20)).bold()
                                                    .foregroundColor(Color.white)
                                                    .frame(width: screen_width*0.4, height: screen_width*0.4)
                                                    .background(surveys![index+1].is_completed! ? Color.red : AppColors.buttonDarkBlue)
                                                    .cornerRadius(20)
                                                    .onTapGesture{
                                                        if !surveys![index+1].is_completed!{
                                                            self.surveyId = surveys![index+1].id!
                                                            self.goToSurvey = true
                                                        }
                                                    }
                                            }
                                        }
                                    }
                                    
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.8)
                    }
                }
                .navigationBarBackButtonHidden(true)
                    
                }
            .background(AppColors.bgBlue)
        }
        .alert(popUpText, isPresented: $popUp){
            Button("OK", role: .cancel){}
        }
        .onAppear{
            getMeeting()
            getSurveys()
            getParticipant()
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
    
    func getParticipant(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/participant") else {
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
                let participant = try JSONDecoder().decode(ParticipantJSON.self, from: data)
                DispatchQueue.main.async {
                    self.participant = participant.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getSurveys(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/survey") else {
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
                let surveys = try JSONDecoder().decode(SurveysJSON.self, from: data)
                DispatchQueue.main.async {
                    self.surveys = surveys.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
