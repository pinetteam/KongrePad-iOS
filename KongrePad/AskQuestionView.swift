//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct AskQuestionView : View {
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @State var hallId: Int!
    @State var question = "soru"
    @State var is_hidden_name = false
    @State var popUp = false
    @State var popUpText = ""
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
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
                        Text("Sunucuya sormak istediğiniz soruyu yazın")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }
                    Spacer()
                    VStack{
                        Text("Soru Sor").font(.system(size: 40)).bold().foregroundColor(Color.white)
                        Image(systemName: "questionmark").font(.system(size: 40)).bold().foregroundColor(Color.white)
                        TextField("soru", text: $question, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .background(Color.gray)
                            .frame(height: screen_height*0.4)
                            .cornerRadius(10).padding()
                        HStack{
                            Image(systemName: is_hidden_name ? "checkmark.square" : "square.fill")
                            Text("İsmim Görünmesin")
                        }
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.4)
                            .onTapGesture {
                                self.is_hidden_name = !self.is_hidden_name
                            }
                    }.frame(width: screen_width*0.7).background(Color.red).cornerRadius(10)
                    Spacer().frame(height: 15)
                    Text("GÖNDER")
                        .frame(width: screen_width*0.7, height: screen_height*0.05)
                        .background(Color.green)
                        .cornerRadius(5)
                        .onTapGesture {
                        askQuestion()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }
        .alert(popUpText, isPresented: $popUp){
            Button("OK", role: .cancel){}
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getMeeting()
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
    func askQuestion(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(String(describing: self.hallId!))/session-question") else {
            return
        }
        let body: [String: Any] = ["question": self.question, "is_hidden_name": self.is_hidden_name ? 1 : 0]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(SessionQuestionResponseJSON.self, from: data)
                if(response.status!){
                    self.popUpText = "Sorunuz Gönderildi"
                    self.popUp = true
                } else {
                    self.popUpText = "Bir Sorun Meydana geldi"
                    self.popUp = true
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
