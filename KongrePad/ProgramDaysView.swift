//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProgramDaysView: View{
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @Binding var hallId: Int
    @State var virtualStands: [VirtualStand]?
    @State var programs: [Program]?
    @State var programDays: [ProgramDay]?
    @State var bannerName : String = ""
    
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
                        Text("BİLİMSEL PROGRAM")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.frame(width: screen_width).background(AppColors.buttonYellow)
                    Spacer()
                    VStack(alignment: .center){
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programDays ?? []){day in
                                    NavigationLink(destination: ProgramsView(programDay: day)){
                                        HStack{
                                            Text(day.day!)
                                                .font(.system(size: 20))
                                                .foregroundColor(AppColors.bgBlue)
                                                .padding()
                                            Spacer()
                                            Image("double_right_arrow")
                                                .resizable()
                                                .frame(width: screen_height*0.035, height: screen_height*0.035)
                                                .padding()
                                        }
                                        .frame(width: screen_width*0.9, height: screen_height*0.08)
                                        .background(AppColors.programButtonBlue)
                                        .cornerRadius(5)
                                        .border(.black)
                                    }    
                                }
                            }
                        }.frame(width: screen_width*0.9, height: screen_height*0.7)
                    }
                    Spacer()
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgLightYellow)
        }
        .onAppear{
            getMeeting()
            getPrograms()
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
                    self.programDays = programs.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }

}
