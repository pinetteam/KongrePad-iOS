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
    @EnvironmentObject var alertManager: AlertManager
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
                request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
                
                let body: [String: AnyHashable] = [
                    "code" : code.string,
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
                URLSession.shared.dataTask(with: request) {data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    do{
                        let response = try JSONDecoder().decode(ScoreGamePointsResponseJSON.self, from: data)
                        if (response.status != true){
                            self.isPresentingScanner = false
                            self.scanError = response.errors![0]
                            return
                        }
                        self.scanError = "qr Kod başarıyla okutuldu"
                        getPoints()
                    } catch {
                        print(error)
                    }
                }.resume()
                self.isPresentingScanner = false
            }
        }
        )
        .onDisappear{
            alertManager.present(text: self.scanError)
        }
    }
    
    var body: some View {
        
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(AppColors.bgBlue)
                        .background(
                            Circle().fill(AppColors.logoutButtonBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }
                        Spacer()
                        Text("Doğaya Can Ver")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    Spacer().frame(height: screen_height*0.05)
                    ZStack{
                        Image("dogaya_can_ver")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: screen_width*0.6, height: screen_width*0.6)
                            .foregroundColor(AppColors.sendButtonGreen)
                        Image("dogaya_can_ver")
                            .renderingMode(.template)
                            .resizable()
                            .frame(width: screen_width*0.6, height: screen_width*0.6)
                            .foregroundColor(Color.gray)
                            .mask(Rectangle().padding(.bottom, screen_width*0.006*CGFloat(total_point * 100 / (scoreGame?.total_point ?? 1))))
                    }
                    Text("\(total_point) Puan")
                        .font(.system(size: 40)).bold()
                        .foregroundColor(AppColors.sendButtonGreen)
                    Spacer().frame(height: screen_height*0.05)
                    Button(action: {
                        self.isPresentingScanner = true
                    }){
                        Label("Kare Kodu Okut", systemImage: "camera")
                            .font(.system(size: 25)).padding()
                            .frame(width: screen_width*0.7, height: screen_height*0.15)
                            .foregroundColor(Color.white)
                            .background(AppColors.sendButtonGreen).cornerRadius(10)
                    }.sheet(isPresented: $isPresentingScanner) {
                        self.scannerSheet
                    }
                    Text("Puanlarım")
                        .foregroundColor(Color.white)
                        .frame(width: screen_width*0.85, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                    ScrollView(.vertical){
                        if self.scoreGamePoints?.count == 0 {
                            Text("Şu an hiç puanınız yok")
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.85, height: screen_height*0.1)
                                .multilineTextAlignment(.center)
                            
                        }
                            VStack(spacing: 10){
                                ForEach(self.scoreGamePoints ?? []){point in
                                    HStack{
                                        Text(String(describing: point.point!))
                                            .font(.system(size: 20))
                                            .frame(width: screen_width*0.20)
                                            .frame(maxHeight: .infinity)
                                            .background(AppColors.programTitleBlue)
                                            .cornerRadius(5)
                                        Text(point.title!)
                                            .font(.system(size: 20))
                                            .frame(width: screen_width*0.40)
                                            .frame(maxHeight: .infinity)
                                            .background(AppColors.programDateYellow)
                                            .cornerRadius(5)
                                        Text(point.created_at!)
                                            .multilineTextAlignment(.center)
                                            .foregroundColor(Color.black)
                                            .bold()
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programTitleBlue)
                                            .cornerRadius(5)
                                    }
                                    
                                }
                            }
                        }.frame(width: screen_width*0.7, height: screen_height*0.5)
                        
                    }
                }.background(AppColors.bgBlue)
            
            }
        .onAppear{
            getPoints()
            getScoreGame()
        }
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
                points.data?.forEach{point in
                    total_point = total_point + point.point!
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
