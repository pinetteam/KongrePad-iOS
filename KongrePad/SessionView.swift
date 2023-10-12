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
    @State var bannerName : String = ""
    @State var isLoading : Bool = true
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
                            }
                        Spacer()
                        Text("\(document?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    .background(AppColors.bgBlue)
                    if !isLoading{
                        if self.pdfURL == nil || self.document?.sharing_via_email! == 0{
                            Text("Sunum Önizlemeye kapalıdır")
                                .foregroundColor(.black)
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
                        if(self.pdfURL != nil){
                            NavigationLink(destination: AskQuestionView(hallId: $hallId)){
                                HStack{
                                    Image(systemName: "questionmark")
                                        .font(.system(size: 20)).bold()
                                        .foregroundColor(.white)
                                    Text("Soru Sor")
                                        .foregroundColor(Color.white)
                                        .font(.system(size: 20))
                                }
                                .frame(width: screen_width*0.3, height: screen_height*0.05)
                                .background(Color.red)
                                .cornerRadius(5).padding()
                            }
                        }
                    }
                    
                }.ignoresSafeArea(.all, edges: .bottom).background(AppColors.bgBlue)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .task{
            getDocument()
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

