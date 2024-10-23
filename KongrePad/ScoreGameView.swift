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
    @State var isPresentingPoints = false
    @EnvironmentObject var alertManager: AlertManager
    @State var scanError : String = ""
    @State var total_point : Int = 0
    @State var scoreGame: ScoreGame?
    @State var is_scanned: Bool = false
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
                            self.is_scanned = false
                            self.scanError = response.errors![0]
                            return
                        }
                        self.scanError = "Tebrikler!"
                        self.is_scanned = true
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
            if self.scanError != ""{
                let error = self.scanError
                self.scanError = ""
                alertManager.present(title: self.is_scanned ? "Başarılı" : "Hata", text: error)
            }
        }
    }
    
    var body: some View {
        
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                        HStack(alignment: .center){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.bgBlue)
                                .background(
                                    Circle().fill(.white)
                                )
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }.frame(width: screen_width*0.1)
                            Spacer()
                        }
                        Text("QR Okut")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width*0.7, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding().frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom)
                    ZStack {
                        
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screen_width * 0.6, height: screen_width * 0.6)
                            .foregroundColor(AppColors.sendButtonGreen)
                        
                        Image(systemName: "qrcode")
                            .resizable()
                            .scaledToFit()
                            .frame(width: screen_width * 0.6, height: screen_width * 0.6)
                            .foregroundColor(Color.gray)
                            .mask(
                                Rectangle()
                                    .padding(.bottom, screen_width * 0.006 * CGFloat(total_point * 100 / (scoreGame?.total_point ?? 1)))
                            )
                    }

                    Text("\(total_point) puan")
                        .font(.largeTitle).bold()
                        .foregroundColor(AppColors.sendButtonGreen)
                    Spacer()
                    Button(action: {
                        self.isPresentingPoints = true
                    }){
                        Label("Puan Geçmişim", systemImage: "list.number")
                            .padding()
                            .foregroundColor(Color.white)
                            .background(AppColors.sendButtonGreen).cornerRadius(10)
                    }.sheet(isPresented: $isPresentingPoints) {
                        ScoreGamePointsView(scoreGamePoints: $scoreGamePoints)
                    }
                    
                    Spacer()
                    ZStack{
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                        Button(action: {
                            self.isPresentingScanner = true
                        }){
                            Label("Kare Kodu Okut", systemImage: "camera")
                                .padding()
                                .foregroundColor(Color.white)
                                .background(AppColors.sendButtonGreen).cornerRadius(10)
                        }.sheet(isPresented: $isPresentingScanner) {
                            self.scannerSheet
                        }
                    }.overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .top)
                    }
                }.background(AppColors.bgBlue)
            }
        .ignoresSafeArea(.all, edges: .bottom)
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

struct ScoreGamePointsView: View {
    @Binding var scoreGamePoints: [ScoreGamePoint]?
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                    HStack(alignment: .center){
                        Image(systemName: "chevron.left")
                            .font(.system(size: 20)).bold().padding(8)
                            .foregroundColor(AppColors.bgBlue)
                            .background(
                                Circle().fill(.white)
                            )
                            .onTapGesture {
                                dismiss()
                            }.frame(width: screen_width*0.1)
                        Spacer()
                    }
                    Text("Puan Geçmişim")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.bgBlue)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    VStack(spacing: 0){
                        ScrollView(.vertical){
                            if self.scoreGamePoints?.count == 0 {
                                Text("Şu an hiç puanınız yok")
                                    .foregroundColor(Color.gray).font(.footnote)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            VStack(spacing: 10){
                                ForEach(self.scoreGamePoints ?? []){point in
                                    HStack{
                                        Text(String(describing: point.point!))
                                            .foregroundColor(.white).bold()
                                            .frame(width: screen_width*0.15)
                                            .frame(maxHeight: .infinity)
                                            .background(AppColors.sendButtonGreen)
                                            .cornerRadius(10)
                                        VStack{
                                            Text(point.title!)
                                                .foregroundColor(.white)
                                            Text(point.created_at!)
                                                .font(.footnote)
                                                .foregroundColor(.white)
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.75)
                                        .background(.gray)
                                        .cornerRadius(10)
                                    }
                                    
                                }
                            }
                        }.frame(width: screen_width*0.9, height: screen_height*0.8)
                    }.padding([.trailing, .leading])
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }
    }
}
