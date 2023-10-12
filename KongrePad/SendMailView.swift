//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI

struct SendMailView : View {
    @Environment(\.presentationMode) var pm
    @State var programDay: ProgramDay?
    @State var documents: [Document]?
    @State var selectedDocuments = Set<Int>()
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
                        }
                        Spacer()
                        Text("\(programDay?.day! ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.sendMailBlue)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.sendMailBlue)
                    
                ScrollView(.vertical){
                    VStack(spacing: 10){
                        ForEach(self.programDay?.programs ?? []){program in
                            HStack{
                                VStack(alignment: .center, spacing: 0){
                                    Text(program.start_at!)
                                        .foregroundColor(Color.black)
                                        .bold()
                                    RoundedRectangle(cornerRadius: 5)
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.004)
                                        .foregroundColor(Color.black)
                                    Text(program.finish_at!)
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
                                    Text(program.title!)
                                        .font(.system(size: 15))
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .padding()
                                    ForEach(program.debates ?? []){debate in
                                        Text("- \(debate.title ?? "")")
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding([.bottom, .trailing, .leading])
                                    }
                                    if program.chairs != nil{
                                        VStack{
                                            Text("Oturum Başkanları:")
                                                .foregroundColor(Color.gray)
                                                .font(.system(size: 12))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                            ForEach(program.chairs ?? []){chair in
                                                Text("\(chair.full_name ?? "")")
                                                    .foregroundColor(Color.gray)
                                                    .font(.system(size: 12))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                            }
                                        }
                                        .padding([.bottom, .trailing, .leading])
                                    }
                                }
                                .frame(maxHeight: .infinity)
                                .frame(width: screen_width*0.65)
                                .background(AppColors.programTitleBlue)
                                .overlay (
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(.black)
                                )
                                .cornerRadius(8)
                            }
                            ForEach(program.sessions ?? []){session in
                                HStack{
                                    VStack(alignment: .center, spacing: 0){
                                        Text(session.start_at!)
                                            .foregroundColor(Color.black)
                                            .bold()
                                        RoundedRectangle(cornerRadius: 5)
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.004)
                                            .foregroundColor(Color.black)
                                        Text(session.finish_at!)
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
                                        HStack{
                                            if (session.document_id != nil && session.is_document_requested! == false ){
                                                if (session.document_sharing_via_email! != false){
                                                    Image(systemName: (selectedDocuments.contains(session.document_id ?? 0)) ? "checkmark.square" : "square")
                                                }
                                            } else if session.is_document_requested! {
                                                Image(systemName: "checkmark.square").foregroundColor(.gray)
                                            }
                                            Text(session.title!)
                                                .font(.system(size: 15))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                        }.onTapGesture{
                                            if (session.document_id != nil){
                                                if selectedDocuments.contains(session.document_id!)
                                                {
                                                    self.selectedDocuments.remove(session.document_id!)
                                                }
                                                else
                                                {
                                                    self.selectedDocuments.insert(session.document_id!)
                                                }
                                            }
                                        }
                                        .padding()
                                        if session.speaker_name != nil{
                                            Text("Konuşmacı: \(session.speaker_name!)")
                                                .foregroundColor(Color.gray)
                                                .font(.system(size: 12))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding([.bottom, .trailing, .leading])
                                        }
                                    }
                                    .frame(maxHeight: .infinity)
                                    .frame(width: screen_width*0.65)
                                    .background(AppColors.programTitleBlue)
                                    .overlay (
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(.black)
                                    )
                                    .cornerRadius(8)
                                }
                                .padding([.leading])
                                
                            }
                               
                        }
                    }
                }.frame(width: screen_width*0.85, height: screen_height*0.8)
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
        .navigationBarBackButtonHidden(true)
        .onAppear{
            getDocuments()
        }
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
            alertManager.present(text: "Bir hata meydana geldi")
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
                    alertManager.present(text: response.errors![0])
                    return
                }
                alertManager.present(text: "Paylaşıma izin verilen sunumlardan talep ettikleriniz kongreden sonra tarafınıza mail olarak gönderilecektir.")
                DispatchQueue.main.async {
                    pm.wrappedValue.dismiss()
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
