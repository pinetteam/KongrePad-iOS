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
    @State var selected = true
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack(alignment: .topLeading){
                        Text("Sunumunun mail olarak paylaşılmasına izin veren konuşmacıların sunumlarını kendinize mail olarak gönderebilirsiniz")
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
                    ScrollView(.horizontal){
                        VStack(alignment: .center, spacing: 10){
                            ForEach(self.documents ?? []){document in
                                HStack{
                                        Image(systemName: document.is_selected != false ? "square.fill" : "square")
                                        Text("\(document.title ?? "")")
                                }
                            }
                        }.frame(width: screen_width*0.65)
                    }
                    Text("Mail Gönder").padding().background(Color.green).onTapGesture {
                        sendMail()
                    }
                }
            }
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
    }
}
