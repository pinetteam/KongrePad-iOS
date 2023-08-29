//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct DebateView: View{
    @Environment(\.presentationMode) var pm
    @State var meeting: Meeting?
    @State var debate: Debate?
    @State var debateTeams: [DebateTeam]?
    @State var selectedOption: Int = 1
    @State var virtualStands: [VirtualStand]?
    @State var bannerName : String = ""
    
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
                        Spacer()
                        Text(self.debate?.title ?? "")
                        ZStack{
                        Rectangle()
                                .frame(width: screen_width*0.9, height: screen_height*0.2)
                                .foregroundColor(Color.white)
                        ScrollView(){
                            VStack(alignment: .leading, spacing: 20){
                                ForEach(self.debateTeams ?? []){team in
                                    HStack{
                                        RadioButtonView(index: team.id!, text:team.title!, selectedIndex: $selectedOption)
                                    }
                                }
                            }.padding(3)
                        }.frame(width: screen_width*0.9, height: screen_height*0.2, alignment: .leading)
                        }
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
            getVirtualStands()
            getMeeting()
            getDebate()
        }
    }
    
    struct RadioButtonView: View {
        var index: Int
        var text: String
        @Binding var selectedIndex: Int
        var body: some View {
            Button(action: {
                selectedIndex = index
            }) {
                HStack {
                    Image(systemName: selectedIndex == index ? "largecircle.fill.circle" : "circle")
                        .foregroundColor(.black)
                    Text(text)
                }
            }
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
    
    func getDebate(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/debate") else {
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
                let debate = try JSONDecoder().decode(Debate.self, from: data)
                DispatchQueue.main.async {
                    self.debate = debate
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
                let stands = try JSONDecoder().decode([VirtualStand].self, from: data)
                DispatchQueue.main.async {
                    self.virtualStands = stands
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getDebateTeams(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/debate//team") else {
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
                let teams = try JSONDecoder().decode([DebateTeam].self, from: data)
                DispatchQueue.main.async {
                    self.debateTeams = teams
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
