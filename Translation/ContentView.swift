
//AIzaSyBwu0znjGkP7JIk4Qh1sjj1caHmu9GV8Yo


import SwiftUI

struct ContentView: View {
    @State private var sourceText = ""
    @State private var targetText = ""
    @State private var selectedInputLanguageIndex = 0
    @State private var selectedOutputLanguageIndex = 0
    @State private var isInputPickerExpanded = false
    @State private var isOutputPickerExpanded = false
    @State private var isTranslationStarted = false
    
    private let apiKey = "AIzaSyBwu0znjGkP7JIk4Qh1sjj1caHmu9GV8Yo"
    private let languages = [
        ("en", "English"),
        ("es", "Spanish"),
        ("fr", "French"),
        ("vi", "Vietnamese"),
        ("ko", "Korean"),
        ("zh", "Chinese"),
        ("ja", "Japanese"),
        // Add more language codes and names here
    ]
    
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        Group {
            if isTranslationStarted {
                translationView
            } else {
                introView
            }
        }
        .preferredColorScheme(.dark)
        .onAppear {
            fetchTranslation()
        }
    }
    
    private var introView: some View {
        VStack(spacing: 20) {
            Text("Welcome to Our Translator")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Translate text between different languages with ease.")
                .multilineTextAlignment(.center)
            
            Button(action: {
                isTranslationStarted = true
            }) {
                Text("Get Started")
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
    
    private var translationView: some View {
        VStack(spacing: 10) {
            HStack {
                Picker("Input Language", selection: $selectedInputLanguageIndex) {
                    ForEach(0..<languages.count, id: \.self) { index in
                        Text(languages[index].1)
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.primary)
                .padding()
                .onChange(of: selectedInputLanguageIndex) { _ in
                    fetchTranslation()
                }
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
                
                Picker("Output Language", selection: $selectedOutputLanguageIndex) {
                    ForEach(0..<languages.count, id: \.self) { index in
                        Text(languages[index].1)
                            .tag(index)
                    }
                }
                .pickerStyle(MenuPickerStyle())
                .foregroundColor(.primary)
                .padding()
                .onChange(of: selectedOutputLanguageIndex) { _ in
                    fetchTranslation()
                }
                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
            }
            .padding(.top, verticalSizeClass == .compact ? 50 : 100)
            .padding(.bottom, verticalSizeClass == .compact ? 10 : 20)
            .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
            
            TextEditor(text: $sourceText)
                .font(.title2)
                .frame(width: adaptiveTextFieldWidth, height: adaptiveTextFieldHeight)
                .foregroundColor(.primary)
                .background(Color.secondary)
                .cornerRadius(10)
                .padding(.horizontal, adaptiveTextFieldPadding)
                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Button(action: {
                fetchTranslation()
            }) {
                Text("Translate")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            
            Text(targetText)
                .font(.title2)
                .foregroundColor(.primary)
                .padding()
                .shadow(color: .white.opacity(0.3), radius: 10, x: 0, y: 5)
            
            Spacer()
        }
        .padding()
        .background(Color.black)
        .edgesIgnoringSafeArea(.all)
    }
    
    private func fetchTranslation() {
        let inputLanguageCode = languages[selectedInputLanguageIndex].0
        let outputLanguageCode = languages[selectedOutputLanguageIndex].0
        let url = URL(string: "https://translation.googleapis.com/language/translate/v2?key=\(apiKey)")!
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let body = "q=\(sourceText)&source=\(inputLanguageCode)&target=\(outputLanguageCode)"
        request.httpBody = body.data(using: .utf8)
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let data = data {
                if let translation = parseTranslation(data: data) {
                    DispatchQueue.main.async {
                        targetText = translation
                    }
                }
            }
        }.resume()
    }
    
    private func parseTranslation(data: Data) -> String? {
        let json = try? JSONSerialization.jsonObject(with: data, options: [])
        if let dict = json as? [String: Any],
           let data = dict["data"] as? [String: Any],
           let translations = data["translations"] as? [[String: Any]],
           let translation = translations.first,
           let translatedText = translation["translatedText"] as? String {
            return translatedText
        }
        return nil
    }
    
    // Adaptive Sizes
    private var adaptiveTextFieldWidth: CGFloat {
        if horizontalSizeClass == .compact {
            return 300
        } else {
            return 380
        }
    }
    
    private var adaptiveTextFieldHeight: CGFloat {
        if verticalSizeClass == .compact {
            return 100
        } else {
            return 220
        }
    }
    
    private var adaptiveTextFieldPadding: CGFloat {
        if horizontalSizeClass == .compact {
            return 20
        } else {
            return 60
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
