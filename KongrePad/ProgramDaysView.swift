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
    @Binding var hallId: Int
    @State var virtualStands: [VirtualStand]?
    @State var programs: [Program]?
    @State var programDays: [ProgramDay]?
    @State var isLoading : Bool = true
    
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
                        }
                        Spacer()
                        Text("Bilimsel Program")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.buttonYellow)
                    Spacer()
                    if !isLoading{
                        VStack(alignment: .center){
                            ScrollView(.vertical){
                                VStack(spacing: 10){
                                    ForEach(self.programDays ?? []){day in
                                        NavigationLink(destination: ProgramsView(programDay: day)){
                                            HStack{
                                                Image("double_right_arrow")
                                                    .resizable()
                                                    .frame(width: screen_height*0.035, height: screen_height*0.035)
                                                    .padding()
                                                Text(day.day!)
                                                    .font(.system(size: 20))
                                                    .foregroundColor(AppColors.bgBlue)
                                                    .padding()
                                                Spacer()
                                            }
                                            .frame(width: screen_width*0.9, height: screen_height*0.08)
                                            .background(AppColors.programButtonBlue)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(8)
                                        }
                                    }
                                }
                            }.frame(width: screen_width*0.9, height: screen_height*0.7)
                        }
                    } else {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                                .frame(width: screen_width, height: screen_height*0.7)
                                .background(AppColors.bgLightYellow)
                    }
                    Spacer()
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgLightYellow)
        }
        .onAppear{
            getPrograms()
        }
    }
    
    func getPrograms(){
        self.isLoading = true
        @State var isLoading : Bool = true
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
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }

}
