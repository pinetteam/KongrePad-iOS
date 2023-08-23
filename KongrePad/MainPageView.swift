//
//  ContentView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 16.08.2023.
//

import SwiftUI
import CoreData

struct MainPageView: View {
    @Environment(\.presentationMode) var pm
    var Meeting: Meeting?
    var body: some View {
        NavigationStack {
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                ZStack{
                    Image("giris").resizable().aspectRatio(contentMode: .fill).edgesIgnoringSafeArea(.all)
                    VStack(alignment: .center){
                        AsyncImage(url: URL(string: "")).frame(width: screen_width, height: screen_height*0.2)
                        ZStack{
                            VStack(alignment: .center, spacing: 0){
                                HStack(spacing: 0){
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: screen_width*0.25, height: screen_height*0.05)
                                            .foregroundColor(Color.purple).padding(.bottom, -10)
                                        Text("Sponsorlar").foregroundColor(Color.black)
                                    }
                                    RoundedRectangle(cornerRadius: 5)
                                            .frame(width: screen_width*0.66, height: screen_height*0.02)
                                            .foregroundColor(Color.purple).padding(.bottom, -25).padding(.leading, -3)
                                }
                            Rectangle()
                                    .frame(width: screen_width*0.9, height: screen_height*0.1)
                                .foregroundColor(Color.white)
                        }
                        ScrollView(.horizontal){
                            HStack(spacing: 10){
                                ForEach(0..<10){_ in
                                    VStack{
                                        AsyncImage(url: URL(string: "")).frame(width: 100, height: 50)
                                    }
                                    
                                }
                            }
                        }.frame(width: screen_width*0.85, height: screen_height*0.1).padding(.top, 23).padding(.leading, 20)
                        }.padding(.leading, -20)
                        .shadow(radius: 6)
                        ZStack{
                            VStack(alignment: .center, spacing: 0){
                                HStack(spacing: 0){
                                    ZStack{
                                        RoundedRectangle(cornerRadius: 10)
                                            .frame(width: screen_width*0.25, height: screen_height*0.05)
                                            .foregroundColor(Color.purple).padding(.bottom, -10)
                                        Label("Duyurular", systemImage: "speaker")
                                    }
                                    RoundedRectangle(cornerRadius: 5)
                                            .frame(width: screen_width*0.66, height: screen_height*0.02)
                                            .foregroundColor(Color.purple).padding(.bottom, -25).padding(.leading, -3)
                                }
                            Rectangle()
                                    .frame(width: screen_width*0.9, height: screen_height*0.2)
                                .foregroundColor(Color.white)
                        }
                            ScrollView(){
                                VStack(spacing: 20){
                                    Text("Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum ")
                                    Text("Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum Lorem ipsum ")
                                }
                            }.frame(width: screen_width*0.9, height: screen_height*0.2).padding(.top, 25)
                        }.padding(.leading, -20)
                        .shadow(radius: 6)
                        NavigationLink(destination: DenemeView())
                        {
                            HStack{
                                Label("",systemImage: "play.fill").font(.system(size:50)).labelStyle(.iconOnly).padding()
                                    .frame(width: screen_width*0.2, height: screen_height*0.2)
                                    .foregroundColor(Color.white)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .zIndex(1)
                                ZStack{
                                    RoundedRectangle(cornerRadius: 50)
                                        .frame(width: screen_width*0.7, height: screen_height*0.12)
                                        .foregroundColor(Color.red)
                                    Text("JOIN SESSION").foregroundColor(Color.white).padding(.leading, 70).font(.system(size: 22, weight: .heavy))
                                        Circle().foregroundColor(Color.white)
                                        .frame(height: screen_height*0.13)
                                        .padding(.leading, -150)
                                }.padding(.leading, -80)
                            }
                        }.padding()
                        HStack(spacing: 15){
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Program", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white)).cornerRadius(10)
                            }
                            .shadow(radius: 6)
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Surveys", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white)).cornerRadius(10)
                            }
                            .shadow(radius: 6)
                            NavigationLink(destination: DenemeView())
                            {
                                Label("Score Games", systemImage: "play")
                                    .labelStyle(.titleOnly).padding(15)
                                    .foregroundColor(Color.purple)
                                    .background(Color(.white)).cornerRadius(10)
                            }
                            .shadow(radius: 6)
                        }.padding(.leading, -25)
                    }.padding().navigationBarBackButtonHidden(true).toolbar{
                        Button("Logout") {
                            pm.wrappedValue.dismiss()
                        }
                        .foregroundColor(Color.white)
                        .font(.system(size:20, weight: .heavy))
                    }
                }.padding(.top, -50)
                
            }
            
        }
    }
    
    
    struct MainPageView_Previews: PreviewProvider {
        static var previews: some View {
            MainPageView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
