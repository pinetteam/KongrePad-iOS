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
                        Text("Hesabım")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width*0.7, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding().frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer().frame(height: 20)
                        VStack(spacing: 20){
                            Image("default_profile_photo")
                                .resizable()
                                .clipShape(Circle()).frame(width: screen_width*0.3, height: screen_width*0.3)
                                .overlay(
                                    Circle()
                                        .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                )
                            Label((self.participant?.full_name) ?? "", systemImage: "person.fill")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                            Label((self.participant?.email) ?? "", systemImage: "envelope.open.fill")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                )
                            Label((self.participant?.phone) ?? "", systemImage: "phone.fill")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                            Label((self.participant?.organisation) ?? "", systemImage: "building.columns.fill")
                                .padding()
                                .foregroundColor(Color.white)
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .overlay(
                                        RoundedRectangle(cornerRadius: 10)
                                            .stroke(AppColors.logoutButtonBlue, lineWidth: 2)
                                    )
                        }.frame(width: screen_width*0.9)
                    Spacer()
                    
                    ZStack(alignment: .center){
                            Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.bgBlue)
                            Text("Bilgilerinizde eksik veya hatalı bilgi var ise lütfen kayıt masası ile irtibata geçiniz.")
                            .multilineTextAlignment(.center)
                            .font(.footnote)
                            .foregroundColor(Color.white).padding()
                        }
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .top).shadow(radius: 6)
                    }.navigationBarBackButtonHidden(true)
                }
                .background(AppColors.bgBlue)
                
                
            }
        .ignoresSafeArea(.all, edges: .bottom)
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
