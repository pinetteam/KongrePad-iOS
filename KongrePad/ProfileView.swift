//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProfileView: View{
    @Environment(\.presentationMode) var pm
    @State var logOut = false
    @State var meeting: Meeting?
    @State var participant: Participant?
    @State var bannerName : String = ""
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    ZStack(alignment: .topLeading){
                        Text("\(participant?.full_name ?? "")")
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
                        Spacer()
                        VStack(spacing: 20){
                                AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/meeting-banners/\(self.bannerName)")){ image in
                                    image
                                        .resizable().clipShape(Circle()).frame(width: screen_width*0.3, height: screen_height*0.2)
                                    
                                } placeholder: {
                                    Circle().frame(width: screen_width*0.3, height: screen_height*0.2)
                                }
                            Text((self.participant?.full_name) ?? "")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.blue, lineWidth: 4)
                                    )
                            Text((self.participant?.email) ?? "")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.blue, lineWidth: 4)
                                    )
                            Text((self.participant?.phone) ?? "")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.blue, lineWidth: 4)
                                    )
                            Text((self.participant?.organisation) ?? "")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.5)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(.blue, lineWidth: 4)
                                    )
                        }
                    Spacer()
                    ZStack(alignment: .topLeading){
                        Text("Bilgilerinizde eksik veya hatalı bilgi var ise lütfen ön masa ile irtibata geçiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width, height: screen_height*0.1).padding()
                            .background(AppColors.bgBlue).multilineTextAlignment(.center)
                    }
                    }.navigationBarBackButtonHidden(true)
                }
                .background(AppColors.bgBlue)
                
                
            }
            .onAppear{
                getMeeting()
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
                    self.bannerName = "\(String(describing: meeting.data!.banner_name!)).\(String(describing: meeting.data!.banner_extension!))"
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
        
    }
