//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct SendMailView : View {
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @State var documents: [Document]?
    @State var selectedDocuments = Set<Int>()
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
                        Text("Sunumunun mail olarak paylaşılmasına izin veren konuşmacıların sunumlarını kendinize mail olarak gönderebilirsiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.sendMailBlue)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screen_width)
                    .background(AppColors.sendMailBlue)
                    ScrollView(.vertical){
                        VStack(alignment: .leading, spacing: 10){
                            ForEach(documents ?? []){document in
                                if document.session != nil {
                                    HStack{
                                        VStack(alignment: .leading){
                                            Text(document.session?.start_at! ?? "")
                                                .foregroundColor(Color.black)
                                                .bold()
                                            Spacer()
                                            Text(document.session?.finish_at! ?? "")
                                                .foregroundColor(Color.black)
                                                .bold()
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.20)
                                        .background(AppColors.programDateYellow)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(8)
                                        VStack(alignment: .leading){
                                            Text(document.session?.title! ?? "")
                                                .font(.system(size: 20))
                                                .multilineTextAlignment(.leading)
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.65)
                                        .background((selectedDocuments.contains(document.id!) || document.is_requested!) ? Color.red : AppColors.programTitleBlue)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(8)
                                    }.onTapGesture{
                                        if selectedDocuments.contains(document.id!)
                                        {
                                            self.selectedDocuments.remove(document.id!)
                                        }
                                        else
                                        {
                                            self.selectedDocuments.insert(document.id!)
                                        }
                                    }
                                }
                                
                            }
                        }.padding()
                    }.frame(width: screen_width, height: screen_height*0.7).background(Color.white)
                    Spacer()
                    ZStack(alignment: .center){
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                        HStack{
                            Image("send_mail_button")
                                .resizable()
                                .frame(width: screen_width*0.05, height: screen_width*0.05)
                            Text("Mail Gönder")
                                .foregroundColor(Color.white)
                        }
                        .padding().background(AppColors.buttonLightBlue).bold()
                        .cornerRadius(5)
                        .onTapGesture {
                            sendMail()
                        }
                    }
                    
                }.background(AppColors.bgBlue)
            }
        }
        .alert(popUpText, isPresented: $popUp){
            Button("OK", role: .cancel){}
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            getMeeting()
            getDocuments()
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
    
func getDocuments(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/document") else {
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
                let documents = try JSONDecoder().decode(DocumentsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.documents = documents.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func sendMail(){
        
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/mail") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        var body: [String: String]
        do{
            
            let encoder = JSONEncoder()
            let documentsData = try encoder.encode(Array(selectedDocuments))
            let string : String? = String(data: documentsData, encoding: .utf8)
            body = ["documents": string!]
        } catch {
            self.popUpText = "Bir hata meydana geldi"
            self.popUp = true
            return
        }
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(ScoreGamePointsResponseJSON.self, from: data)
                if (response.status != true){
                    self.popUpText = response.errors![0]
                    self.popUp = true
                    return
                }
                self.popUpText = "İstediğiniz dökümanlar kongreden sonra size mail olarak gönderilecek"
                self.popUp = true
                DispatchQueue.main.async {
                    pm.wrappedValue.dismiss()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
