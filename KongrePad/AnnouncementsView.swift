//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI

struct AnnouncementsView: View{
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @State var participant: Participant?
    @State var announcements: [Announcement]?
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.black)
                        .background(
                            Circle().fill(Color.white)
                        )
                        .padding(5)
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }.frame(width: screen_width*0.1)
                        Text("BİLDİRİMLER")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screen_width)
                    .background(AppColors.notificationsRed)
                    
                    Rectangle().frame(width: screen_width, height: screen_height*0.01).foregroundColor(Color.gray)
                    VStack(alignment: .leading){
                        ScrollView(.vertical){
                            VStack(alignment:.leading, spacing: 10){
                                ForEach(self.announcements ?? []){announcement in
                                    HStack{
                                        Text(announcement.created_at!)
                                            .font(.system(size: 20))
                                            .frame(width: screen_width*0.2)
                                            .cornerRadius(5)
                                            .multilineTextAlignment(.leading)
                                        Text(announcement.title!)
                                            .font(.system(size: 20))
                                            .frame(width: screen_width*0.65, alignment: .leading)
                                            .cornerRadius(5)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Divider()
                                }
                            }.padding()
                        }.frame(width: screen_width, height: screen_height*0.8)
                            .frame(maxHeight: .infinity)
                            .background(AppColors.bgLightPink)
                    }
                    Rectangle().frame(width: screen_width, height: screen_height*0.05).foregroundColor(Color.gray).ignoresSafeArea(.all)
                }.background(Color.gray)
                }.navigationBarBackButtonHidden(true)
        }
        .onAppear{
            getMeeting()
            getAnnouncements()
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
    
    func getAnnouncements(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/announcement") else {
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
                let announcements = try JSONDecoder().decode(AnnouncementsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.announcements = announcements.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
