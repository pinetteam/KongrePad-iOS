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
    @State var isPresentingKvkk = false
    @State var isPresentingLoginWithCode = false
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
                    Circle()
                        .frame(width: screen_height*2, height: screen_height*2)
                        .foregroundColor(Color.white)
                        .offset(y: -screen_height*0.6)
                        .frame(width: screen_width, height: screen_height*0.1)
                        .shadow(radius: 6)
                    Circle()
                        .frame(width: screen_height*2, height: screen_height*2)
                        .foregroundColor(AppColors.bgBlue)
                        .offset(y: -screen_height*1.2)
                        .frame(width: screen_width, height: screen_height*0.1)
                        .shadow(radius: 6)
                    VStack(alignment: .center){
                        Image(uiImage: UIImage(named: "logo")!)
                            .resizable()
                            .frame(width: screen_width*0.5, height: screen_width*0.5)
                            .padding(30)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            Spacer().frame(height: screen_height*0.1)
                        Button(action: {
                            self.isPresentingScanner = true
                        }){
                            HStack{
                                Text("GİRİŞ")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(Color.white)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(Color.white)
                            }
                            .frame(width: screen_width*0.5, height: 100)
                            .background(Color.orange)
                            .cornerRadius(50)
                        }.sheet(isPresented: $isPresentingScanner) {
                            self.scannerSheet
                        }.navigationDestination(isPresented: $goToMainPage){
                            MainPageView()
                            }
                        Text(self.scanError).foregroundColor(Color.red).font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        Text("Giriş yap butonuna bastıktan sonra kameraya yaka kartınızda bulunan Qr Kod'u okutunuz.").font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        (
                            Text("Giriş yaparak ") + Text("6698 Sayılı KVKK'yı").underline()
                            + Text(" kabul etmiş sayılırsınız")
                        ).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        .onTapGesture {
                            self.isPresentingKvkk = true
                        }
                        .sheet(isPresented: $isPresentingKvkk) {
                            Text("kvkk kanunu")
                        }
                            
                        Text("KOD İLE GİRİŞ").font(.system(size: 20))
                            .foregroundColor(AppColors.bgBlue)
                            .frame(width: screen_width*0.42, height: screen_height*0.05)
                            .background(AppColors.buttonLightBlue).cornerRadius(20)
                            .onTapGesture {
                                self.isPresentingLoginWithCode = true
                            }.sheet(isPresented: $isPresentingLoginWithCode){
                                loginWithCode(goToMainPage: $goToMainPage, scanError: $scanError)
                            }
                    }.padding()
                }.frame(width: screen_width, height: screen_height)
                    .background(AppColors.bgBlue)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            let userDefault = UserDefaults.standard
                if(userDefault.string(forKey: "token") != nil)
                {
                    self.goToMainPage = true
                    
                }
        }
        
    }
}
struct loginWithCode: View {
    @Binding var goToMainPage: Bool
    @State var code: String = ""
    @Binding var scanError: String
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    HStack(alignment: .center){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.blue)
                        .background(
                            Circle().fill(AppColors.buttonLightBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            dismiss()
                        }.frame(width: screen_width*0.1)
                        Spacer()
                    }.frame(width: screen_width).background(AppColors.bgBlue)
                    Spacer()
                    TextField("", text: $code, prompt: Text("Lütfen kodunuzu buraya giriniz.").foregroundColor(.gray), axis: .vertical)
                        .tint(.black)
                        .frame(width: screen_width*0.65).padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(AppColors.buttonLightBlue, lineWidth: 2)
                        ).padding()
                    Text("GİRİŞ")
                        .frame(width: screen_width*0.2, height: screen_height*0.05)
                        .background(AppColors.buttonLightBlue)
                        .cornerRadius(15)
                        .onTapGesture {
                            login()
                        }
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }
    }
    func login(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/auth/login/participant") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "username" : self.code,
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
                    dismiss()
                    return
                }
                self.goToMainPage = true
                userDefault.set(token, forKey: "token")
                userDefault.synchronize()
                dismiss()
            } catch {
                print(error)
            }
        }.resume()
    }
}
