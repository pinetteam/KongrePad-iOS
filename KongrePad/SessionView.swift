//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI
import PDFKit

struct SessionView : View {
    @Environment(\.presentationMode) var pm
    @Binding var pdfURL: URL?
    @State var document: Document?
    @State var meeting: Meeting?
    @State var bannerName : String = ""
    @Binding var hallId: Int
    
    
    
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(spacing: 0){
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
                        Text("\(document?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }
                    PdfKitRepresentedView(documentURL: $pdfURL)
                    ZStack(alignment: .trailing){
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                        if(self.pdfURL != nil){
                            NavigationLink(destination: AskQuestionView(hallId: self.hallId)){
                                Label("Soru Sor", systemImage: "questionmark")
                                    .foregroundColor(Color.white)
                                    .frame(width: screen_width*0.3, height: screen_height*0.05)
                                    .font(.system(size: 20))
                                    .background(Color.red)
                                    .cornerRadius(5).padding()
                            }
                        }
                    }
            
                }.background(AppColors.bgBlue)
        }
                
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getMeeting()
                getDocument()
            }
    }
    func getDocument(){
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
        }.resume()
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
                self.bannerName = "\(String(describing: meeting.data!.banner_name!)).\(String(describing: meeting.data!.banner_extension!))"
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
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        
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

