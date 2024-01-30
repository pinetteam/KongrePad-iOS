//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI
import PDFKit

struct SessionView : View {
    @ObservedObject var loadingViewModel = LoadingViewModel()
    @Environment(\.presentationMode) var pm
    @State var pdfURL: URL?
    @State var document: Document?
    @State var participant: Participant?
    @State var session: Session?
    @State var bannerName : String = ""
    @State var isLoading : Bool = true
    @Binding var hallId: Int
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(spacing: 0){
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
                        Text("Sunum İzle")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width*0.7, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding()
                        .frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    if !isLoading{
                        if self.session == nil{
                            Text("Oturum henüz başlamamıştır!").bold()
                                .foregroundColor(Color.white).font(.title2)
                                .frame(width: screen_width, height: screen_height*0.8)
                                .background(AppColors.bgBlue)
                        } else if self.document?.allowed_to_review! == 0{
                            Text("Sunum önizlemeye kapalıdır!").bold()
                                .foregroundColor(Color.white).font(.title2)
                                .frame(width: screen_width, height: screen_height*0.8)
                                .background(AppColors.bgBlue)
                        } else if self.pdfURL == nil{
                            Text("Bu oturum için yüklenmiş sunum bulunmamaktadır!").bold()
                                .foregroundColor(Color.white).font(.title2)
                                .frame(width: screen_width, height: screen_height*0.8)
                                .background(AppColors.bgBlue)
                        } else {
                            PdfKitRepresentedView(documentURL: $pdfURL)
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.white))
                            .frame(width: screen_width, height: screen_height*0.8)
                            .background(AppColors.bgBlue)
                    }
                    ZStack(alignment: .center){
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                        if(self.session != nil && self.participant?.type == "attendee"){
                            NavigationLink(destination: AskQuestionView(hallId: $hallId)){
                                HStack{
                                    Image(systemName: "questionmark")
                                        .bold()
                                        .foregroundColor(.white)
                                    Text("Soru Sor")
                                        .foregroundColor(Color.white)
                                }.padding()
                                    .padding(.leading, 20)
                                    .padding(.trailing, 20)
                                    .background(AppColors.buttonRed)
                                    .cornerRadius(10)
                            }
                        }
                    }.shadow(radius: 6)
                }.ignoresSafeArea(.all, edges: .bottom).background(AppColors.bgBlue)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .task{
            getSession()
            getDocument()
            getParticipant()
        }
    }
    func getDocument(){
        self.isLoading = true
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(self.hallId)/active-document") else {
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
                let document = try JSONDecoder().decode(DocumentJSON.self, from: data)
                if document.status!{
                    DispatchQueue.main.async {
                        self.document = document.data
                    }
                    self.pdfURL = URL(string: "https://app.kongrepad.com/storage/documents/\(String(describing: document.data!.file_name!)).\(String(describing: document.data!.file_extension!))")!
                }
            } catch {
                print(error)
            }
            DispatchQueue.main.async {
                self.isLoading = false
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
    func getParticipant(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/participant") else {
            return
        }
        
        var request2 = URLRequest(url: url)
        
        request2.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request2) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let participant = try JSONDecoder().decode(ParticipantJSON.self, from: data)
                DispatchQueue.main.async {
                    self.participant = participant.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
struct PdfKitRepresentedView : UIViewRepresentable {
    
    @Binding var documentURL : URL?
    
    func makeUIView(context: Context) -> some PDFView {
        let pdfView : PDFView = PDFView()
        if let documentURL{
            pdfView.document = PDFDocument(url: self.documentURL!)
        }
        pdfView.displayDirection = .vertical
        pdfView.autoScales = true
        
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        if let documentURL {
            uiView.document = PDFDocument(url: documentURL)
        } else {
            uiView.document = nil
        }
        
    }
}

