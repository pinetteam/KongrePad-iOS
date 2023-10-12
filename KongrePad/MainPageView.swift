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
    @ObservedObject var loadingViewModel = LoadingViewModel()
    @EnvironmentObject var pusherManager: PusherManager
    @State var isHallsForDocumentPresented = false
    @State var isHallsForProgramPresented = false
    @State var isHallsForSendMailPresented = false
    @State var isHallsForAskQuestionPresented = false
    @State var selectedVirtualStandId: Int = 0
    @State var hallId: Int = 0
    @State var logOut = false
    @State var goToSession = false
    @State var goToPrograms = false
    @State var goToProgramsForMail = false
    @State var goToAskQuestion = false
    @State var goToVirtualStand = false
    @State var meeting: Meeting?
    @State var participant: Participant?
    @State var virtualStands: [VirtualStand]?
    @State var bannerName : String = ""
    @State var pdfURL: URL?
    @State var standPdfURL: URL?
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
                            .fill(AppColors.bgLightBlue)
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
                                .font(.system(size: 30)).bold().padding(.top, 10)
                        }
                    }
                    Spacer()
                    VStack(alignment: .center, spacing: 1){
                        Rectangle()
                            .frame(width: screen_width*0.9, height: screen_height*0.002)
                            .foregroundColor(Color.white)
                            HStack(alignment: .center, spacing: 10){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold()
                                .foregroundColor(Color.white)
                                ScrollView(.horizontal){
                                    NavigationLink(destination: VirtualStandView(pdfURL: $standPdfURL, virtualStandId: $selectedVirtualStandId), isActive: $goToVirtualStand)
                                    {
                                        HStack(alignment: .center, spacing: 10){
                                            ForEach(self.virtualStands ?? []){stand in
                                                AsyncImage(url: URL(string: "https://app.kongrepad.com/storage/virtual-stands/\(String(describing: stand.file_name!)).\(String(describing: stand.file_extension!))")){ image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 100, height:50)
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .scaledToFill()
                                                .onTapGesture{
                                                    self.selectedVirtualStandId = stand.id!
                                                    self.goToVirtualStand = true
                                                }
                                            }
                                        }
                                    }
                                }
                            Image(systemName: "chevron.right")
                                .font(.system(size: 20)).bold()
                                .foregroundColor(Color.white)
                            }.frame(width: screen_width*0.9, height: screen_height*0.06)
                        Rectangle()
                            .frame(width: screen_width*0.9, height: screen_height*0.002)
                            .foregroundColor(Color.white)
                    }
                    .shadow(radius: 6)
                    Spacer()
                    VStack(alignment: .center, spacing: 15){
                        HStack{
                            NavigationLink(destination: SessionView(hallId: $hallId), isActive: $goToSession){
                                VStack(alignment: .center){
                                    Image("play_button")
                                        .resizable()
                                        .frame(width: screen_width*0.1, height: screen_width*0.1)
                                    Text("Sunum İzle").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonPurple).cornerRadius(10)
                                    .onTapGesture {
                                        if self.meeting?.session_hall_count == 1 {
                                            self.goToSession = true
                                            self.hallId = (self.meeting?.session_first_hall_id)!
                                        } else {
                                            self.isHallsForDocumentPresented = true
                                        }
                                    }.sheet(isPresented: $isHallsForDocumentPresented){
                                        HallsForDocument(goToSession: $goToSession, pdfURL: $pdfURL, hallId: $hallId)
                                    }
                            }
                            NavigationLink(destination: AskQuestionView(hallId: $hallId), isActive: $goToAskQuestion){
                                VStack(alignment: .center){
                                    Image(systemName: "questionmark")
                                        .font(.system(size: 50)).bold()
                                        .foregroundColor(.white)
                                    Text("Soru Sor").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonRed).cornerRadius(10)
                                    .onTapGesture {
                                        if self.meeting?.question_hall_count == 1 {
                                            self.goToAskQuestion = true
                                            self.hallId = (self.meeting?.question_first_hall_id)!
                                        } else {
                                            self.isHallsForAskQuestionPresented = true
                                        }
                                    }.sheet(isPresented: $isHallsForAskQuestionPresented){
                                        HallsForAskQuestion(goToAskQuestion: $goToAskQuestion, hallId: $hallId)
                                    }
                            }
                        }
                        HStack(){
                            NavigationLink(destination: ProgramDaysView(hallId: $hallId), isActive: $goToPrograms){
                                VStack(alignment: .center){
                                    Image("program_button")
                                        .resizable()
                                        .frame(width: screen_width*0.1, height: screen_width*0.1)
                                    Text("Bilimsel Program").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonYellow).cornerRadius(10)
                                    .onTapGesture {
                                        if self.meeting?.program_hall_count == 1 {
                                            self.goToPrograms = true
                                            self.hallId = (self.meeting?.program_first_hall_id)!
                                        } else {
                                            self.isHallsForProgramPresented = true
                                        }
                                    }.sheet(isPresented: $isHallsForProgramPresented){
                                        HallsForProgram(goToProgram: $goToPrograms, hallId: $hallId)
                                    }
                            }
                            NavigationLink(destination: ProgramDaysForMailView(hallId: $hallId), isActive: $goToProgramsForMail){
                                VStack(alignment: .center){
                                    Image("send_mail_button")
                                        .resizable()
                                        .frame(width: screen_width*0.1, height: screen_width*0.1)
                                    Text("Mail Gönder").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15)
                                    .background(AppColors.buttonLightBlue).cornerRadius(10)
                                    .onTapGesture {
                                        if self.meeting?.mail_hall_count == 1 {
                                            self.goToProgramsForMail = true
                                            self.hallId = (self.meeting?.mail_first_hall_id)!
                                        } else {
                                            self.isHallsForSendMailPresented = true
                                        }
                                    }.sheet(isPresented: $isHallsForSendMailPresented){
                                        HallsForSendMail(goToProgramsForMail: $goToProgramsForMail, hallId: $hallId)
                                    }
                            }
                        }
                        
                        HStack(){
                            NavigationLink(destination: SurveysView())
                            {
                                VStack(alignment: .center){
                                    Image("surveys_button")
                                        .resizable()
                                        .frame(width: screen_width*0.1, height: screen_width*0.1)
                                    Text("Anketler").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonDarkBlue).cornerRadius(10)
                            }
                            NavigationLink(destination: ScoreGameView())
                            {
                                VStack(alignment: .center){
                                    Image("score_game_button")
                                        .resizable()
                                        .frame(width: screen_width*0.1, height: screen_width*0.1)
                                    Text("Doğaya Can Ver").font(.system(size: 20)).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonGreen).cornerRadius(10)
                            }
                        }
                    }
                    Spacer()
                    HStack(alignment: .center){
                        NavigationLink(destination: LoginView(), isActive: $logOut){
                            Image("logout_button")
                                .resizable()
                                .frame(width: screen_width*0.07, height: screen_width*0.08)
                                .padding()
                                .onTapGesture {
                                    let userDefault = UserDefaults.standard
                                    userDefault.set(nil, forKey: "token")
                                    userDefault.synchronize()
                                    pusherManager.setChannel("ios")
                                    self.logOut = true
                                }
                        }
                        Spacer()
                        HStack{
                            NavigationLink(destination: AnnouncementsView()){
                                Image(systemName: "bell.fill")
                                    .foregroundColor(Color.white).padding()
                                    .font(.system(size: 25, weight: .heavy))
                            }
                            NavigationLink(destination: ProfileView()){
                                Image(systemName: "person.fill")
                                    .foregroundColor(Color.white).padding()
                                    .font(.system(size: 25, weight: .heavy))
                            }
                        }
                    }.padding()
                }.navigationBarBackButtonHidden(true)
                    .overlay(
                        LoadingView(viewModel: loadingViewModel)
                    )
            }
            .background(AppColors.bgBlue)
            
            
        }
        .task{
            loadingViewModel.startLoading()
            await getData()
        }
    }
    
    func getData() async{
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
                    self.bannerName = "\(String(describing: meeting.data!.banner_name ?? "")).\(String(describing: meeting.data!.banner_extension ?? ""))"
                }
                pusherManager.setChannel("meeting-\(String(describing: meeting.data!.id!))")
            } catch {
                print(error)
            }
        }.resume()
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/participant") else {
            return
        }
        
        var request2 = URLRequest(url: url)
        
        request2.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request2.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request2) {data, _, error in
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
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/virtual-stand") else {
            return
        }
        
        var request3 = URLRequest(url: url)
        
        request3.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request3.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request3) {data, _, error in
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
            DispatchQueue.main.async {
                loadingViewModel.stopLoading()
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
                VStack(alignment: .center){
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
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_session == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(5)
                                        .onTapGesture {
                                            self.hallId = hall.id!
                                            getDocument(HallId: hall.id!)
                                            self.goToSession = true
                                            dismiss()
                                        }
                                }
                            }
                        }
                    }.onAppear{
                        getHalls()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
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

struct HallsForSendMail: View {
    @State var halls: [Hall]?
    @Binding var goToProgramsForMail: Bool
    @Binding var hallId: Int
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
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
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_send_mail == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(5)
                                        .onTapGesture {
                                            self.hallId = hall.id!
                                            self.goToProgramsForMail = true
                                            dismiss()
                                        }
                                }
                            }
                        }
                    }.onAppear{
                        getHalls()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
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
                VStack(alignment: .center){
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
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_view_program == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(5)
                                        .onTapGesture {
                                            self.hallId = hall.id!
                                            self.goToProgram = true
                                            dismiss()
                                        }
                                }
                            }
                        }
                    }.onAppear{
                        getHalls()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
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

struct HallsForAskQuestion: View {
    @State var halls: [Hall]?
    @Binding var goToAskQuestion: Bool
    @Binding var hallId: Int
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
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
                        Text("Lütfen soru sormak istediğiniz salonu seçiniz")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.bgBlue)
                            .multilineTextAlignment(.center)
                    }.frame(width: screen_width).background(AppColors.bgBlue)
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_ask_question == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(5)
                                        .onTapGesture {
                                            self.hallId = hall.id!
                                            self.goToAskQuestion = true
                                            dismiss()
                                        }
                                }
                            }
                        }
                    }.onAppear{
                        getHalls()
                    }
                    Spacer()
                }.background(AppColors.bgBlue)
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

