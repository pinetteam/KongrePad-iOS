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
    @State var pdfURL: URL
    @State var document: Document?
    @State var meeting: Meeting?
    @State var bannerName : String = ""
    @State var hallId: Int
    
    
    
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(spacing: 0){
                    ZStack(alignment: .topLeading){
                        Text("\(document?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width, height: screen_height*0.1).padding()
                            .background(AppColors.bgBlue).multilineTextAlignment(.center)
                        NavigationLink(destination: MainPageView()){
                            Label("Geri", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                                .font(.system(size: 20))
                                .foregroundColor(Color.blue)
                                .padding(5)
                        }
                    }
                    ZStack(alignment: .bottomTrailing){
                        PdfKitRepresentedView(documentURL: self.pdfURL)
                            .accessibilityLabel("pdf from \(pdfURL)")
                            .accessibilityValue("pdf from \(pdfURL)")
                        NavigationLink(destination: AskQuestionView(hallId: self.hallId)){
                                Label("Soru", systemImage: "questionmark")
                                    .labelStyle(.iconOnly)
                                    .frame(width: screen_width*0.1, height: screen_height*0.05)
                                    .font(.system(size: 20))
                                    .background(Color.blue).padding()
                        }
                    }
            
        }
        }
                
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getMeeting()
                getDocument()
            }
    }
    func getDocument(){
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
                let document = try JSONDecoder().decode(DocumentJSON.self, from: data)
                DispatchQueue.main.async {
                    self.document = document.data
                }
                self.pdfURL = URL(string: "https://app.kongrepad.com/storage/documents/\(String(describing: document.data!.file_name!)).\(String(describing: document.data!.file_extension!))")!
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
    
    let documentURL : URL
    
    init(documentURL : URL){
        self.documentURL = documentURL
    }
    
    func makeUIView(context: Context) -> some UIView {
        let pdfView : PDFView = PDFView()
        
        pdfView.document = PDFDocument(url: self.documentURL)
        pdfView.displayDirection = .vertical
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

