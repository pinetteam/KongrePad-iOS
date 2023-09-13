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
    @State var programDay: ProgramDay?
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
                        Text("Bilimsel Program")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }
                    Spacer().frame(height: 5)
                    VStack(alignment: .center){
                        Text("Bilimsel Program")
                            .font(.largeTitle)
                            .foregroundColor(AppColors.bgBlue)
                            .frame(width: screen_width*0.85)
                            .background(AppColors.buttonYellow)
                            .cornerRadius(5)
                        Spacer().frame(height: 5)
                        Text("\(programDay?.day ?? "")")
                            .foregroundColor(AppColors.bgBlue)
                            .bold()
                            .frame(width: screen_width*0.85)
                            .background(AppColors.buttonYellow)
                            .cornerRadius(5)
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programDay?.programs ?? []){program in
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(program.start_at!)
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                            Spacer()
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
                                                .multilineTextAlignment(.leading)
                                            ForEach(program.debates ?? []){debate in
                                                Text("- \(debate.title ?? "")").multilineTextAlignment(.leading)
                                                
                                            }
                                            
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.65)
                                        .background(AppColors.programTitleBlue)
                                        .cornerRadius(5)
                                    }
                                    ForEach(program.sessions ?? []){session in
                                        HStack{
                                            VStack(alignment: .leading){
                                                Text(session.start_at!)
                                                        .foregroundColor(Color.black)
                                                        .bold()
                                                Spacer()
                                                Text(session.finish_at!)
                                                        .foregroundColor(Color.black)
                                                        .bold()
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programDateYellow)
                                                .cornerRadius(5)
                                            VStack(alignment: .leading){
                                                Text(session.title!)
                                                    .font(.system(size: 20))
                                                    .multilineTextAlignment(.leading)
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.65)
                                            .background(AppColors.programTitleBlue)
                                            .cornerRadius(5)
                                        }
                                        
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

}
