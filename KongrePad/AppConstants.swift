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
    @Binding var hallId: Int
    @State var response: String?
    @State var keypad: Keypad?
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(AppColors.bgBlue)
                        .background(
                            Circle().fill(AppColors.logoutButtonBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            dismiss()
                        }.frame(width: screen_width*0.1)
                        Text("\(keypad?.keypad ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.sendMailBlue)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screen_width)
                    .background(AppColors.sendMailBlue)
                    .overlay(Divider().background(.white), alignment: .bottom)
                    Spacer()
                    ScrollView(.vertical){
                        VStack(spacing: 10){
                            ForEach(Array(self.keypad?.options?.enumerated() ?? [].enumerated()), id: \.element){index, option in
                                HStack{
                                    if index%2 == 0{
                                        Text(option.option!)
                                            .font(.system(size: 20)).bold()
                                            .foregroundColor(Color.white)
                                            .frame(width: screen_width*0.4, height: screen_width*0.4)
                                            .background(AppColors.buttonPurple)
                                            .cornerRadius(20)
                                            .onTapGesture{
                                                sendVote(optionId: option.id!, keypadId: option.keypad_id!)
                                            }
                                        if(index < (keypad?.options!.count ?? 0) - 1){
                                            Text(keypad?.options![index+1].option! ?? "")
                                                .font(.system(size: 20)).bold()
                                                .foregroundColor(Color.white)
                                                .frame(width: screen_width*0.4, height: screen_width*0.4)
                                                .background(AppColors.buttonPurple)
                                                .cornerRadius(20)
                                                .onTapGesture{
                                                    sendVote(optionId: (keypad?.options![index+1].id)!, keypadId: option.keypad_id!)
                                                }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    Text(response ?? "").foregroundColor(Color.white)
                }.background(AppColors.bgBlue)
                    .onAppear{
                        getKeypad(HallId: hallId)
                    }
            }
        }
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
                        self.response = "Yanıtınız Gönderildi"
                    } else {
                        self.response = "Bir Sorun Meydana geldi"
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}


struct DebateView: View {
    @Binding var hallId: Int
    @State var debate: Debate?
    @State var response: String?
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    HStack(alignment: .top){
                        Image(systemName: "chevron.left")
                        .font(.system(size: 20)).bold().padding(8)
                        .foregroundColor(AppColors.bgBlue)
                        .background(
                            Circle().fill(AppColors.logoutButtonBlue)
                        )
                        .padding(5)
                        .onTapGesture {
                            dismiss()
                        }.frame(width: screen_width*0.1)
                        Text("\(debate?.title ?? "")")
                            .foregroundColor(Color.white)
                            .frame(width: screen_width*0.85, height: screen_height*0.1)
                            .background(AppColors.sendMailBlue)
                            .multilineTextAlignment(.center)
                    }
                    .frame(width: screen_width)
                    .background(AppColors.sendMailBlue)
                    .overlay(Divider().background(.white), alignment: .bottom)
                    Spacer()
                    ScrollView(.vertical){
                        VStack(spacing: 10){
                            ForEach(Array(self.debate?.teams?.enumerated() ?? [].enumerated()), id: \.element){index, team in
                                HStack{
                                    if index%2 == 0{
                                        Text(team.title!)
                                            .font(.system(size: 20)).bold()
                                            .foregroundColor(Color.white)
                                            .frame(width: screen_width*0.4, height: screen_width*0.4)
                                            .background(AppColors.buttonPurple)
                                            .cornerRadius(20)
                                            .onTapGesture{
                                                sendVote(teamId: team.id!, debateId: team.debate_id!)
                                            }
                                        if(index < (debate?.teams!.count ?? 0) - 1){
                                            Text(debate?.teams![index+1].title! ?? "")
                                                .font(.system(size: 20)).bold()
                                                .foregroundColor(Color.white)
                                                .frame(width: screen_width*0.4, height: screen_width*0.4)
                                                .background(AppColors.buttonPurple)
                                                .cornerRadius(20)
                                                .onTapGesture{
                                                    sendVote(teamId: (debate?.teams![index+1].id)!, debateId: team.debate_id!)
                                                }
                                        }
                                    }
                                }
                                
                            }
                        }
                    }
                    Text(response ?? "").foregroundColor(Color.white)
                }.background(AppColors.bgBlue)
                    .onAppear{
                        getDebate(HallId: hallId)
                    }
            }
        }
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
                } else
                {
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
                    if(response.status!){
                        self.response = "Oyunuz Gönderildi"
                    } else {
                        self.response = "Bir Sorun Meydana geldi"
                    }
                }
            } catch {
                print(error)
            }
        }.resume()
    }
}

struct LoadingView: View {
    @Binding var isLoading: Bool
    var body: some View{
        ZStack{
            Color(.white)
                .ignoresSafeArea()
                .opacity(0.3)
            ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: AppColors.bgBlue))
                .scaleEffect(3)
        }.background(BackgroundClearView())
            .onDisappear{
                isLoading = false
            }
    }
}

struct BackgroundClearView: UIViewRepresentable {
    func makeUIView(context: Context) -> UIView {
        let view = UIView()
        DispatchQueue.main.async {
            view.superview?.superview?.backgroundColor = .clear
        }
        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {}
}
