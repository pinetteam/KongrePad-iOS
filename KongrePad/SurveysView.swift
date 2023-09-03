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
                    ZStack(alignment: .topLeading){
                        Text("Anketlerimizi doldurarak yardımcı olun")
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
                    Spacer().frame(height: 5)
                    VStack(alignment: .center){
                        Text("Anketler")
                            .foregroundColor(Color.white)
                            .bold()
                            .frame(width: screen_width*0.85)
                            .background(AppColors.buttonYellow)
                            .cornerRadius(5)
                        NavigationLink(destination: SurveyView(surveyId: self.surveyId), isActive: $goToSurvey){
                            ScrollView(.vertical){
                                VStack(spacing: 10){
                                    ForEach(self.surveys ?? []){survey in
                                        HStack{
                                            VStack(alignment: .leading){
                                                Text(survey.title!)
                                                    .font(.system(size: 20))
                                            }
                                            .frame(width: screen_width*0.65)
                                            .background(AppColors.programTitleBlue)
                                            .cornerRadius(5)
                                        }.onTapGesture{
                                            self.surveyId = survey.id!
                                            self.goToSurvey = true
                                        }
                                        
                                    }
                                }
                            }.frame(width: screen_width*0.85, height: screen_height*0.5)
                        }
                        }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)
        }
        .onAppear{
            getMeeting()
            getSurveys()
            getParticipant()
        }
    }
    
    
    struct MainPageView_Previews: PreviewProvider {
        static var previews: some View {
            MainPageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
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
