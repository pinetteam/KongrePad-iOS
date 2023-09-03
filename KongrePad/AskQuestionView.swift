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
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack(alignment: .topLeading){
                        Text("Sunucuya sormak istediğiniz soruyu yazın")
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
                    TextField("soru", text: $question, axis: .vertical).textFieldStyle(.roundedBorder).background(Color.gray)
                    Toggle("İsmim görünmesin", isOn: $is_hidden_name).frame(width: screen_width*0.5)
                    Text("Soru sor").padding().background(Color.green).onTapGesture {
                        askQuestion()
                    }
                }
            }
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
                DispatchQueue.main.async {
                    if(response.data != nil){
                        self.question = "Sorunuz Gönderildi"
                    } else {
                        self.question = "Bir Sorun Meydana geldi"
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
