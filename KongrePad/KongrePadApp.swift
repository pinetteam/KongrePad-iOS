//
//  KongrePadApp.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI

@main
struct KongrePadApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            LoginView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
