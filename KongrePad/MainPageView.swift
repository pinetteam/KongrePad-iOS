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
    @State var isHallsForDocumentPresented = false
    @State var isHallsForProgramPresented = false
    @State var keypadPresent = false
    @State var debatePresent = false
    @State var hallId: Int = 0
    @State var logOut = false
    @State var goToSession = false
    @State var goToPrograms = false
    @State var meeting: Meeting?
    @State var keypad: Keypad?
    @State var debate: Debate?
    @State var participant: Participant?
    @State var virtualStands: [VirtualStand]?
    @State var announcements: [Announcement]?
    @State var bannerName : String = ""
    @State var pdfURL: URL?
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
                            Rectangle().frame(width: screen_width, height:screen_height*0.15)
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
                            Spacer().frame(height: 10)
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
                                            .foregroundColor(Color.blue).font(.system(size:20))
                                            .background(Color.white)
                                            .padding(.bottom, 5)
                                            .cornerRadius(5)
                                            .padding(.bottom, -5)
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
                                            }
                                        }
                                    }
                                }.frame(width: screen_width*0.85, height: screen_height*0.06)
                                
                            Rectangle()
                                    .frame(width: screen_width*0.9, height: screen_height*0.002)
                                    .foregroundColor(Color.white)
                        }
                        .shadow(radius: 6)
                    Spacer()
                    VStack(alignment: .center, spacing: 15){                        VStack(alignment: .center){
                        Image(systemName: "play.fill")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                        Text("Sunum İzle").font(.system(size: 20)).foregroundColor(.white)
                    }.frame(width: screen_width*0.76, height: screen_height*0.15).background(AppColors.buttonPurple).cornerRadius(10)
                            .onTapGesture {
                                self.isHallsForDocumentPresented = true
                            }.sheet(isPresented: $isHallsForDocumentPresented){
                                HallsForDocument(goToSession: $goToSession, pdfURL: $pdfURL, hallId: $hallId)
                            }.background(
                                NavigationLink(destination: SessionView(pdfURL: $pdfURL, hallId: $hallId), isActive: $goToSession){
                                    EmptyView()
                                })
                        HStack{
                            VStack(alignment: .center){
                                Text("Keypad Deneme").font(.system(size: 20)).foregroundColor(.white)
                            }.frame(width: screen_width*0.37, height: screen_height*0.05).background(AppColors.buttonPurple).cornerRadius(10)
                                .onTapGesture {
                                    getKeypad(HallId: 5)
                                    self.keypadPresent = true
                                }.sheet(isPresented: $keypadPresent){
                                    KeypadView(keypad: $keypad)
                                }
                            VStack(alignment: .center){
                                Text("Debate Deneme").font(.system(size: 20)).foregroundColor(.white)
                            }.frame(width: screen_width*0.37, height: screen_height*0.05).background(AppColors.buttonPurple).cornerRadius(10)
                                .onTapGesture {
                                    getDebate(HallId: 5)
                                    self.debatePresent = true
                                }.sheet(isPresented: $debatePresent){
                                    DebateView(debate: $debate)
                                }
                        }
                        HStack(spacing: 10){
                                VStack(alignment: .center){
                                    Label("", systemImage: "doc.text").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Bilimsel Program").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.37, height: screen_height*0.15).background(AppColors.buttonYellow).cornerRadius(10)
                                .onTapGesture {
                                    self.isHallsForProgramPresented = true
                                }.sheet(isPresented: $isHallsForProgramPresented){
                                    HallsForProgram(goToProgram: $goToPrograms, hallId: $hallId)
                                }.background(
                                    NavigationLink(destination: ProgramsView(hallId: $hallId), isActive: $goToPrograms){
                                    EmptyView()
                                })
                            NavigationLink(destination: SendMailView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "envelope.badge").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Mail Gönder").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.37, height: screen_height*0.15).background(AppColors.buttonLightBlue).cornerRadius(10)
                            }
                        }

                        HStack(spacing: 15){
                            NavigationLink(destination: SurveysView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "text.badge.checkmark").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Anketler").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.37, height: screen_height*0.15).background(AppColors.buttonDarkBlue).cornerRadius(10)
                            }
                            NavigationLink(destination: ScoreGameView())
                            {
                                VStack(alignment: .center){
                                    Label("", systemImage: "leaf.arrow.circlepath").font(.system(size: 40)).foregroundColor(.white)
                                    Text("Doğaya Can Ver").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.37, height: screen_height*0.15).background(AppColors.buttonGreen).cornerRadius(10)
                            }
                        }
                    }
                    Spacer()
                    HStack(alignment: .center){
                        NavigationLink(destination: LoginView(), isActive: $logOut){
                            Label("", systemImage: "rectangle.portrait.and.arrow.right")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 20, weight: .heavy))
                                .foregroundColor(Color.blue).padding()
                                .onTapGesture {
                                    let userDefault = UserDefaults.standard
                                    userDefault.set(nil, forKey: "token")
                                    userDefault.synchronize()
                                    self.logOut = true
                                }
                            }
                        Spacer()
                        HStack{
                        NavigationLink(destination: AnnouncementsView()){
                            Label("", systemImage: "bell.fill")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 25, weight: .heavy))
                                .foregroundColor(Color.white).padding()
                        }
                        NavigationLink(destination: ProfileView()){
                            Label("", systemImage: "person.fill")
                                .labelStyle(.iconOnly)
                                .font(.system(size: 25, weight: .heavy))
                                .foregroundColor(Color.white).padding()
                        }
                        }
                }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgBlue)

            
        }
        .onAppear{
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
    
    func getKeypad(HallId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(HallId)/active-keypad") else {
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
                let keypad = try JSONDecoder().decode(KeypadJSON.self, from: data)
                if keypad.status!{
                    DispatchQueue.main.async {
                        self.keypad = keypad.data
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getDebate(HallId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(HallId)/active-debate") else {
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
                let debate = try JSONDecoder().decode(DebateJSON.self, from: data)
                if debate.status!{
                    DispatchQueue.main.async {
                        self.debate = debate.data
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }

    
    

}

struct HallsForDocument: View {
    @State var halls: [Hall]?
    @Binding var goToSession: Bool
    @Binding var pdfURL: URL?
    @Binding var hallId: Int
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .leading){
                    HStack(alignment: .top){
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
                        Text("Lütfen sunumu görüntülemek istediğiniz salonu seçiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }.frame(width: screen_width).background(AppColors.bgBlue)
                    HStack{
                        Label("", systemImage: "chevron.left")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(AppColors.bgBlue).padding()
                        Spacer()
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(self.halls ?? []){hall in
                                        VStack(alignment: .center){
                                            ZStack(alignment: .bottom){
                                                Text(hall.title!).foregroundColor(Color.white)
                                                    .frame(width: screen_width*0.5, height: screen_width*0.5)
                                                    .background(AppColors.bgBlue)
                                                    .clipShape(Circle())
                                                Text("Kişi Sayısı")
                                                    .foregroundColor(Color.white)
                                                    .frame(width: screen_width*0.5, height: screen_height*0.05)
                                                    .background(AppColors.buttonGreen)
                                            }
                                        }.frame(width: screen_width*0.5)
                                            .onTapGesture {
                                                self.hallId = hall.id!
                                                getDocument(HallId: hall.id!)
                                                self.goToSession = true
                                                dismiss()
                                        }
                                    }
                                }
                        }.onAppear{
                            getHalls()
                        }.frame(width: screen_width*0.5)
                        Spacer()
                        Label("", systemImage: "chevron.right")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(AppColors.bgBlue).padding()
                    }
                }
            }
        }
    }
    func getHalls(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall") else {
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
                let halls = try JSONDecoder().decode(HallsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.halls = halls.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getDocument(HallId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(HallId)/active-document") else {
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
                if document.status!{
                    DispatchQueue.main.async {
                        self.pdfURL = URL(string: "https://app.kongrepad.com/storage/documents/\(String(describing: document.data!.file_name!)).\(String(describing: document.data!.file_extension!))")!
                    }
                } else {
                    pdfURL = nil
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}
struct HallsForProgram: View {
    @State var halls: [Hall]?
    @Binding var goToProgram: Bool
    @Binding var hallId: Int
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .leading){
                    HStack(alignment: .top){
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
                        Text("Lütfen bilimsel programı görüntülemek istediğiniz salonu seçiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }.frame(width: screen_width).background(AppColors.bgBlue)
                    HStack{
                        Label("", systemImage: "chevron.left")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(AppColors.bgBlue).padding()
                        Spacer()
                        ScrollView(.horizontal){
                            HStack{
                                ForEach(self.halls ?? []){hall in
                                        VStack(alignment: .center){
                                            ZStack(alignment: .bottom){
                                                Text(hall.title!).foregroundColor(Color.white)
                                                    .frame(width: screen_width*0.5, height: screen_width*0.5)
                                                    .background(AppColors.bgBlue)
                                                    .clipShape(Circle())
                                                Text("Kişi Sayısı")
                                                    .foregroundColor(Color.white)
                                                    .frame(width: screen_width*0.5, height: screen_height*0.05)
                                                    .background(AppColors.buttonGreen)
                                            }
                                        }.frame(width: screen_width*0.5)
                                            .onTapGesture {
                                                self.hallId = hall.id!
                                                self.goToProgram = true
                                                dismiss()
                                        }
                                    }
                                }
                        }.onAppear{
                            getHalls()
                        }.frame(width: screen_width*0.5)
                        Spacer()
                        Label("", systemImage: "chevron.right")
                            .labelStyle(.iconOnly)
                            .font(.system(size: 20, weight: .heavy))
                            .foregroundColor(AppColors.bgBlue).padding()
                    }
                }
            }
        }
    }
    func getHalls(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall") else {
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
                let halls = try JSONDecoder().decode(HallsJSON.self, from: data)
                DispatchQueue.main.async {
                    self.halls = halls.data
                }
            } catch {
                print(error)
            }
        }.resume()
    }

}

