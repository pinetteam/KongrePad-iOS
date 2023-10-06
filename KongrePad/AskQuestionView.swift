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
    @State var question = ""
    @State var is_hidden_name = false
    @EnvironmentObject var alertManager: AlertManager
    
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
                        Spacer()
                    }.frame(width: screen_width)
                        .background(AppColors.bgBlue)
                    Text("\(self.session?.title ?? "")")
                        .foregroundColor(Color.white)
                        .frame(width: screen_width*0.85, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                    Spacer()
                    VStack{
                        Text("\(self.session?.speaker_name ?? "")")
                            .foregroundColor(Color.white)
                            .font(.system(size: 20)).bold()
                            .multilineTextAlignment(.center)
                            .padding(.top, 15)
                        ZStack(alignment: .top){
                            RoundedRectangle(cornerRadius: 10)
                                .frame(width: screen_width*0.85, height: screen_height*0.3)
                                .foregroundColor(.white)
                            TextField("Soru sor", text: $question, axis: .vertical)
                                .frame(width: screen_width*0.84)
                                .background(Color.white)
                                .tint(.red).padding()
                                .onChange(of: question) { _ in
                                    question = String(question.prefix(255))
                                }
                        }.padding()
                        HStack{
                            Image(systemName: is_hidden_name ? "checkmark.square" : "square.fill")
                            Text("İsmimi gizle")
                            Spacer()
                            Text("\(question.count)/255")
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
                    alertManager.present(text: "Sorunuz gönderildi")
                } else {
                    alertManager.present(text: "Bir sorun meydana geldi")
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
