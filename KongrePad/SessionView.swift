//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI
import PDFKit

struct SessionView : View {
    
    @State var pdfURL: URL
    @State var document: Document?
    
    
    
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
    
    var body: some View{
        VStack{
            Text(document?.title ?? "")
                .onAppear{
                    getDocument()
                }
            PdfKitRepresentedView(documentURL: self.pdfURL)
                .accessibilityLabel("pdf from \(pdfURL)")
                .accessibilityValue("pdf from \(pdfURL)")
        }
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
        pdfView.autoScales = true
        pdfView.displayDirection = .vertical
        pdfView.minScaleFactor = 0.5
        pdfView.maxScaleFactor = 5.0
        
        return pdfView
    }
    
    func updateUIView(_ uiView: UIViewType, context: Context) {
        
    }
}

