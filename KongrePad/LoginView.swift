//
//  DenemeView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 21.08.2023.
//

import SwiftUI
import CodeScanner

struct LoginView: View {
    
    @State var isPresentingScanner = false
    @State var goToMainPage = false
    @State var scanError : String = ""
    
    var scannerSheet : some View {
        CodeScannerView(codeTypes: [.qr], completion: {
            result in
            if case let .success(code) = result{
                guard let url = URL(string: "https://app.kongrepad.com/api/v1/auth/login/participant") else {
                    return
                }
                
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: AnyHashable] = [
                    "username" : code.string,
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
                URLSession.shared.dataTask(with: request) {data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    do{
                        let response = try JSONSerialization.jsonObject(with: data,options: .allowFragments) as! [String: Any]
                        let userDefault = UserDefaults.standard
                        guard let token = response["token"]  else {
                            self.scanError = "Wrong Qr Code"
                            return
                        }
                        self.goToMainPage = true
                        userDefault.set(token, forKey: "token")
                        userDefault.synchronize()
                    } catch {
                        print(error)
                    }
                }.resume()
                self.isPresentingScanner = false
            }
        })
        }
    
    var body: some View {
        
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                ZStack{
                    Image("giris").resizable().aspectRatio(contentMode: .fill).edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center){
                        Image(uiImage: UIImage(named: "logo")!).padding(70)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                        Spacer().frame(height: 30)
                        Button(action: {
                            self.isPresentingScanner = true
                        }){
                            Label("Log in", systemImage: "play")
                                .labelStyle(.titleAndIcon)
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: screen_width*0.5, height: 100)
                                .foregroundColor(Color.white)
                                .background(Color.orange).cornerRadius(30)
                        }.sheet(isPresented: $isPresentingScanner) {
                            self.scannerSheet
                        }
                        Text(self.scanError).foregroundColor(Color.red).font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        Text("Giriş butonuna bastıktan sonra kameraya yaka kartıınızda bulunan Qr Kod'u okutunuz.").font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        
                    }.padding()
                }.frame(width: screen_width, height: screen_height)}
            .navigationDestination(isPresented: $goToMainPage){
                MainPageView()
                }
        }.onAppear{
            
            let userDefault = UserDefaults.standard
            userDefault.set("2|laravel_sanctum_pr7FcD1tnIn2StI9VzVEcXtmAVbbCo6XmvTKG6nGcad406ae", forKey: "token")
            userDefault.synchronize()
                if(UserDefaults.standard.string(forKey: "token") != nil)
                {
                    self.goToMainPage = true
                    
                }
        }
        
    }

    
    struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
            LoginView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
