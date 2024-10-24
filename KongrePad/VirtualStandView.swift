//
//  SwiftView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 29.08.2023.
//

import SwiftUI
import PDFKit

struct VirtualStandView : View {
    @Environment(\.presentationMode) var pm
    @Binding var pdfURL: URL?
    @State var virtualStand: VirtualStand?
    @Binding var virtualStandId: Int
    @State var bannerName : String = ""
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .leading, spacing: 0){
                    ZStack{
                        HStack(alignment: .center){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.bgOrange)
                                .background(
                                    Circle().fill(.white)
                                )
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }.frame(width: screen_width*0.1)
                            Spacer()
                        }
                        AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/virtual-stands/\(self.bannerName)")){ image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(height: screen_height*0.05)
                        } placeholder: {
                            ProgressView()
                        }
                    }.padding()
                     .frame(width: screen_width).background(AppColors.bgOrange)
                     .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    PdfKitRepresentedView(documentURL: $pdfURL)
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .onChange(of: virtualStandId) { newValue in
            // virtualStandId değiştiğinde getVirtualStand çağrılır
            getVirtualStand()
        }
        .onAppear{
            getVirtualStand()
        }
    }
    
    func getVirtualStand() {
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/virtual-stand/\(self.virtualStandId)") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do {
                let virtualStand = try JSONDecoder().decode(VirtualStandJSON.self, from: data)
                DispatchQueue.main.async {
                    if let fileName = virtualStand.data?.file_name,
                       let fileExtension = virtualStand.data?.file_extension,
                       let pdfName = virtualStand.data?.pdf_name {

                        // Banner adını güvenli bir şekilde ayarla
                        self.bannerName = "\(fileName).\(fileExtension)"
                        
                        // PDF URL'sini güvenli bir şekilde oluştur
                        if let pdfURL = URL(string: "https://app.kongrepad.com/storage/virtual-stand-pdfs/\(pdfName).pdf") {
                            self.pdfURL = pdfURL
                            print(pdfURL)
                        } else {
                            print("Geçersiz PDF URL'si.")
                        }
                    }
                }
            } catch {
                print("Veri çözümleme hatası: \(error)")
            }
        }.resume()
    }
}
