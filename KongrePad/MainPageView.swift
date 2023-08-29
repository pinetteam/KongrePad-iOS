//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct MainPageView: View{
    @Environment(\.presentationMode) var pm
    @State var goToSession = false
    @State var meeting: Meeting?
    @State var virtualStands: [VirtualStand]?
    @State var announcements: [Announcement]?
    @State var bannerName : String = ""
    @State var pdfURL: URL = URL(string: "https://africau.edu/images/default/sample.pdf")!
    
    
    var participant: Participant?
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                ZStack{
                    Image("giris")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center){
                        AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/meeting-banners/\(self.bannerName)")){ image in
                            image
                                .resizable()
                                .frame(width: screen_width*0.9, height:screen_height*0.2)
                        } placeholder: {
                            ProgressView()
                        }
                        ZStack{
                            VStack(alignment: .center, spacing: 0){
                                HStack(alignment: .bottom, spacing: 0){
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: screen_width*0.25, height: screen_height*0.05)
                                            .foregroundColor(Color.purple)
                                            .padding(.bottom, -10)
                                        Text("Sponsorlar")
                                            .foregroundColor(Color.black)
                                    }.zIndex(1)
                                    RoundedRectangle(cornerRadius: 5)
                                            .frame(width: screen_width*0.655, height: screen_height*0.02)
                                            .foregroundColor(Color.purple).padding(.bottom, -10)
                                            .padding(.leading, -3)
                                }
                            Rectangle()
                                .frame(width: screen_width*0.9, height: screen_height*0.1)
                                .foregroundColor(Color.white)
                        }
                        ScrollView(.horizontal){
                            HStack(spacing: 10){
                                ForEach(self.virtualStands ?? []){stand in
                                    HStack{
                                        AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/virtual-stands/\(String(describing: stand.file_name!)).\(String(describing: stand.file_extension!))")){ image in
                                            image
                                                .resizable()
                                                .aspectRatio(contentMode: .fit)
                                                .frame(width: 100, height:50)
                                        } placeholder: {
                                            ProgressView()
                                        }
                                            
                                            .scaledToFill()
                                    }.frame(width: 100, height: 50)
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.1)
                        .padding(.top, 23).padding(.leading, 20)
                        }
                        .shadow(radius: 6)
                        ZStack{
                            VStack(alignment: .center, spacing: 0){
                                HStack(alignment: .bottom , spacing: 0){
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: screen_width*0.3, height: screen_height*0.05)
                                            .foregroundColor(Color.purple)
                                            .padding(.bottom, -10)
                                        Label("Duyurular", systemImage: "speaker")
                                    }.zIndex(1)
                                    RoundedRectangle(cornerRadius: 5)
                                            .frame(width: screen_width*0.604, height: screen_height*0.02)
                                            .foregroundColor(Color.purple)
                                            .padding(.bottom, -10).padding(.leading, -3)
                                }
                                ZStack{
                                Rectangle()
                                        .frame(width: screen_width*0.9, height: screen_height*0.2)
                                        .foregroundColor(Color.white)
                                ScrollView(){
                                    VStack(alignment: .leading, spacing: 20){
                                        ForEach(self.announcements ?? []){announcement in
                                            Text(announcement.title ?? "")
                                        }
                                    }.padding(3)
                                }.frame(width: screen_width*0.9, height: screen_height*0.2, alignment: .leading)
                                }
                            }
                        }.shadow(radius: 6)
                        
                        NavigationLink(destination: SessionView(pdfURL: self.pdfURL), isActive: $goToSession){
                            HStack{
                                Label("",systemImage: "play.fill").font(.system(size:50)).labelStyle(.iconOnly).padding()
                                    .frame(width: screen_width*0.2, height: screen_height*0.2)
                                    .foregroundColor(Color.white)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .zIndex(1)
                                    .overlay(
                                        Circle()
                                            .stroke(.white, lineWidth: 5)
                                    )
                                ZStack{
                                    RoundedRectangle(cornerRadius: 50)
                                        .frame(width: screen_width*0.65, height: screen_height*0.12)
                                        .foregroundColor(Color.red)
                                    Text("JOIN SESSION").foregroundColor(Color.white).padding(.leading, 60).font(.system(size: 22, weight: .heavy))
                                }.padding(.leading, -80)
                            }.onTapGesture {
                                DispatchQueue.main.async {
                                    getDocument()
                                }
                                self.goToSession = true
                            }
                        }
                        HStack(spacing: 15){
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Program", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white))
                                    .cornerRadius(10)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.purple, lineWidth: 1)
                            )
                            .shadow(radius: 6)
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Surveys", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white))
                                    .cornerRadius(10)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.purple, lineWidth: 1)
                            )
                            .shadow(radius: 6)
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Score Games", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white))
                                    .cornerRadius(10)
                            }
                            .overlay(
                                RoundedRectangle(cornerRadius: 5)
                                    .stroke(.purple, lineWidth: 1)
                            )
                            .shadow(radius: 6)
                        }
                        Spacer()
                    }.padding().navigationBarBackButtonHidden(true).toolbar{
                        Button("Logout") {
                            let userDefault = UserDefaults.standard
                            userDefault.set(nil, forKey: "token")
                            userDefault.synchronize()
                            pm.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color.white)
                        .font(.system(size:20, weight: .heavy))
                    }
                }
                
            }
            
        }
        .onAppear{
            let options = PusherClientOptions(
              host: .cluster("eu"),
              useTLS: true
            )
            let pusher = Pusher(key: "1cf2459678ef9563476b", options: options)
            
            let channel = pusher.subscribe("screen-channel")
            
            let _ = channel.bind(eventName: "my-event", eventCallback: { (event: PusherEvent) -> Void in
                if let data: String = event.data {
                    print("aa")
                }
            })
            
            pusher.connect()
            getMeeting()
            getVirtualStands()
            getAnnouncements()
        }
    }
    
    
    struct MainPageView_Previews: PreviewProvider {
        static var previews: some View {
            MainPageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
    
    func getMeeting(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/meeting") else {
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
                let meeting = try JSONDecoder().decode(Meeting.self, from: data)
                DispatchQueue.main.async {
                    self.meeting = meeting
                }
                self.bannerName = "\(String(describing: meeting.banner_name!)).\(String(describing: meeting.banner_extension!))"
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getVirtualStands(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/virtual-stand") else {
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
                let stands = try JSONDecoder().decode([VirtualStand].self, from: data)
                DispatchQueue.main.async {
                    self.virtualStands = stands
                }
            } catch {
                print(error)
            }
        }.resume()
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
                let announcements = try JSONDecoder().decode([Announcement].self, from: data)
                DispatchQueue.main.async {
                    self.announcements = announcements
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getDocument(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/document") else {
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
                let document = try JSONDecoder().decode(DocumentJSON.self, from: data)
                DispatchQueue.main.async {
                    self.pdfURL = URL(string: "https://app.kongrepad.com/storage/documents/\(String(describing: document.data!.file_name!)).\(String(describing: document.data!.file_extension!))")!
                }
            } catch {
                print(error)
            }
        }.resume()
    }

}
