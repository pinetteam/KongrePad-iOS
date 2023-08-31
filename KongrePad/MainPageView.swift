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
    @State var participant: Participant?
    @State var virtualStands: [VirtualStand]?
    @State var announcements: [Announcement]?
    @State var bannerName : String = ""
    @State var pdfURL: URL = URL(string: "https://africau.edu/images/default/sample.pdf")!
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                        AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/meeting-banners/\(self.bannerName)")){ image in
                            image
                                .resizable()
                                .frame(width: screen_width, height:screen_height*0.15)
                            
                        } placeholder: {
                            ProgressView()
                        }
                    ZStack(alignment: .top){
                        Ellipse()
                            .fill(.blue)
                            .frame(width: screen_width*1.5, height: screen_height*0.2)
                            .offset(y: -screen_height*0.1)
                            .clipped()
                            .offset(y: screen_height*0.05)
                            .frame(width: screen_width, height: screen_height*0.1)
                            .shadow(radius: 6)
                        VStack{
                            Text("\(participant?.full_name ?? "")")
                                .foregroundColor(.white)
                                .font(.system(size: 25)).bold()
                            Text("Hoş Geldiniz")
                                .foregroundColor(.white)
                                .font(.system(size: 25))
                        }
                    }
                    Spacer()
                            VStack(alignment: .center, spacing: 1){
                                    ZStack(alignment: .bottom){
                                        Text("Sanal Stant Alanı")
                                            .padding(5)
                                            .foregroundColor(Color.blue).bold()
                                            .background(Color.white).cornerRadius(5)
                                        Rectangle()
                                                .frame(width: screen_width*0.9, height: screen_height*0.002)
                                                .foregroundColor(Color.white).zIndex(-1)
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
                                
                            Rectangle()
                                    .frame(width: screen_width*0.9, height: screen_height*0.002)
                                    .foregroundColor(Color.white)
                        }
                        .shadow(radius: 6)
                    Spacer()
                    VStack(alignment: .center, spacing: 15){
                        HStack(spacing: 15){
                            NavigationLink(destination: SessionView(pdfURL: self.pdfURL), isActive: $goToSession)
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "play").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Sunum İzle").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonPurple).cornerRadius(10)
                            }.onTapGesture {
                                DispatchQueue.main.async {
                                    getDocument()
                                }
                                self.goToSession = true
                            }
                            NavigationLink(destination: DenemeView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "questionmark").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Soru Sor").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonPink).cornerRadius(10)
                            }
                        }
                        HStack(spacing: 15){
                            NavigationLink(destination: DenemeView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "doc.text").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Bilimsel Program").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonYellow).cornerRadius(10)
                            }
                            NavigationLink(destination: DenemeView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "envelope.badge").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Mail Gönder").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonLightBlue).cornerRadius(10)
                            }
                        }

                        HStack(spacing: 15){
                            NavigationLink(destination: DenemeView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "text.badge.checkmark").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Anketler").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonDarkBlue).cornerRadius(10)
                            }
                            NavigationLink(destination: DenemeView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "leaf.arrow.circlepath").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Doğaya Can Ver").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: 160, height: 120).background(AppColors.buttonGreen).cornerRadius(10)
                            }
                        }
                    }
                        Spacer()
                    HStack(alignment: .center){
                        Button(action:{
                            let userDefault = UserDefaults.standard
                            userDefault.set(nil, forKey: "token")
                            userDefault.synchronize()
                            pm.wrappedValue.dismiss()
                        }){
                            Label("", systemImage: "rectangle.portrait.and.arrow.right")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 20)).bold()
                                .foregroundColor(Color.white).padding()
                        }
                        .background(
                            Circle().foregroundColor(Color.red)
                        ).padding()
                        Spacer()
                    
                        Button(action:{
                        }){
                            Label("", systemImage: "person.fill")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 25)).bold()
                                .foregroundColor(Color.white).padding()
                        }
                    }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)

            
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
            getParticipant()
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
                let meeting = try JSONDecoder().decode(MeetingJSON.self, from: data)
                DispatchQueue.main.async {
                    self.meeting = meeting.data
                }
                self.bannerName = "\(String(describing: meeting.data!.banner_name!)).\(String(describing: meeting.data!.banner_extension!))"
            } catch {
                print(error)
            }
        }.resume()
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
                let stands = try JSONDecoder().decode(VirtualStandsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.virtualStands = stands.data
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
                let announcements = try JSONDecoder().decode(AnnouncementsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.announcements = announcements.data
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
