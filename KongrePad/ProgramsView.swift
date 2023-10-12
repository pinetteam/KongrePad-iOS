//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import PusherSwift

struct ProgramsView: View{
    @Environment(\.presentationMode) var pm
    @State var programDay: ProgramDay?
    
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(Color.black)
                        .background(
                            Circle().fill(Color.white)
                        )
                        .onTapGesture {
                            pm.wrappedValue.dismiss()
                        }
                        .padding(5)
                        Spacer()
                        Text("")
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                    }
                    .padding()
                    .frame(width: screen_width, height: screen_height*0.1)
                    Spacer().frame(height: 5)
                    VStack(alignment: .center){
                        Text("Bilimsel Program")
                            .bold()
                            .padding()
                            .foregroundColor(AppColors.bgBlue)
                            .frame(width: screen_width*0.85)
                            .background(AppColors.buttonYellow)
                            .overlay (
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black)
                            )
                            .cornerRadius(8)
                        Spacer().frame(height: 5)
                        Text("\(programDay?.day ?? "")")
                            .foregroundColor(AppColors.bgBlue)
                            .padding()
                            .frame(width: screen_width*0.85)
                            .background(AppColors.programDateYellow)
                            .overlay (
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(.black)
                            )
                            .cornerRadius(8)
                        ScrollView(.vertical){
                            VStack(spacing: 10){
                                ForEach(self.programDay?.programs ?? []){program in
                                    HStack{
                                        VStack(alignment: .center, spacing: 0){
                                            Text(program.start_at!)
                                                .foregroundColor(Color.black)
                                                .bold()
                                            RoundedRectangle(cornerRadius: 5)
                                                .frame(maxHeight: .infinity)
                                                .frame(width: screen_width*0.004)
                                                .foregroundColor(Color.black)
                                            Text(program.finish_at!)
                                                .foregroundColor(Color.black)
                                                .bold()
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.20)
                                        .background(AppColors.programDateYellow)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(8)
                                        VStack(alignment: .leading){
                                            Text(program.title!)
                                                .font(.system(size: 15))
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .padding()
                                            ForEach(program.debates ?? []){debate in
                                                Text("- \(debate.title ?? "")")
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding([.bottom, .trailing, .leading])
                                            }
                                            if program.chairs != nil{
                                                VStack{
                                                    Text("Oturum Başkanları:")
                                                        .foregroundColor(Color.gray)
                                                        .font(.system(size: 12))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                    ForEach(program.chairs ?? []){chair in
                                                        Text("\(chair.full_name ?? "")")
                                                            .foregroundColor(Color.gray)
                                                            .font(.system(size: 12))
                                                            .frame(maxWidth: .infinity, alignment: .leading)
                                                    }
                                                }
                                                .padding([.bottom, .trailing, .leading])
                                            }
                                        }
                                        .frame(maxHeight: .infinity)
                                        .frame(width: screen_width*0.65)
                                        .background(AppColors.programTitleBlue)
                                        .overlay (
                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(.black)
                                        )
                                        .cornerRadius(8)
                                    }
                                    ForEach(program.sessions ?? []){session in
                                        HStack{
                                            VStack(alignment: .center, spacing: 0){
                                                Text(session.start_at!)
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                                RoundedRectangle(cornerRadius: 5)
                                                    .frame(maxHeight: .infinity)
                                                    .frame(width: screen_width*0.004)
                                                    .foregroundColor(Color.black)
                                                Text(session.finish_at!)
                                                    .foregroundColor(Color.black)
                                                    .bold()
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.20)
                                            .background(AppColors.programDateYellow)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(8)
                                            VStack(alignment: .leading){
                                                Text(session.title!)
                                                    .font(.system(size: 15))
                                                    .frame(maxWidth: .infinity, alignment: .leading)
                                                    .padding()
                                                if session.speaker_name != nil{
                                                    Text("Konuşmacı: \(session.speaker_name!)")
                                                        .foregroundColor(Color.gray)
                                                        .font(.system(size: 12))
                                                        .frame(maxWidth: .infinity, alignment: .leading)
                                                        .padding([.bottom, .trailing, .leading])
                                                }
                                            }
                                            .frame(maxHeight: .infinity)
                                            .frame(width: screen_width*0.61)
                                            .background(AppColors.programTitleBlue)
                                            .overlay (
                                                RoundedRectangle(cornerRadius: 8)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(8)
                                        }
                                        .padding([.leading])
                                        
                                    }
                                       
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.8)
                    }
                }.navigationBarBackButtonHidden(true)
                }
            .background(AppColors.bgLightYellow)
        }
    }
}
