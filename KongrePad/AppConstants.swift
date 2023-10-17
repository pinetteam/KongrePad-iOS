import SwiftUI


struct AppColors{
    static let bgBlue = Color("bgBlue")
    static let bgLightBlue = Color("bgLightBlue")
    static let bgLightPink = Color("bgLightPink")
    static let bgLightYellow = Color("bgLightYellow")
    static let notificationsRed = Color("notificationsRed")
    static let sendMailBlue = Color("sendMailBlue")
    static let bgOrange = Color("bgOrange")
    static let buttonLightBlue = Color("buttonLightBlue")
    static let buttonDarkBlue = Color("buttonDarkBlue")
    static let buttonYellow = Color("buttonYellow")
    static let buttonGreen = Color("buttonGreen")
    static let buttonPink = Color("buttonPink")
    static let buttonRed = Color("buttonRed")
    static let buttonPurple = Color("buttonPurple")
    static let logoutButtonBlue = Color("logoutButtonBlue")
    static let sendButtonGreen = Color("sendButtonGreen")
    static let programDateYellow = Color("programDateYellow")
    static let programTitleBlue = Color("programTitleBlue")
    static let programDayBackground = Color("programDayBackground")
    static let programButtonBlue = Color("programButtonBlue")
}



struct KeypadView: View {
    @EnvironmentObject var alertManager: AlertManager
    @Binding var hallId: Int
    @State var response: String?
    @State var success: Bool?
    @State var keypad: Keypad?
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                        Text("Lütfen size en uygun yanıtı seçiniz.")
                            .foregroundColor(Color.white).font(.title2)
                            .frame(width: screen_width*0.9, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding().frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    Text(keypad?.keypad ?? "")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .foregroundColor(.white)
                        .frame(width: screen_width*0.9)
                    if self.keypad != nil {
                        ScrollView(.vertical){
                            VStack(spacing: 20){
                                ForEach(Array(self.keypad?.options?.enumerated() ?? [].enumerated()), id: \.element){index, option in
                                    HStack(){
                                        Image(systemName: "greaterthan.circle.fill")
                                            .foregroundColor(.white)
                                        Text(option.option!)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .padding()
                                            .foregroundColor(.white)
                                    }
                                    .frame(width: screen_width*0.9)
                                    .background(.gray)
                                    .cornerRadius(10)
                                    .onTapGesture{
                                            sendVote(optionId: option.id!, keypadId: option.keypad_id!)
                                        }
                                    
                                }
                            }
                        }
                    } else {
                        Text("Aktif Keypad Yok")
                            .font(.system(size: 20)).bold()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding()
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.8)
                    }
                }.background(AppColors.bgBlue)
                    .onAppear{
                        getKeypad(HallId: hallId)
                    }.onDisappear{
                        if let text = self.response
                            {
                            alertManager.present(title: self.success ?? false ? "Başarılı" : "Uyarı", text: text)
                            }
                    }
            }
        }.interactiveDismissDisabled()
    }
    func getKeypad(HallId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(HallId)/active-keypad") else {
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
                let keypad = try JSONDecoder().decode(KeypadJSON.self, from: data)
                self.success = keypad.status!
                if keypad.status!{
                    DispatchQueue.main.async {
                        self.keypad = keypad.data
                    }
                } else {
                    self.keypad = nil
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    func sendVote(optionId: Int, keypadId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/keypad/\(keypadId)/keypad-vote") else {
            return
        }
        let body: [String: Any] = ["option": optionId]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(SessionQuestionResponseJSON.self, from: data)
                DispatchQueue.main.async {
                    if(response.status!){
                        self.response = "Yanıtınız gönderildi!"
                    } else {
                        self.response = "Daha önceden yanıt verdiniz!"
                    }
                    dismiss()
                }
            } catch {
                print(error)
                dismiss()
            }
        }.resume()
    }
}


struct DebateView: View {
    @EnvironmentObject var alertManager: AlertManager
    @Binding var hallId: Int
    @State var debate: Debate?
    @State var response: String?
    @State var success: Bool?
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                        Text("Lütfen oy vermek istediğiniz takımı seçiniz.")
                            .foregroundColor(Color.white).font(.title2)
                            .frame(width: screen_width*0.9, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding().frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom).shadow(radius: 6)
                    Spacer()
                    if self.debate != nil {
                    ScrollView(.vertical){
                        VStack(spacing: 10){
                            ForEach(Array(self.debate?.teams?.enumerated() ?? [].enumerated()), id: \.element){index, team in
                                if let data = Data(base64Encoded: team.logo ?? "" ,options: .ignoreUnknownCharacters){
                                            let image = UIImage(data: data)
                                            Image(uiImage: image ?? UIImage())
                                                .resizable()
                                                .ignoresSafeArea()
                                                .aspectRatio(contentMode: .fit).padding()
                                                .frame(width: screen_width*0.7, height: screen_width*0.7)
                                                .background(.gray)
                                                .cornerRadius(10)
                                                .onTapGesture{
                                                    sendVote(teamId: team.id!, debateId: team.debate_id!)
                                                }
                                        }else{
                                            Text(team.title!)
                                                .font(.system(size: 20)).bold()
                                                .foregroundColor(Color.white)
                                                .frame(width: screen_width*0.7, height: screen_width*0.7)
                                                .background(AppColors.buttonPurple)
                                                .cornerRadius(10)
                                                .onTapGesture{
                                                    sendVote(teamId: team.id!, debateId: team.debate_id!)
                                                }
                                        }
                            }
                        }
                    }
                } else {
                    Text("Aktif Münazara Yok")
                        .font(.system(size: 20)).bold()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .foregroundColor(Color.white)
                        .frame(width: screen_width*0.8)
                }
                }.background(AppColors.bgBlue)
                    .onAppear{
                        getDebate(HallId: hallId)
                    }.onDisappear{
                        if let text = self.response
                            {
                            alertManager.present(title: self.success ?? false ? "Başarılı" : "Uyarı", text: text)
                            }
                    }
            }
        }.interactiveDismissDisabled()
    }
    func getDebate(HallId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/hall/\(HallId)/active-debate") else {
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
                let debate = try JSONDecoder().decode(DebateJSON.self, from: data)
                if debate.status!{
                    DispatchQueue.main.async {
                        self.debate = debate.data
                    }
                } else {
                    self.debate = nil
                }
            } catch {
                print(error)
            }
        }.resume()
    }
    func sendVote(teamId: Int, debateId: Int){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/debate/\(debateId)/debate-vote") else {
            return
        }
        let body: [String: Any] = ["team": teamId]
        let jsonData = try? JSONSerialization.data(withJSONObject: body)
        var request = URLRequest(url: url)
        
        request.addValue("Bearer \(UserDefaults.standard.string(forKey: "token")!)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) {data, response, error in
            guard let data = data, error == nil else {
                return
            }
            do{
                let response = try JSONDecoder().decode(SessionQuestionResponseJSON.self, from: data)
                DispatchQueue.main.async {
                    self.success = response.status!
                    if(response.status!){
                        self.response = "Oyunuz gönderildi!"
                    } else {
                        self.response = "Daha önceden oy kullandınız!"
                    }
                    dismiss()
                }
            } catch {
                print(error)
                dismiss()
            }
        }.resume()
    }
}

struct EmptyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
    }
}

