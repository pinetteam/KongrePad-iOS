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
    @State var selectedDocuments: Set = [0]
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack(alignment: .topLeading){
                        Text("Sunumunun mail olarak paylaşılmasına izin veren konuşmacıların sunumlarını kendinize mail olarak gönderebilirsiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                            Image(systemName: "chevron.left")
                            .font(.system(size: 20)).bold().padding(8)
                            .foregroundColor(Color.blue)
                            .background(
                                Circle().fill(AppColors.buttonLightBlue)
                            )
                            .padding(5)
                            .onTapGesture {
                                pm.wrappedValue.dismiss()
                            }
                    }.frame(width: screen_width)
                    ScrollView(.vertical){
                        VStack(alignment: .leading, spacing: 10){
                            ForEach(self.documents ?? []){document in
                                HStack{
                                    Button(action: {
                                        if selectedDocuments.contains(document.id!)
                                            {
                                                self.selectedDocuments.remove(document.id!)
                                            }
                                        else
                                            {
                                                self.selectedDocuments.insert(document.id!)
                                            }
                                    }){
                                        if document.sharing_via_email == 1{
                                            Image(systemName: selectedDocuments.contains(document.id!) ? "square.fill" : "square")
                                        }
                                        Text("\(document.title ?? "")").foregroundColor(Color.black)
                                        
                                    }
                                }
                                Divider()
                            }
                        }.padding()
                    }.frame(width: screen_width, height: screen_height*0.8).background(Color.white)
                    Spacer()
                    ZStack(alignment: .center){
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                        Label("Mail Gönder", systemImage: "envelope")
                            .foregroundColor(Color.white)
                            .padding().background(AppColors.buttonLightBlue).bold()
                            .cornerRadius(5)
                            .onTapGesture {
                                sendMail()
                            }
                    }
                    
                }.background(AppColors.bgBlue)
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
