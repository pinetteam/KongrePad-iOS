//
//  DenemeView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 21.08.2023.
//

import SwiftUI
import CodeScanner

struct ScoreGameView: View {
    @Environment(\.presentationMode) var pm
    
    @State var isPresentingScanner = false
    @State var scanError : String = ""
    @State var total_point : Int = 0
    @State var scoreGame: ScoreGame?
    @State var scoreGamePoints: [ScoreGamePoint]?
    
    var scannerSheet : some View {
        CodeScannerView(codeTypes: [.qr], completion: {
            result in
            if case let .success(code) = result{
                guard let url = URL(string: "https://app.kongrepad.com/api/v1/score-game/0/point") else {
                    return
                }
                
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: AnyHashable] = [
                    "code" : code.string,
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
                        userDefault.set(token, forKey: "token")
                        userDefault.synchronize()
                        self.scanError = "qr Kod başarıyla okutuldu"
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
                VStack{
                    ZStack(alignment: .topLeading){
                        Text("Score Oyunu")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width, height: screen_height*0.1).padding()
                            .background(AppColors.bgBlue).multilineTextAlignment(.center)
                            Label("Geri", systemImage: "chevron.left")
                                .labelStyle(.titleAndIcon)
                                .font(.system(size: 20))
                                .foregroundColor(Color.blue)
                                .padding(5)
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }
                    }
                    Text("\(total_point ?? 0) Puan").background(Color.blue)
                        Spacer().frame(height: screen_height*0.1)
                    ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.scoreGamePoints ?? []){point in
                                    HStack{
                                        Text(point.created_at!)
                                            .foregroundColor(Color.black)
                                            .bold()
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programDateYellow)
                                                .cornerRadius(5)
                                        VStack(alignment: .leading){
                                            Text(point.title!)
                                                .font(.system(size: 20))
                                        }
                                        .frame(width: screen_width*0.65)
                                        .background(AppColors.programTitleBlue)
                                        .cornerRadius(5)
                                    }
                                    
                                }
                            }
                        }.frame(width: screen_width*0.7, height: screen_height*0.5)
                        Button(action: {
                            self.isPresentingScanner = true
                        }){
                            Label("Puan Okut", systemImage: "qrcode.viewfinder")
                                .labelStyle(.titleAndIcon)
                                .font(.system(size: 40, weight: .bold))
                                .frame(width: screen_width*0.5, height: 100)
                                .foregroundColor(Color.white)
                                .background(Color.red).cornerRadius(30)
                        }.sheet(isPresented: $isPresentingScanner) {
                            self.scannerSheet
                        }
                        Text(self.scanError).foregroundColor(Color.red).font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        Text("Giriş yap butonuna bastıktan sonra kameraya yaka kartıınızda bulunan Qr Kod'u okutunuz.").font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        
                    }.padding()
                }.background(AppColors.bgBlue)
            }
        .onAppear{}
        .navigationBarBackButtonHidden(true)
        }

    func getScoreGame(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/score-game") else {
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
                let score_game = try JSONDecoder().decode(ScoreGameJSON.self, from: data)
                DispatchQueue.main.async {
                    self.scoreGame = score_game.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    func getPoints(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/score-game/0/point") else {
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
                let points = try JSONDecoder().decode(ScoreGamePointsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.scoreGamePoints = points.data
                }
                self.total_point = 0
                ForEach(self.scoreGamePoints ?? []){point in
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
