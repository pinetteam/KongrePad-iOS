//
//  KongrePadApp.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

@main
struct KongrePadApp: App {
    @StateObject var pusherManager = PusherManager.shared
    @StateObject var alertManager = AlertManager.shared
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(pusherManager)
                .environmentObject(alertManager)
                .sheet(isPresented: $pusherManager.isKeypadPresented){
                    KeypadView(hallId: $pusherManager.keypadHallId)
                        .environmentObject(alertManager)
                }
                .sheet(isPresented: $pusherManager.isDebatePresented){
                    DebateView(hallId: $pusherManager.debateHallId)
                        .environmentObject(alertManager)
                }.alert(alertManager.text, isPresented: $alertManager.isPresented){
                    Button("OK", role: .cancel){}
                }
                
        }
    }
}

class AlertManager: ObservableObject{
    static let shared = AlertManager()
    @Published var isPresented = false
    @Published var text = ""
    
    func present(text: String){
        DispatchQueue.main.async {
            self.isPresented = true
            self.text = text
        }
    }
}

class PusherManager: ObservableObject {
    static let shared = PusherManager()
    @Published var isDebatePresented = false
    @Published var debateHallId = 0
    @Published var isKeypadPresented = false
    @Published var keypadHallId = 0
    @Published var pusher: Pusher!
    @Published var channelName: String = "default-channel"
    @Published var participant: Participant?

    private init() {
        pusher = Pusher(
            key: "314fc649c9f65b8d7960",
            options: PusherClientOptions(
                host: .cluster("eu")
            )
        )
        pusher.connect()
    }

    func setChannel(_ channel: String) {
        pusher.unsubscribe(channelName)
        channelName = channel
        let myChannel = pusher.subscribe(channelName)
        getParticipant()
        myChannel.bind(eventName: "keypad", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data{
                do{
                    if self.participant?.type == "attendee" {
                        let pusherJson = try JSONDecoder().decode(PusherJSON.self, from: Data(data.utf8))
                        self.keypadHallId = pusherJson.hall_id!
                        self.isKeypadPresented = pusherJson.on_vote!
                    }
                }
                catch {
                    print(error)
                }
            }
        })
        myChannel.bind(eventName: "debate", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                do{
                    if self.participant?.type == "attendee" {
                        let pusherJson = try JSONDecoder().decode(PusherJSON.self, from: Data(data.utf8))
                        self.debateHallId = pusherJson.hall_id!
                        self.isDebatePresented = pusherJson.on_vote!
                    }
                }
                catch {
                    print(error)
                }
            }
        })
    }
    
    
    func getParticipant(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/participant") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token") ?? "")", forHTTPHeaderField: "Authorization")
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
    
    class PusherJSON : Codable, Identifiable{
        
        var hall_id: Int?
        var on_vote: Bool?
    }

}

class LoadingViewModel: ObservableObject {
    @Published var isLoading = false
    
    func startLoading() {
        isLoading = true
    }
    
    func stopLoading() {
        isLoading = false
    }
}

struct LoadingView: View {
    @ObservedObject var viewModel: LoadingViewModel
    
    var body: some View {
        if viewModel.isLoading {
            ZStack {
                Color.black.opacity(0.4)
                    .edgesIgnoringSafeArea(.all)
                
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                    .scaleEffect(2.0, anchor: .center)
                    .foregroundColor(Color.white)
            }
            .transition(.opacity)
        }
    }
}
