//
//  DenemeView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 21.08.2023.
//

import SwiftUI
struct DenemeView: View {
    
    var body: some View {
                HStack(alignment: .top){
                    Rectangle().fill(Color.red).frame(width: 100, height: 100).padding()
                    Rectangle().fill(Color.green).frame(width: 50, height: 50).padding()
                    Rectangle().fill(Color.blue).frame(width: 25, height: 25).padding()
                }
    }
    
    
    struct DenemeView_Previews: PreviewProvider {
    static var previews: some View {
            DenemeView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
