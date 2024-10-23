//
//  DenemeView.swift
//  KongrePad
//
//  Created by Mert Demirbağ on 21.08.2023.
//

import SwiftUI
import CodeScanner

struct LoginView: View {
    
    @State var isPresentingScanner = false
    @State var isPresentingKvkk = false
    @State var isPresentingLoginWithCode = false
    @State var goToMainPage = false
    @State var scanError : String = ""
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var pusherManager: PusherManager
    
    var scannerSheet : some View {
        CodeScannerView(codeTypes: [.qr], completion: {
            result in
            if case let .success(code) = result{
                guard let url = URL(string: "https://app.kongrepad.com/api/v1/auth/login/participant") else {
                    return
                }
                
                var request = URLRequest(url: url)
                
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                
                let body: [String: AnyHashable] = [
                    "username" : code.string,
                ]
                
                request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
                URLSession.shared.dataTask(with: request) {data, _, error in
                    guard let data = data, error == nil else {
                        return
                    }
                    
                    do{
                        let response = try JSONSerialization.jsonObject(with: data,options: .allowFragments) as! [String: Any]
                        let userDefault = UserDefaults.standard
                        guard let token = response["token"]  else {
                            self.scanError = "Geçersiz bir kare kod okuttunuz!"
                            return
                        }
                        self.goToMainPage = true
                        userDefault.set(token, forKey: "token")
                        userDefault.synchronize()
                        getMeeting()
                        self.scanError = ""
                    } catch {
                        print(error)
                    }
                }.resume()
                self.isPresentingScanner = false
            }
        }).onDisappear{
            if self.scanError != "" {
                let error = scanError
                self.scanError = ""
                alertManager.present(title: "Uyarı", text: error)
            }
        }
        }
    
    var body: some View {
        
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                ZStack{
                    Circle()
                        .frame(width: screen_height*2, height: screen_height*2)
                        .foregroundColor(Color.white)
                        .offset(y: -screen_height*0.6)
                        .frame(width: screen_width, height: screen_height*0.1)
                        .shadow(radius: 6)
                    Circle()
                        .frame(width: screen_height*2, height: screen_height*2)
                        .foregroundColor(AppColors.bgBlue)
                        .offset(y: -screen_height*1.2)
                        .frame(width: screen_width, height: screen_height*0.1)
                        .shadow(radius: 6)
                    VStack(alignment: .center){
                        Image(uiImage: UIImage(named: "logo")!)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: screen_width*0.5)
                            .frame(height: screen_width*0.5)
                            .padding(30)
                            .background(Color.white)
                            .clipShape(Circle())
                            .shadow(radius: 5)
                            Spacer().frame(height: screen_height*0.05)
                        Button(action: {
                            self.isPresentingScanner = true
                        }){
                            HStack{
                                Text("Giriş")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.white)
                                Image(systemName: "arrow.right")
                                    .font(.largeTitle)
                                    .foregroundColor(Color.white)
                            }.padding()
                                .padding(.leading, 20)
                                .padding(.trailing, 20)
                            .background(Color.orange)
                            .cornerRadius(10)
                        }.sheet(isPresented: $isPresentingScanner) {
                            self.scannerSheet
                        }.navigationDestination(isPresented: $goToMainPage){
                            MainPageView()
                            }
                        Text("Giriş yap butonuna bastıktan sonra yaka kartınızda bulunan kare kodu kameraya gösteriniz.").font(.system(size: 22)).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        (
                            Text("\"Uygulamaya giriş yaparak ").font(.footnote) + Text("6698 sayılı KVKK'yı").underline().font(.footnote)
                            + Text(" kabul ediyorum.\"").font(.footnote)
                        ).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        .onTapGesture {
                            self.isPresentingKvkk = true
                        }
                        .sheet(isPresented: $isPresentingKvkk) {
                            ScrollView(.vertical){
                                VStack{
                                    Text("KİŞİLER VERİLERİN KORUNMASI AYDINLATMA METNİ ve TİCARİ ELEKTRONİK İLETİ MUVAFAKATNAMESİ").bold()
                                    
                                    Text("A-    KİŞİLER VERİLERİN KORUNMASI AYDINLATMA METNİ 6698 sayılı Kişisel Verilerin Korunması Kanunu (“Kanun”) uyarınca, kişisel verileriniz; veri sorumlusu olarak D Event Turizm Organizasyon Hizmetleri Limited Şirketi (“D Event” veya “Şirket”) tarafından aşağıda açıklanan koşullar kapsamında işlenmektedir.")
                                    Text("1.Kişisel Verilerin İşlenme Amacı\nKişisel verileriniz, bilgi güvenliğini ve hukuki işlem güvenliğini sağlamamız ve faaliyetlerin mevzuata uygun yürütülmesini sağlamamamız başta olmak üzere, iletişim faaliyetlerinin yürütülmesi, verilerinizin doğruluğunun sağlanması, ürün/hizmetlerin pazarlama süreçlerinin yürütülmesi,ürün ve/veya hizmetlerimizin tanıtımı, sunulması ve satış süreçlerinin işletilmesi, sözleşmelerin müzakeresi, akdedilmesi ve ifası, mevcut ile yeni ürün ve hizmetlerdeki değişikliklerin, kampanyaların, promosyonların duyurulması, pazarlama ve satış faaliyetlerinin yürütülmesi, sosyal medya ve kurumsal iletişim süreçlerinin planlanması ve icra edilmesi, reklam/kampanya/promosyon süreçlerinin yürütülmesi, ihtiyaçlar, talepler ile yasal ve teknik gelişmeler doğrultusunda ürün ve hizmetlerimizin güncellenmesi, özelleştirilmesi, geliştirilmesi ve üyelik işlemlerinin gerçekleştirilmesi amaçlarıyla işlenecektir.")
                                    Text("2. Kişisel Verileri Toplama Yöntemleri ve Hukuki Sebepleri\nMobil uygulama/internet sitesi üzerinden toplanan kişisel veriler (kimlik ve iletişim bilgileri) ilgili kişinin mobil uygulama/internet sitesi içerisinde yer alan formları doldurması ile toplanmaktadır. Bu kişisel veriler Kanun’da belirtilen kişisel veri işleme şartlarına uygun olarak ve sizinle aramızdaki ilişkinin icrası ve faaliyetlerin mevzuata uygunluğunun temini amaçları başta olmak üzere, sizlere ait kişisel verilerin işlenmesinin gerekli olması, hukuki yükümlülüğümüzü yerine getirebilmek için zorunlu olması hukuki sebepleri doğrultusunda işlenmektedir.")
                                    Text("3.İşlenen Kişisel Verilerin Aktarılması\n Şirketimiz, kişisel verilerinizi “bilme gereği” ve “kullanma gereği” ilkelerine uygun olarak, gerekli veri minimizasyonunu sağlayarak ve gerekli teknik ve idari güvenlik tedbirlerini alarak işlemeye özen göstermektedir. Şirketimiz, topladığı kişisel verileri faaliyetlerini yürütebilmek için iş birliği yaptığı kurum ve kuruluşlarla, verilerin bulut ortamında saklanması halinde yurt içindeki/yurt dışındaki kişi ve kurumlarla, ticari elektronik iletilerin gönderilmesi konusunda anlaşmalı olduğu yurt içindeki/yurt dışındaki kuruluşlarla, talep halinde kamu otoriteleriyle ve hizmetin verilmesiyle ilgili olarak iş ortakları ile paylaşabilmektedir.")
                                    Text("4.Veri Sorumlusuna Başvuru Yolları ve Haklarınız\nŞirketimize başvurarak, kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, kişisel verilerinizin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme, yurt içinde kişisel verilerinizin aktarıldığı üçüncü kişileri bilme, kişisel verilerinizin eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme ve bu kapsamda yapılan işlemin kişisel verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme, kanunda öngörülen şartlar çerçevesinde kişisel verilerinizin silinmesini veya yok edilmesini isteme, zarara uğramanız hâlinde zararınızın giderilmesini talep etme haklarına sahipsiniz.")
                                    Text("Kişisel verilerinizle ilgili sorularınızı ve taleplerinizi, info@devent.com adresine gönderebilir ya da 0 216 573 18 36 numaralı telefondan bilgi alabilirsiniz.")
                                    Text("Şirket, işbu metni yürürlükteki mevzuatta yapılabilecek değişiklikler çerçevesinde her zaman güncelleme hakkını saklı tutar.")
                                    Text("B-    TİCARİ ELEKTRONİK İLETİ MUVAFAKATNAMESİ")
                                    Text("D Event Turizm Organizasyon Hizmetleri Limited Şirketi’ne vermiş olduğum iletişim adreslerime,  her türlü tanıtım, reklam, bilgilerme vb. amaçlarla ticari elektronik ileti (e-posta,sms vs.) gönderilmesine 6563 sayılı Kanun gereği muvafakat ediyorum.")
                                }
                            }.padding()
                        }.padding(.bottom, 5)
                        HStack{
                            Text("Kod ile Giriş")
                                .font(.title3)
                                .foregroundColor(Color.white)
                            Image(systemName: "rectangle.and.pencil.and.ellipsis")
                                .font(.title3)
                                .foregroundColor(Color.white)
                        }.padding()
                        .background(AppColors.bgBlue).cornerRadius(10)
                        .onTapGesture {
                            self.isPresentingLoginWithCode = true
                        }.sheet(isPresented: $isPresentingLoginWithCode){
                            loginWithCode(goToMainPage: $goToMainPage, scanError: $scanError)
                        }
                        Text("v1.3.0").font(.footnote).foregroundColor(.black)
                    }.padding()
                }.frame(width: screen_width, height: screen_height)
                    .background(AppColors.bgBlue)
            }
            
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            let userDefault = UserDefaults.standard
                if(userDefault.string(forKey: "token") != nil)
                {
                    self.goToMainPage = true
                }
        }
        
    }
    
    func getMeeting() {
        
            guard let url = URL(string: "https://app.kongrepad.com/api/v1/meeting") else {
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
                    let meeting = try JSONDecoder().decode(MeetingJSON.self, from: data)
                    pusherManager.setChannel("meeting-\(String(describing: meeting.data!.id!))")
                } catch {
                    print(error)
                }
            }.resume()
    }
}
struct loginWithCode: View {
    @Binding var goToMainPage: Bool
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var pusherManager: PusherManager
    @State var isPresentingKvkk = false
    @State var code: String = ""
    @Binding var scanError: String
    @Environment (\.dismiss) var dismiss
    var body: some View{
        NavigationStack{
            GeometryReader{ geometry in
                let screen_width = geometry.size.width
                let screen_height = geometry.size.height
                VStack(alignment: .center){
                    ZStack{
                        HStack(alignment: .center){
                            Image(systemName: "chevron.left")
                                .font(.system(size: 20)).bold().padding(8)
                                .foregroundColor(AppColors.bgBlue)
                                .background(
                                    Circle().fill(.white)
                                )
                                .onTapGesture {
                                    dismiss()
                                }.frame(width: screen_width*0.1)
                            Spacer()
                        }
                        Text("Kod ile Giriş")
                            .foregroundColor(Color.white).font(.title)
                            .frame(width: screen_width*0.7, height: screen_height*0.1)
                            .multilineTextAlignment(.center)
                    }.padding().frame(width: screen_width).background(AppColors.bgBlue)
                        .overlay(Rectangle().frame(width: nil, height: 1, alignment: .bottom).foregroundColor(Color.gray), alignment: .bottom)
                    Spacer()
                    TextField("", text: $code, prompt: Text("Lütfen kodunuzu buraya giriniz.").foregroundColor(.orange), axis: .vertical)
                        .tint(.orange).foregroundColor(.orange)
                        .frame(width: screen_width*0.9).padding()
                        .background(.white).cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(Color.orange, lineWidth: 2)
                        ).padding(.bottom, 5)
                    (
                            Text("\"Uygulamaya giriş yaparak ").font(.footnote) + Text("6698 sayılı KVKK'yı").underline().font(.footnote)
                            + Text(" kabul ediyorum.\"").font(.footnote)
                    ).foregroundColor(.white).multilineTextAlignment(.center).frame(width: screen_width*0.8)
                        .onTapGesture {
                            self.isPresentingKvkk = true
                        }
                        .sheet(isPresented: $isPresentingKvkk) {
                            ScrollView(.vertical){
                                VStack{
                                    Text("KİŞİLER VERİLERİN KORUNMASI AYDINLATMA METNİ ve TİCARİ ELEKTRONİK İLETİ MUVAFAKATNAMESİ").bold()
                                    
                                    Text("A-    KİŞİLER VERİLERİN KORUNMASI AYDINLATMA METNİ 6698 sayılı Kişisel Verilerin Korunması Kanunu (“Kanun”) uyarınca, kişisel verileriniz; veri sorumlusu olarak D Event Turizm Organizasyon Hizmetleri Limited Şirketi (“D Event” veya “Şirket”) tarafından aşağıda açıklanan koşullar kapsamında işlenmektedir.")
                                    Text("1.Kişisel Verilerin İşlenme Amacı\nKişisel verileriniz, bilgi güvenliğini ve hukuki işlem güvenliğini sağlamamız ve faaliyetlerin mevzuata uygun yürütülmesini sağlamamamız başta olmak üzere, iletişim faaliyetlerinin yürütülmesi, verilerinizin doğruluğunun sağlanması, ürün/hizmetlerin pazarlama süreçlerinin yürütülmesi,ürün ve/veya hizmetlerimizin tanıtımı, sunulması ve satış süreçlerinin işletilmesi, sözleşmelerin müzakeresi, akdedilmesi ve ifası, mevcut ile yeni ürün ve hizmetlerdeki değişikliklerin, kampanyaların, promosyonların duyurulması, pazarlama ve satış faaliyetlerinin yürütülmesi, sosyal medya ve kurumsal iletişim süreçlerinin planlanması ve icra edilmesi, reklam/kampanya/promosyon süreçlerinin yürütülmesi, ihtiyaçlar, talepler ile yasal ve teknik gelişmeler doğrultusunda ürün ve hizmetlerimizin güncellenmesi, özelleştirilmesi, geliştirilmesi ve üyelik işlemlerinin gerçekleştirilmesi amaçlarıyla işlenecektir.")
                                    Text("2. Kişisel Verileri Toplama Yöntemleri ve Hukuki Sebepleri\nMobil uygulama/internet sitesi üzerinden toplanan kişisel veriler (kimlik ve iletişim bilgileri) ilgili kişinin mobil uygulama/internet sitesi içerisinde yer alan formları doldurması ile toplanmaktadır. Bu kişisel veriler Kanun’da belirtilen kişisel veri işleme şartlarına uygun olarak ve sizinle aramızdaki ilişkinin icrası ve faaliyetlerin mevzuata uygunluğunun temini amaçları başta olmak üzere, sizlere ait kişisel verilerin işlenmesinin gerekli olması, hukuki yükümlülüğümüzü yerine getirebilmek için zorunlu olması hukuki sebepleri doğrultusunda işlenmektedir.")
                                    Text("3.İşlenen Kişisel Verilerin Aktarılması\n Şirketimiz, kişisel verilerinizi “bilme gereği” ve “kullanma gereği” ilkelerine uygun olarak, gerekli veri minimizasyonunu sağlayarak ve gerekli teknik ve idari güvenlik tedbirlerini alarak işlemeye özen göstermektedir. Şirketimiz, topladığı kişisel verileri faaliyetlerini yürütebilmek için iş birliği yaptığı kurum ve kuruluşlarla, verilerin bulut ortamında saklanması halinde yurt içindeki/yurt dışındaki kişi ve kurumlarla, ticari elektronik iletilerin gönderilmesi konusunda anlaşmalı olduğu yurt içindeki/yurt dışındaki kuruluşlarla, talep halinde kamu otoriteleriyle ve hizmetin verilmesiyle ilgili olarak iş ortakları ile paylaşabilmektedir.")
                                    Text("4.Veri Sorumlusuna Başvuru Yolları ve Haklarınız\nŞirketimize başvurarak, kişisel verilerinizin işlenip işlenmediğini öğrenme, işlenmişse buna ilişkin bilgi talep etme, kişisel verilerinizin işlenme amacını ve bunların amacına uygun kullanılıp kullanılmadığını öğrenme, yurt içinde kişisel verilerinizin aktarıldığı üçüncü kişileri bilme, kişisel verilerinizin eksik veya yanlış işlenmiş olması halinde bunların düzeltilmesini isteme ve bu kapsamda yapılan işlemin kişisel verilerin aktarıldığı üçüncü kişilere bildirilmesini isteme, kanunda öngörülen şartlar çerçevesinde kişisel verilerinizin silinmesini veya yok edilmesini isteme, zarara uğramanız hâlinde zararınızın giderilmesini talep etme haklarına sahipsiniz.")
                                    Text("Kişisel verilerinizle ilgili sorularınızı ve taleplerinizi, info@devent.com adresine gönderebilir ya da 0 216 573 18 36 numaralı telefondan bilgi alabilirsiniz.")
                                    Text("Şirket, işbu metni yürürlükteki mevzuatta yapılabilecek değişiklikler çerçevesinde her zaman güncelleme hakkını saklı tutar.")
                                    Text("B-    TİCARİ ELEKTRONİK İLETİ MUVAFAKATNAMESİ")
                                    Text("D Event Turizm Organizasyon Hizmetleri Limited Şirketi’ne vermiş olduğum iletişim adreslerime,  her türlü tanıtım, reklam, bilgilerme vb. amaçlarla ticari elektronik ileti (e-posta,sms vs.) gönderilmesine 6563 sayılı Kanun gereği muvafakat ediyorum.")
                                }
                            }.padding()
                        }.padding(.bottom, 5)
                    HStack{
                        Text("Giriş")
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                        Image(systemName: "arrow.right")
                            .font(.largeTitle)
                            .foregroundColor(Color.white)
                    }.padding()
                        .padding(.leading, 20)
                        .padding(.trailing, 20)
                        .background(Color.orange)
                        .cornerRadius(10)
                        .onTapGesture {
                            login()
                        }
                    Spacer()
                }.background(AppColors.bgBlue)
            }
        }.onDisappear{
            if self.scanError != "" {
                let error = scanError
                self.scanError = ""
                alertManager.present(title: "Uyarı", text: error)
            }
        }
    }
    func login(){
        guard let url = URL(string: "https://app.kongrepad.com/api/v1/auth/login/participant") else {
            return
        }
        
        var request = URLRequest(url: url)
        
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: AnyHashable] = [
            "username" : self.code,
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .fragmentsAllowed)
        URLSession.shared.dataTask(with: request) {data, _, error in
            guard let data = data, error == nil else {
                return
            }
            
            do{
                let response = try JSONSerialization.jsonObject(with: data,options: .allowFragments) as! [String: Any]
                let userDefault = UserDefaults.standard
                guard let token = response["token"]  else {
                    self.scanError = "Geçersiz bir kod girdiniz!"
                    dismiss()
                    return
                }
                self.goToMainPage = true
                userDefault.set(token, forKey: "token")
                userDefault.synchronize()
                getMeeting()
                self.scanError = ""
                dismiss()
            } catch {
                print(error)
            }
        }.resume()
    }
    
    func getMeeting() {
        
            guard let url = URL(string: "https://app.kongrepad.com/api/v1/meeting") else {
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
                    let meeting = try JSONDecoder().decode(MeetingJSON.self, from: data)
                    pusherManager.setChannel("meeting-\(String(describing: meeting.data!.id!))")
                } catch {
                    print(error)
                }
            }.resume()
    }
}
