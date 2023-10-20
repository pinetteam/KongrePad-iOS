//
//  KongrePadApp.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift
import PushNotifications

class PusherManager: ObservableObject {
    static let shared = PusherManager()
    @Published var isDebatePresented = false
    @Published var debateHallId = 0
    @Published var isKeypadPresented = false
    @Published var keypadHallId = 0
    @Published var pusher: Pusher!
    @Published var channelName: String = "default-channel"
    @Published var participant: Participant?
    let pushNotifications = PushNotifications.shared

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
        if channel == "ios" {
            try! self.pushNotifications.clearDeviceInterests()
        }
        if self.participant?.type == "atendee" {
            try! self.pushNotifications.addDeviceInterest(interest: channelName)
        }
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

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
    let pushNotifications = PushNotifications.shared
    @ObservedObject var pusherManager = PusherManager.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        self.pushNotifications.start(instanceId: "8dedc4bd-d0d1-4d83-825f-071ab329a328") // Can be found here: https://dash.pusher.com
        self.pushNotifications.registerForRemoteNotifications()
        try! self.pushNotifications.addDeviceInterest(interest: "debug-kongrepad")

        return true
    }

    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        self.pushNotifications.registerDeviceToken(deviceToken)
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any], fetchCompletionHandler completionHandler: @escaping (UIBackgroundFetchResult) -> Void) {
        self.pushNotifications.handleNotification(userInfo: userInfo)
        var userData :PusherBeamsJSON?
        do {
            let data = try JSONSerialization.data(withJSONObject: userInfo["data"], options: [])
            userData = try JSONDecoder().decode(PusherBeamsJSON.self, from: data)
        } catch {
            print(error)
        }
        // notification geldi
        if (userData?.event == "debate") {
            pusherManager.debateHallId = userData?.hall_id ?? 0
            pusherManager.isDebatePresented = true
        } else if userData?.event == "keypad" {
            pusherManager.keypadHallId = userData?.hall_id ?? 0
            pusherManager.isKeypadPresented = true
        }
    }

    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Remote notification support is unavailable due to error: \(error.localizedDescription)")
    }
    
    
    
    class PusherBeamsJSON : Codable, Identifiable{
        
        var hall_id: Int?
        var event: String?
    }
}


@main
struct KongrePadApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
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
                }.alert(isPresented: $alertManager.isPresented){
                    Alert(title: Text(alertManager.title), message: Text(alertManager.text), dismissButton: .default(Text("Tamam")))
                }
                
        }
    }
}

class AlertManager: ObservableObject{
    static let shared = AlertManager()
    @Published var isPresented = false
    @Published var text = ""
    @Published var title = ""
    
    func present(title: String, text: String){
        DispatchQueue.main.async {
            self.isPresented = true
            self.text = text
            self.title = title
        }
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
