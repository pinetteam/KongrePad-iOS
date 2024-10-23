import SwiftUI
import Foundation

struct ProgramDaysView: View {
    @Environment(\.presentationMode) var pm
    @Binding var hallId: Int
    @State var virtualStands: [VirtualStand]?
    @State var programs: [Program]?
    @State var programDays: [ProgramDay]?
    @State var isLoading: Bool = true

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center, spacing: 0) {
                    ZStack {
                        HStack(alignment: .center) {
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.buttonYellow)
                                .background(Circle().fill(.white))
                                .onTapGesture {
                                    pm.wrappedValue.dismiss()
                                }.frame(width: screen_width * 0.1)
                            Spacer()
                        }
                        Text("Gün Seçiniz")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width * 0.7, height: screen_height * 0.1)
                            .multilineTextAlignment(.center)
                    }.padding()
                        .frame(width: screen_width).background(AppColors.buttonYellow)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer().frame(height: 10)
                    if !isLoading {
                        VStack(alignment: .center) {
                            ScrollView(.vertical) {
                                VStack(spacing: 10) {
                                    ForEach(self.programDays ?? []) { day in
                                        NavigationLink(destination: ProgramsView(programDay: day, hallId: hallId)) {
                                            HStack {
                                                Image(systemName: "chevron.right.2")
                                                    .resizable()
                                                    .scaledToFit()
                                                    .frame(height: screen_height * 0.035).foregroundColor(.black)
                                                    .padding()
                                                
                                                // API'den gelen tarih formatını Türkçe'ye çeviriyoruz
                                                if let dayString = day.day, let turkishDate = getTurkishFormattedDate(from: dayString) {
                                                    Text(turkishDate)
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.black)
                                                        .padding()
                                                } else {
                                                    Text("Tarih Geçersiz")
                                                        .font(.system(size: 20))
                                                        .foregroundColor(.red)
                                                        .padding()
                                                }
                                                
                                                Spacer()
                                            }
                                            .frame(width: screen_width * 0.9, height: screen_height * 0.08)
                                            .background(AppColors.programButtonBlue)
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 10)
                                                    .stroke(.black)
                                            )
                                            .cornerRadius(10)
                                        }
                                    }
                                }
                            }.frame(width: screen_width * 0.9, height: screen_height * 0.7)
                        }
                    } else {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: Color.black))
                            .frame(width: screen_width, height: screen_height * 0.7)
                            .background(AppColors.bgLightYellow)
                    }
                    Spacer()
                }.navigationBarBackButtonHidden(true)
            }.background(AppColors.bgLightYellow)
        }
        .onAppear {
            getPrograms()
        }
    }

    func getPrograms() {
        self.isLoading = true
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(self.hallId)/program") else {
            return
        }

        var request = URLRequest(url: url)
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, _, error in
            guard let data = data, error == nil else {
                return
            }

            do {
                let programs = try JSONDecoder().decode(ProgramsJson.self, from: data)
                DispatchQueue.main.async {
                    self.programDays = programs.data
                }
            } catch {
                print("JSON Decode Hatası: \(error)")
            }
            DispatchQueue.main.async {
                self.isLoading = false
            }
        }.resume()
    }

    func getTurkishFormattedDate(from dateString: String) -> String? {
        // Tarih stringine geçici bir yıl ekliyoruz
        let dateStringWithYear = dateString + " 2024"

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMMM EEEE yyyy"
        dateFormatter.locale = Locale(identifier: "en_US")

        guard let date = dateFormatter.date(from: dateStringWithYear) else {
            print("Tarih çevirimi başarısız: \(dateStringWithYear)")
            return nil
        }
        
        let turkishDateFormatter = DateFormatter()
        turkishDateFormatter.dateFormat = "dd MMMM EEEE"
        turkishDateFormatter.locale = Locale(identifier: "tr_TR")

        let turkishDate = turkishDateFormatter.string(from: date)
        return turkishDate.capitalized
    }
}
