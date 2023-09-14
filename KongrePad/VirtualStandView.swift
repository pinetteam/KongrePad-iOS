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
    
    
    
    
    var body: some View{
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(spacing: 0){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.black)
                        .background(
                            Circle().fill(Color.white)
                        )
                        .padding(5)
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }.frame(width: screen_width*0.1)
                        Text("\(virtualStand?.title ?? "")")
                            .font(.system(size: 30))
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screen_width)
                    .background(AppColors.bgOrange)
                    PdfKitRepresentedView(documentURL: $pdfURL)
                    Rectangle().frame(width: screen_width, height: screen_height*0.05).foregroundColor(Color.gray)
                }
            }
        }.background(Color.gray)
        .navigationBarBackButtonHidden(true)
        .onAppear{
                getVirtualStand()
            }
    }
    
    func getVirtualStand(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/virtual-stand/\(self.virtualStandId)") else {
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
                let virtualStand = try JSONDecoder().decode(VirtualStandJSON.self, from: data)
                DispatchQueue.main.async {
                    self.virtualStand = virtualStand.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}

