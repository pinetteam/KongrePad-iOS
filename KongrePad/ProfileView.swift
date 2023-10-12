//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProfileView: View{
    @Environment(\.presentationMode) var pm
    @State var logOut = false
    @State var participant: Participant?
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.black)
                        .background(
                            Circle().fill(AppColors.buttonLightBlue)
                        )
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }
                        .padding(5)
                        Spacer()
                        Text("Hesabım")
                            .foregroundColor(.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                        Spacer()
                        VStack(spacing: 20){
                            Image("default_profile_photo")
                                .resizable()
                                .clipShape(Circle()).frame(width: screen_width*0.3, height: screen_width*0.3)
                            Label((self.participant?.full_name) ?? "", systemImage: "person")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.7)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                            Label((self.participant?.email) ?? "", systemImage: "envelope")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.7)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                            Label((self.participant?.phone) ?? "", systemImage: "phone")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.7)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                            Label((self.participant?.organisation) ?? "", systemImage: "house")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(width: screen_width*0.7)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                        }
                    Spacer()
                    ZStack(alignment: .topLeading){
                        Text("Bilgilerinizde eksik veya hatalı bilgi var ise lütfen kayıt masası ile irtibata geçiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.8, height: screen_height*0.1).padding()
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }
                    }.navigationBarBackButtonHidden(true)
                }
                .background(AppColors.bgBlue)
                
                
            }
            .onAppear{
                getParticipant()
            }
        }
        
        func getParticipant(){
            guard let url = URL(string: "https://app.kongrepad.com/api/v1/participant") else {
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
                    let participant = try JSONDecoder().decode(ParticipantJSON.self, from: data)
                    DispatchQueue.main.async {
                        self.participant = participant.data
                    }
                } catch {
                    print(error)
                }
            }.resume()
        }
        
    }
