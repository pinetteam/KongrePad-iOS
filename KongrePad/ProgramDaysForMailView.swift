//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProgramDaysForMailView: View{
    @Environment(\.presentationMode) var pm
    @Binding var hallId: Int
    @State var programDays: [ProgramDay]?
    @EnvironmentObject var alertManager: AlertManager
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
                        Text("Mail Gönder")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.bgLightBlue)
                    Spacer()
                    if !isLoading {
                    VStack(alignment: .center){
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programDays ?? []){day in
                                    NavigationLink(destination: SendMailView(programDay: day)){
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
                            .background(AppColors.bgBlue)
                }
                    HStack{
                        Image("send_mail_button")
                            .resizable()
                            .frame(width: screen_width*0.05, height: screen_width*0.05)
                        Text("İzin Verilen Tüm Sunumları Gönder")
                            .foregroundColor(Color.white)
                    }
                    .padding().background(AppColors.buttonLightBlue).bold()
                    .cornerRadius(5)
                    .onTapGesture {
                        sendMail()
                    }
                    Spacer()
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)
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
    
    func sendMail(){
        
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/mail_send_all") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(ScoreGamePointsResponseJSON.self, from: data)
                if (response.status != true){
                    alertManager.present(text: response.errors![0])
                    return
                }
                alertManager.present(text: "İstediğiniz dökümanlar kongreden sonra size mail olarak gönderilecek")
                DispatchQueue.main.async {
                    pm.wrappedValue.dismiss()
                }
            } catch {
                print(error)
            }
        }.resume()
    }

}
