//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI

struct SurveysView: View{
    @ObservedObject var loadingViewModel = LoadingViewModel()
    @Environment(\.presentationMode) var pm
    @State var goToSurvey = false
    @State var isLoading = true
    @State var surveys: [Survey]?
    @State var surveyId = 0
    @State var participant: Participant?
    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
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
                        Text("Anketler")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.sendMailBlue)
                    .overlay(Divider().background(.white), alignment: .bottom)
                    Spacer().frame(height: 20)
                    if !isLoading {
                        if self.participant?.type == "attendee" {
                            NavigationLink(destination: SurveyView(surveyId: $surveyId), isActive: $goToSurvey){
                                ScrollView(.vertical){
                                    VStack(spacing: 10){
                                        ForEach(Array(self.surveys?.enumerated() ?? [].enumerated()), id: \.element){index, survey in
                                            HStack{
                                                Image("surveys_button")
                                                    .resizable()
                                                    .frame(width: screen_width*0.06, height: screen_width*0.06).padding()
                                                Text(survey.title!)
                                                    .font(.system(size: 15)).bold()
                                                    .foregroundColor(Color.white)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                            .padding()
                                            .frame(width: screen_width*0.8)
                                            .background(survey.is_completed! ? Color.red : AppColors.buttonDarkBlue)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(8)
                                            .onTapGesture{
                                                self.surveyId = survey.id!
                                                self.goToSurvey = true
                                            }
                                        }
                                    }
                                }.frame(width: screen_width*0.85, height: screen_height*0.8)
                            }
                        } else {
                           Text("Anketlere Katılma İzniniz Yok")
                               .frame(width: screen_width, height: screen_height*0.7)
                               .background(AppColors.bgBlue)
                        }
                        
                } else {
                           ProgressView()
                               .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                               .frame(width: screen_width, height: screen_height*0.7)
                               .background(AppColors.bgBlue)
                   }
                }
                .navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)
        }
        .onAppear{
            getParticipant()
            getSurveys()
        }
    }
    
    func getParticipant(){
        isLoading = true
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
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }
}
