import SwiftUI

// MARK: - 📍 資料模型 (Model)
struct PhotoPost: Identifiable {
    let id = UUID()
    let authorName: String
    let authorAvatar: String
    let imageName: String
    let title: String
    let price: Int?
    let canUnlockWithAd: Bool
}

// MARK: - 📍 主畫面 (Main App View)
struct ContentView: View {
    var body: some View {
        TabView {
            FeedView()
                .tabItem {
                    Image(systemName: "house.fill")
                    Text("首頁")
                }
            
            UploadView()
                .tabItem {
                    Image(systemName: "plus.app.fill")
                    Text("上傳")
                }
            
            Text("個人主頁與設定開發中 🛠️")
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("我")
                }
        }
        .accentColor(.yellow)
    }
}

// MARK: - 📍 追焦動態牆 (Feed View)
struct FeedView: View {
    let posts = [
        PhotoPost(authorName: "暮春生", authorAvatar: "person.crop.circle.fill", imageName: "bicycle", title: "4月12日，陽明山花季追焦", price: 30, canUnlockWithAd: true),
        PhotoPost(authorName: "金字追士", authorAvatar: "person.crop.circle.badge.checkmark", imageName: "motorcycle", title: "4月10日，台九線夜馳", price: nil, canUnlockWithAd: true),
        PhotoPost(authorName: "東灣夜", authorAvatar: "person.crop.square.fill", imageName: "car.fill", title: "信義區街頭抓拍", price: 50, canUnlockWithAd: false)
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 20) {
                    ForEach(posts) { post in
                        PhotoCardView(post: post)
                    }
                }
                .padding()
            }
            .navigationTitle("推薦追焦 📸")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

// MARK: - 📍 單張照片卡片 (Photo Card View)
struct PhotoCardView: View {
    let post: PhotoPost
    @State private var showDownloadMenu = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            ZStack {
                Rectangle()
                    .fill(Color.gray.opacity(0.2))
                    .frame(height: 200)
                    .cornerRadius(12)
                
                Image(systemName: post.imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 80)
                    .foregroundColor(.gray)
            }
            
            Text(post.title)
                .font(.headline)
            
            HStack {
                Image(systemName: post.authorAvatar)
                    .foregroundColor(.gray)
                Text(post.authorName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                Button(action: {
                    showDownloadMenu = true
                }) {
                    Text(buttonText)
                        .font(.subheadline)
                        .bold()
                        .padding(.horizontal, 16)
                        .padding(.vertical, 8)
                        .background(Color.black)
                        .foregroundColor(.white)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.bottom, 10)
        .sheet(isPresented: $showDownloadMenu) {
            DownloadOptionsView(post: post)
                .presentationDetents([.fraction(0.35)])
        }
    }
    
    var buttonText: String {
        if let price = post.price {
            return "取得 NT$\(price)"
        } else if post.canUnlockWithAd {
            return "取得 觀看廣告"
        } else {
            return "免費下載"
        }
    }
}

// MARK: - 📍 下載解鎖選項彈窗 (Download Options Sheet)
struct DownloadOptionsView: View {
    let post: PhotoPost
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        VStack(spacing: 20) {
            Text("解鎖高清照片")
                .font(.title2)
                .bold()
                .padding(.top, 20)
            
            if post.canUnlockWithAd {
                Button(action: {
                    print("觸發播放廣告邏輯...")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "play.tv.fill")
                        Text("觀看廣告解鎖")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                    .font(.headline)
                }
            }
            
            if let price = post.price {
                Button(action: {
                    print("觸發 Apple Pay 或 In-App Purchase 邏輯... 扣款 NT$\(price)")
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "dollarsign.circle.fill")
                        Text("支付 NT$\(price) 直接下載")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.black)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .font(.headline)
                }
            }
            
            Spacer()
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - 📍 創作者上傳頁面 (Upload View)
struct UploadView: View {
    @State private var priceText: String = ""
    @State private var enableAdUnlock = true
    @State private var isFree = false
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("選擇照片")) {
                    HStack {
                        Spacer()
                        Image(systemName: "photo.badge.plus")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 50, height: 50)
                            .foregroundColor(.gray)
                            .padding()
                        Spacer()
                    }
                }
                
                Section(header: Text("設定下載模式")) {
                    Toggle("允許免費下載", isOn: $isFree)
                        .tint(.yellow)
                    
                    if !isFree {
                        Toggle("允許用戶看廣告解鎖", isOn: $enableAdUnlock)
                            .tint(.yellow)
                        
                        HStack {
                            Text("設定直接購買價格")
                            Spacer()
                            Text("NT$")
                            TextField("0", text: $priceText)
                                .keyboardType(.numberPad)
                                .multilineTextAlignment(.trailing)
                                .frame(width: 60)
                        }
                    }
                }
                
                Button(action: {
                    print("準備上傳到伺服器...")
                }) {
                    Text("發布作品")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .listRowBackground(Color.clear)
                .listRowInsets(EdgeInsets())
            }
            .navigationTitle("上傳作品 📤")
        }
    }
}
