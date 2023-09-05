//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProgramsView: View{
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @Binding var hallId: Int
    @State var participant: Participant?
    @State var virtualStands: [VirtualStand]?
    @State var programs: [Program]?
    @State var bannerName : String = ""
    @State var pdfURL: URL = URL(string: "https://africau.edu/images/default/sample.pdf")!
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                        ZStack(alignment: .topLeading){
                            Text("Kongre programı")
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
                        Text("Bilimsel Program")
                            .foregroundColor(Color.white)
                            .bold()
                            .frame(width: screen_width*0.85)
                            .background(AppColors.buttonYellow)
                            .cornerRadius(5)
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programs ?? []){program in
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(program.start_at!)
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                            Text(program.finish_at!)
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.20)
                                        .background(AppColors.programDateYellow)
                                            .cornerRadius(5)
                                        VStack(alignment: .leading){
                                            Text(program.title!)
                                                .font(.system(size: 20))
                                            ForEach(program.sessions ?? []){session in
                                                Text("- \(session.title ?? "")").multilineTextAlignment(.leading)
                                                
                                            }
                                            ForEach(program.debates ?? []){debate in
                                                Text("- \(debate.title ?? "")").multilineTextAlignment(.leading)
                                                
                                            }
                                            
                                        }
                                        .frame(width: screen_width*0.65)
                                        .background(AppColors.programTitleBlue)
                                        .cornerRadius(5)
                                    }
                                       
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.7)
                    }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)
        }
        .onAppear{
            getMeeting()
            getParticipant()
            getVirtualStands()
            getPrograms()
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
    
    func getVirtualStands(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/virtual-stand") else {
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
                let stands = try JSONDecoder().decode(VirtualStandsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.virtualStands = stands.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getPrograms(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(self.hallId)/program") else {
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
                let programs = try JSONDecoder().decode(ProgramsJson.self, from: data)
                DispatchQueue.main.async {
                    self.programs = programs.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getDocument(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/document") else {
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
                let document = try JSONDecoder().decode(DocumentJSON.self, from: data)
                DispatchQueue.main.async {
                    self.pdfURL = URL(string: "https://app.kongrepad.com/storage/documents/\(String(describing: document.data!.file_name!)).\(String(describing: document.data!.file_extension!))")!
                }
            } catch {
                print(error)
            }
        }.resume()
    }

}
