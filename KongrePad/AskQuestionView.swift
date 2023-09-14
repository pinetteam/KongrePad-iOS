//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct AskQuestionView : View {
    @Environment(\.presentationMode) var pm
    @Binding var hallId: Int
    @State var session: Session?
    @State var question = "Soru sor"
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
                        .foregroundColor(AppColors.bgBlue)
                        .background(
                            Circle().fill(AppColors.logoutButtonBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }.frame(width: screen_width*0.1)
                        Text("\(self.session?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }.frame(width: screen_width)
                    Spacer()
                    VStack{
                        Text("\(self.session?.speaker_name ?? "")")
                            .foregroundColor(Color.white)
                            .bold()
                            .multilineTextAlignment(.center)
                            .padding()
                        TextField("soru", text: $question, axis: .vertical)
                            .frame(width: screen_width*0.85, height: screen_height*0.3)
                            .background(Color.white).cornerRadius(10).padding()
                        HStack{
                            Image(systemName: is_hidden_name ? "checkmark.square" : "square.fill")
                            Text("İsmimi gizle")
                        }
                        .foregroundColor(Color.white)
                        .frame(width: screen_width*0.5)
                        .onTapGesture {
                            self.is_hidden_name = !self.is_hidden_name
                        }.padding()
                    }.frame(width: screen_width*0.9).background(Color.red).cornerRadius(10)
                    Spacer().frame(height: 15)
                    Text("GÖNDER")
                        .frame(width: screen_width*0.9, height: screen_height*0.08)
                        .foregroundColor(Color.white)
                        .background(AppColors.sendButtonGreen)
                        .cornerRadius(5)
                        .onTapGesture {
                        askQuestion()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }
        .onAppear{
            getSession()
        }
        .alert(popUpText, isPresented: $popUp){
            Button("OK", role: .cancel){}
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func askQuestion(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(String(describing: self.hallId))/session-question") else {
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
    
    func getSession(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(self.hallId)/active-session") else {
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
                let session = try JSONDecoder().decode(SessionJSON.self, from: data)
                DispatchQueue.main.async {
                    self.session = session.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
