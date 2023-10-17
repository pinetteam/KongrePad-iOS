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
    @EnvironmentObject var alertManager: AlertManager
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
    @GestureState var standLongPress = false
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
                        Text(self.meeting?.title ?? "").font(.largeTitle).frame(width: screen_width, height:screen_height*0.15).foregroundColor(.white)
                    }
                    ZStack(alignment: .center){
                        Ellipse()
                            .fill(AppColors.bgLightBlue)
                            .frame(width: screen_width*1.5, height: screen_height*0.2)
                            .offset(y: -screen_height*0.1)
                            .clipped()
                            .offset(y: screen_height*0.05)
                            .frame(width: screen_width, height: screen_height*0.1)
                            .shadow(radius: 6)
                        VStack{
                            Text("\(participant?.full_name ?? "")")
                                .foregroundColor(.white)
                                .font(.title)
                        }
                    }
                    Spacer()
                    if self.virtualStands?.count != 0 {
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
                                                AsyncImage(url: URL(string: stand.on_hover ?? false ? "https://app.kongrepad.com/storage/virtual-stands/\(String(describing: stand.file_name!)).\(String(describing: stand.file_extension!))" : "https://app.kongrepad.com/storage/virtual-stands/\(String(describing: stand.file_name!))_grayscale.\(String(describing: stand.file_extension!))" )){ image in
                                                    image
                                                        .resizable()
                                                        .aspectRatio(contentMode: .fit)
                                                        .frame(width: 100, height:50)
                                                        .onTapGesture{
                                                            self.selectedVirtualStandId = stand.id!
                                                            self.goToVirtualStand = true
                                                        }
                                                        .onLongPressGesture(minimumDuration: 20, maximumDistance: 100, pressing: { pressing in
                                                            if let index = virtualStands!.firstIndex(where: { $0.id == stand.id }) {
                                                                virtualStands![index].on_hover = pressing
                                                            }
                                                        }, perform: {})
                                                    
                                                } placeholder: {
                                                    ProgressView()
                                                }
                                                .scaledToFill()
                                            }
                                        }
                                    }.buttonStyle(EmptyButtonStyle())
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
                    }
                    Spacer()
                    VStack(alignment: .center){
                        HStack{
                            NavigationLink(destination: SessionView(hallId: $hallId), isActive: $goToSession){
                                VStack(alignment: .center){
                                    Image(systemName: "play.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Sunum İzle").font(.title2).foregroundColor(.white)
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
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Soru Sor").font(.title2).foregroundColor(.white)
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
                                    Image(systemName: "book.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Bilimsel Program").font(.title2).foregroundColor(.white)
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
                                    Image(systemName: "envelope.open.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Mail Gönder").font(.title2).foregroundColor(.white)
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
                                    Image(systemName: "checklist.checked")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Anketler").font(.title2).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonDarkBlue).cornerRadius(10)
                            }
                            NavigationLink(destination: ScoreGameView())
                            {
                                VStack(alignment: .center){
                                    Image(systemName: "leaf.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(height: screen_width*0.1)
                                        .foregroundColor(.white)
                                    Text("Doğaya Can Ver").font(.title2).foregroundColor(.white)
                                }.frame(width: screen_width*0.42, height: screen_height*0.15).background(AppColors.buttonGreen).cornerRadius(10)
                            }
                        }
                    }
                    Spacer()
                    HStack(alignment: .center, spacing: 0){
                        NavigationLink(destination: LoginView(), isActive: $logOut){
                            Image(systemName: "power")
                                .foregroundColor(Color.white)
                                .font(.system(size: 25, weight: .heavy))
                                .onTapGesture {
                                    let userDefault = UserDefaults.standard
                                    userDefault.set(nil, forKey: "token")
                                    userDefault.synchronize()
                                    pusherManager.setChannel("ios")
                                    alertManager.present(title: "Başarılı", text: "Başarıyla çıkış yaptınız!")
                                    self.logOut = true
                                }
                        }
                        Spacer()
                        HStack{
                            NavigationLink(destination: AnnouncementsView()){
                                Image(systemName: "bell")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25, weight: .heavy))
                            }
                            NavigationLink(destination: ProfileView()){
                                Image(systemName: "person")
                                    .foregroundColor(Color.white)
                                    .font(.system(size: 25, weight: .heavy))
                            }
                        }
                    }.padding(.top, 5)
                        .overlay(Rectangle()
                            .frame(width: nil, height: 1, alignment: .top).foregroundColor(Color.gray), alignment: .top)
                        .frame(width: screen_width*0.85)
                        .padding()
                        .shadow(radius: 6)
                }.navigationBarBackButtonHidden(true)
                    .overlay(
                        LoadingView(viewModel: loadingViewModel)
                    )
            }
            .ignoresSafeArea(.all, edges: .bottom)
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
                let userDefault = UserDefaults.standard
                userDefault.set(nil, forKey: "token")
                userDefault.synchronize()
                pusherManager.setChannel("ios")
                self.logOut = true
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
                    Text("Salon Seçiniz")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.bgBlue)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_session == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue).font(.title2)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(10)
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
                    Text("Salon Seçiniz")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.bgBlue)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_send_mail == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue).font(.title2)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(10)
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
                    Text("Salon Seçiniz")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.bgBlue)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_view_program == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue).font(.title2)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(10)
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
                    Text("Salon Seçiniz")
                        .foregroundColor(Color.white).font(.title)
                        .frame(width: screen_width*0.7, height: screen_height*0.1)
                        .multilineTextAlignment(.center)
                }.padding()
                    .frame(width: screen_width).background(AppColors.bgBlue)
                    .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    ScrollView(.vertical){
                        VStack{
                            ForEach(self.halls ?? []){hall in
                                if hall.show_on_ask_question == 1{
                                    Text(hall.title!).foregroundColor(AppColors.bgBlue).font(.title2)
                                        .frame(width: screen_width*0.9, height: screen_height*0.1)
                                        .background(AppColors.programTitleBlue).cornerRadius(10)
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

