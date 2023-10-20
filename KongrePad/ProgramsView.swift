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
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer().frame(height: 5)
                    VStack(alignment: .center){
                        Spacer().frame(height: 5)
                        VStack{
                            Text("\(hall?.title ?? "")")
                                .font(.title2)
                                .foregroundColor(.black)
                            Text("\(programDay?.day ?? "")")
                                .font(.footnote)
                                .foregroundColor(.gray)
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
                                        VStack(alignment: .leading){
                                            if program.logo_name != nil {
                                                AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/program-logos/\(getLogoName(program: program))")){ image in
                                                    image
                                                        .resizable()
                                                        .ignoresSafeArea()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(height: screen_height*0.05)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .padding([.top, .leading, .trailing])
                                            }
                                            Text(program.title!)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                            if program.description != nil{
                                                VStack{
                                                    Text(program.description!)
                                                        .foregroundColor(Color.gray)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
                                                .padding([.bottom, .trailing, .leading])
                                            }
                                            ForEach(program.debates ?? []){debate in
                                                Text("- \(debate.title ?? "")")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding([.bottom, .trailing, .leading])
                                                if debate.description != nil{
                                                    VStack{
                                                        Text(debate.description!)
                                                            .foregroundColor(Color.gray)
                                                            .font(.footnote)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                    .padding([.bottom, .trailing, .leading])
                                                }
                                            }
                                            if program.chairs?.count != 0{
                                                VStack{
                                                    Text(getChairs(program: program).dropLast())
                                                        .foregroundColor(Color.gray)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                }
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
                                            VStack(alignment: .leading){
                                                Text(session.title!)
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                if session.description != nil{
                                                    VStack{
                                                        Text(session.description!)
                                                            .foregroundColor(Color.gray)
                                                            .font(.footnote)
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                    .padding([.bottom, .trailing, .leading])
                                                }
                                                if session.speaker_name != nil{
                                                    Text("Konuşmacı: \(session.speaker_name!)")
                                                        .foregroundColor(Color.gray)
                                                        .font(.footnote)
                                                        .frame(maxWidth: .infinity, alignment: .leading)
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
                                       
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.8)
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
