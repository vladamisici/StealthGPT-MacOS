import SwiftUI

struct ContentView: View {
    @State private var apiKey: String = UserDefaults.standard.string(forKey: "OpenAI_API_Key") ?? ""
    @State private var status: String = "Status: Not started"
    @State private var stealthMode: Bool = UserDefaults.standard.bool(forKey: "Stealth_Mode")
    @State private var showErrorDialog: Bool = false
    @State private var errorMessage: String = ""
    @State private var detailedErrorMessage: String = ""
    @State private var showApiKey: Bool = false
    @State private var showConfigDialog: Bool = false
    @State private var selectedLanguage: String = "English"
    @State private var selectedField: String = "General"
    @State private var selectedModel: String = "gpt-3.5-turbo"
    @StateObject private var clipboardMonitor = ClipboardMonitor()

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Image("logo")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 40, height: 40)
                Text("StealthGPT")
                    .font(.largeTitle)
                    .fontWeight(.bold)
            }
            .padding(.bottom, 20)

            HStack {
                Text("OpenAI API Key:")
                Spacer()
                Button(action: {
                    if let url = URL(string: "https://platform.openai.com/account/api-keys") {
                        NSWorkspace.shared.open(url)
                    }
                }) {
                    HStack{
                        Text("Get API Key")
                            .foregroundColor(.blue)
                        Image(systemName: "key.icloud.fill")
                            .foregroundColor(.blue)
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }

            HStack {
                if showApiKey {
                    TextField("Enter your API key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                } else {
                    SecureField("Enter your API key", text: $apiKey)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                }
                Button(action: {
                    showApiKey.toggle()
                }) {
                    Image(systemName: showApiKey ? "eye.slash.fill" : "eye.fill")
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding([.leading, .trailing], 10)

            HStack {
                Button(action: saveApiKey) {
                    Text("Save API Key")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(DefaultButtonStyle())

                Toggle("Stealth Mode", isOn: $stealthMode)
                    .onChange(of: stealthMode) { value in
                        UserDefaults.standard.set(value, forKey: "Stealth_Mode")
                        clipboardMonitor.stealthMode = value
                    }
            }

            Button(action: startMonitoring) {
                Text("Start Monitoring")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DefaultButtonStyle())

            HStack {
                statusIndicatorColor
                    .frame(width: 10, height: 10)
                    .clipShape(Circle())
                Text(status)
                    .padding([.leading, .trailing], 10)
            }

            if !errorMessage.isEmpty {
                Button("See More") {
                    showErrorDialog = true
                }
                .alert(isPresented: $showErrorDialog) {
                    Alert(
                        title: Text("Error Details"),
                        message: Text(detailedErrorMessage),
                        primaryButton: .default(Text("Submit Error"), action: {
                            // Placeholder pentru acțiunea de submitere a erorii
                        }),
                        secondaryButton: .cancel()
                    )
                }
            }

            Button(action: {
                showConfigDialog = true
            }) {
                Text("Configure")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(DefaultButtonStyle())
            .sheet(isPresented: $showConfigDialog) {
                ConfigurationView(selectedLanguage: $selectedLanguage, selectedField: $selectedField, selectedModel: $selectedModel)
            }

            Spacer()
        }
        .padding()
        .frame(width: 400, height: 300) // Dimensiunea fixă a ferestrei
        .onAppear {
            clipboardMonitor.status = $status
            clipboardMonitor.errorMessage = $errorMessage
            clipboardMonitor.detailedErrorMessage = $detailedErrorMessage
        }
    }

    private var statusIndicatorColor: Color {
        switch status {
        case "Status: Not started":
            return .gray
        case "Started monitoring clipboard.":
            return .green
        default:
            return .red
        }
    }

    func saveApiKey() {
        UserDefaults.standard.set(apiKey, forKey: "OpenAI_API_Key")
        clipboardMonitor.apiKey = apiKey
        status = "API Key saved."
    }

    func startMonitoring() {
        guard !apiKey.isEmpty else {
            status = "Please enter and save the API Key first."
            return
        }
        clipboardMonitor.startMonitoring()
        status = "Started monitoring clipboard."
    }
}

#Preview {
    ContentView()
        .frame(width: 600, height: 400)
        .background(CircleAnimationView())
}
