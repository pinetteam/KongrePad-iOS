//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI

struct AnnouncementsView: View{
    @Environment(\.presentationMode) var pm
    @State var announcements: [Announcement]?
    
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
                            .foregroundColor(AppColors.notificationsRed)
                            .background(
                                Circle().fill(.white)
                            )
                            .onTapGesture {
                                pm.wrappedValue.dismiss()
                            }.frame(width: screen_width*0.1)
                        Spacer()
                    }
                    Text("Duyurular")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.notificationsRed)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    VStack(alignment: .leading){
                        ScrollView(.vertical){
                            VStack(alignment:.leading, spacing: 10){
                                ForEach(self.announcements ?? []){announcement in
                                    HStack{
                                        Label(announcement.title!, systemImage: "bell.fill")
                                            .foregroundColor(.black)
                                            .frame(width: screen_width*0.8, alignment: .leading)
                                            .multilineTextAlignment(.leading)
                                    }
                                    Divider().overlay(.black)
                                }
                            }.padding()
                        }.frame(width: screen_width, height: screen_height*0.7)
                            .frame(maxHeight: .infinity)
                            .background(Color.gray)
                    }
                    Spacer()
                    ZStack{
                        Rectangle().frame(width: screen_width, height: screen_height*0.1).foregroundColor(AppColors.notificationsRed)
                        HStack{
                            Image(systemName: "bell.badge.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(height: screen_width*0.05)
                                .foregroundColor(.black)
                            Text("Tüm Duyuruları okudum")
                                .foregroundColor(.black)
                        }
                        .padding().background(.gray)
                        .cornerRadius(10)
                        .onTapGesture {
                            //
                        }
                    }
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .top).shadow(radius: 6)
                }.background(Color.gray)
                }.navigationBarBackButtonHidden(true)
        }
        .onAppear{
            getAnnouncements()
        }
    }
    func getAnnouncements(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/announcement") else {
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
                let announcements = try JSONDecoder().decode(AnnouncementsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.announcements = announcements.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
