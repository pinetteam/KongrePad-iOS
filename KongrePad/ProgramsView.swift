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
    @State var programDay: ProgramDay?
    @State var hall: Hall?
    @State var hallId: Int?
    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    ZStack{
                    HStack(alignment: .center){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20)).bold().padding(8)
                            .foregroundColor(AppColors.buttonYellow)
                            .background(
                                Circle().fill(.white)
                            )
                            .onTapGesture {
                                pm.wrappedValue.dismiss()
                            }.frame(width: screen_width*0.1)
                        Spacer()
                    }
                    Text("Bilimsel Program")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.buttonYellow)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.black), alignment: .bottom).shadow(radius: 6)
                    Spacer().frame(height: 5)
                    VStack(alignment: .center){
                        Spacer().frame(height: 5)
                        VStack{
                            Text("\(hall?.title ?? "")")
                                .font(.title2)
                                .foregroundColor(.black)
                            Text("\(programDay?.day ?? "")")
                                .font(.footnote)
                                .foregroundColor(.black)
                        }
                            .padding()
                            .frame(width: screen_width*0.87)
                            .background(AppColors.programDateYellow)
                            .overlay (
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(.black)
                            )
                            .cornerRadius(10)
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programDay?.programs ?? []){program in
                                    HStack{
                                        VStack(alignment: .center, spacing: 0){
                                            Text(program.start_at!)
                                                .padding([.bottom, .top])
                                                .foregroundColor(Color.black)
                                                .bold()
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(maxHeight: .infinity)
                                                .frame(width: screen_width*0.004)
                                                .foregroundColor(Color.black)
                                            Text(program.finish_at!)
                                                .padding([.bottom, .top])
                                                .foregroundColor(Color.black)
                                                .bold()
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.20)
                                        .background(AppColors.programDateYellow)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(10)
                                        VStack(alignment: .leading, spacing: 0){
                                            if program.logo_name != nil {
                                                AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/program-logos/\(getLogoName(program: program))")){ image in
                                                    image
                                                        .resizable()
                                                        .ignoresSafeArea()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: screen_width*0.325)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .padding([.top, .leading, .trailing])
                                            }
                                            Text(program.title!)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .frame(maxHeight: .infinity)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .padding([.bottom, .trailing, .leading, .top])
                                            if program.chairs?.count != 0{
                                            Text(getChairs(program: program).dropLast())
                                                    .foregroundColor(Color.black)
                                                .font(.footnote)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .fixedSize(horizontal: false, vertical: true)
                                                .padding([.bottom, .trailing, .leading])
                                            }
                                            if program.description != nil{
                                                    Text(program.description!)
                                                    .foregroundColor(Color.black)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .padding([.bottom, .trailing, .leading])
                                            }
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.65)
                                        .background(AppColors.programTitleBlue)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 10)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(10)
                                    }
                                    .frame(maxHeight: .infinity)
                                    ForEach(program.sessions ?? []){session in
                                        HStack{
                                            VStack(alignment: .center, spacing: 0){
                                                Text(session.start_at!)
                                                    .padding([.bottom, .top])
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(maxHeight: .infinity)
                                                    .frame(width: screen_width*0.004)
                                                    .foregroundColor(Color.black)
                                                Text(session.finish_at!)
                                                    .padding([.bottom, .top])
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programDateYellow)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(10)
                                            VStack(alignment: .leading, spacing: 0){
                                                Text(session.title!)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding()
                                            if session.description != nil{
                                                Text(session.description!)
                                                    .foregroundColor(Color.black)
                                                    .font(.footnote)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding([.bottom, .trailing, .leading])
                                                }
                                                if session.speaker_name != nil{
                                                    Text("Konuşmacı: \(session.speaker_name!)")
                                                        .foregroundColor(Color.black)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .padding([.bottom, .trailing, .leading])
                                                }
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.61)
                                            .background(AppColors.programTitleBlue)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(10)
                                        }
                                        .padding([.leading])
                                        
                                    }
                                    
                                    ForEach(program.debates ?? []){debate in
                                        HStack {
                                            VStack(alignment: .center, spacing: 0){
                                                Text(program.start_at!)
                                                    .padding([.bottom, .top])
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                                RoundedRectangle(cornerRadius: 10)
                                                    .frame(maxHeight: .infinity)
                                                    .frame(width: screen_width*0.004)
                                                    .foregroundColor(Color.black)
                                                Text(program.finish_at!)
                                                    .padding([.bottom, .top])
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programDateYellow)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(10)
                                            VStack{
                                                Text(debate.title!)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .fixedSize(horizontal: false, vertical: true)
                                                    .padding([.top, .bottom, .trailing, .leading])
                                                if debate.description != nil{
                                                    Text(debate.description!)
                                                        .foregroundColor(Color.black)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .padding([.bottom, .trailing, .leading])
                                                }
                                                ForEach(debate.teams ?? []){team in
                                                    Label(team.title!, systemImage: "person.3.fill")
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .fixedSize(horizontal: false, vertical: true)
                                                        .padding([.bottom, .trailing, .leading])
                                                    if team.description != nil{
                                                        Text(team.description!)
                                                            .foregroundColor(Color.black)
                                                            .font(.footnote)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                            .fixedSize(horizontal: false, vertical: true)
                                                            .padding([.bottom, .trailing, .leading])
                                                    }
                                                }
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.61)
                                            .background(AppColors.programTitleBlue)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(10)
                                        }
                                        .padding(.leading)
                                    }
                                       
                                }
                            }
                        }
                    }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgLightYellow)
        }
        .onAppear{
            getHall()
        }
    }
    
    
    func getLogoName(program: Program) -> String {
        let result: String = program.logo_name! + "." + program.logo_extension!
        return result
    }
    
    func getChairs(program: Program) -> String {
        var result: String = "Oturum Başkanları:"
        
        program.chairs?.forEach {chair in
            result += " " + chair.full_name! + ","
        }
        return result
    }
    
    func getHall(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(String(describing: self.hallId!))") else {
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
                let hall = try JSONDecoder().decode(HallJSON.self, from: data)
                DispatchQueue.main.async {
                    self.hall = hall.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
