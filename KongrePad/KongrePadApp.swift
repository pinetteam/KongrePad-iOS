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
    
    let persistenceController = PersistenceController.shared
    
    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(pusherManager)
                .sheet(isPresented: $pusherManager.isKeypadPresented){
                    KeypadView(hallId: $pusherManager.keypadHallId)
                }
                .sheet(isPresented: $pusherManager.isDebatePresented){
                    DebateView(hallId: $pusherManager.debateHallId)
                }
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
        myChannel.bind(eventName: "keypad", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                do{
                    let keypad = try JSONDecoder().decode(KeypadPusherJSON.self, from: Data(data.utf8))
                    self.keypadHallId = keypad.hall_id!
                    self.isKeypadPresented = !self.isKeypadPresented
                }
                catch {
                    print(error)
                }
            }
        })
        myChannel.bind(eventName: "debate", eventCallback: { (event: PusherEvent) -> Void in
            if let data: String = event.data {
                do{
                    let keypad = try JSONDecoder().decode(KeypadPusherJSON.self, from: Data(data.utf8))
                    self.debateHallId = keypad.hall_id!
                    self.isDebatePresented = !self.isDebatePresented
                }
                catch {
                    print(error)
                }
            }
        })
    }
}
