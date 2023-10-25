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
    @State var asking = false
    @FocusState var showKeyboard:Bool
    @EnvironmentObject var alertManager: AlertManager
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                        HStack(alignment: .center){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.bgBlue)
                                .background(
                                    Circle().fill(.white)
                                )
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }.frame(width: screen_width*0.1)
                            Spacer()
                        }
                        Text("Soru Sor")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width*0.7, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding()
                        .frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    if self.session != nil{
                    if session?.questions_allowed == 1{
                        VStack{
                            Text("Oturum")
                                .foregroundColor(Color.white).font(.title2)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(self.session?.title ?? "")
                                .foregroundColor(Color.gray).font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text("Konuşmacı")
                                .foregroundColor(Color.white).font(.title3)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            Text(self.session?.speaker_name ?? "")
                                .foregroundColor(Color.gray).font(.footnote)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }.padding()
                        VStack{
                            TextField("Soru sor", text: $question, axis: .vertical)
                                .lineLimit(7...)
                                .frame(width: screen_width*0.84)
                                .textFieldStyle(.roundedBorder)
                                .tint(.red)
                                .focused($showKeyboard)
                                .onChange(of: question) { _ in
                                    question = String(question.prefix(255))
                                }.padding()
                            HStack{
                                HStack{
                                    Image(systemName: is_hidden_name ? "checkmark.square" : "square").foregroundColor(.black)
                                    Text("İsmimi gizle").foregroundColor(.black)
                                }
                                .onTapGesture {
                                    self.is_hidden_name = !self.is_hidden_name
                                }
                                Spacer()
                                Text("\(question.count)/255").foregroundColor(question.count < 140 ? .green : (question.count < 255 ? .yellow : .red))
                            }
                            .padding()
                            .background(.white)
                            .cornerRadius(5)
                            .padding()
                        }.frame(width: screen_width*0.9).background(AppColors.buttonRed).cornerRadius(10)
                        Spacer().frame(height: 15)
                        if !asking{
                            Text("Gönder")
                                .frame(width: screen_width*0.9, height: screen_height*0.08)
                                .foregroundColor(Color.white)
                                .background(question.count > 0 && question.count <= 256 ? AppColors.sendButtonGreen : .gray)
                                .cornerRadius(10)
                                .onTapGesture {
                                    if question.count > 0 && question.count <= 256
                                    {
                                        askQuestion()
                                    }
                                }
                        } else {
                            ProgressView()
                                .frame(width: screen_width*0.9, height: screen_height*0.08)
                                .foregroundColor(Color.white)
                                .background(.gray)
                                .cornerRadius(10)
                        }
                    } else if session?.questions_allowed == 0 {
                        Text("Bu Oturumda Soru alınmamaktadır")
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    }
                    } else {
                        Text("Oturum henüz başlamamıştır!").bold()
                            .foregroundColor(Color.white).font(.title2)
                            .frame(width: screen_width, height: screen_height*0.8)
                            .background(AppColors.bgBlue)
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }
        .onTapGesture{
            showKeyboard = false
        }
        .onAppear{
            getSession()
        }
        .navigationBarBackButtonHidden(true)
    }
    
    
    func askQuestion(){
        self.asking = true
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
                    alertManager.present(title: "Başarılı", text: "Sorunuz gönderildi!")
                    DispatchQueue.main.async {
                        pm.wrappedValue.dismiss()
                    }
                } else {
                    alertManager.present(title: "Hata", text: "Bir sorun meydana geldi!")
                }
            } catch {
                print(error)
            }
            self.asking = false
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
