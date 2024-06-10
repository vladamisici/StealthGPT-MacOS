import Foundation
import SwiftUI
import AppKit

class ClipboardMonitor: ObservableObject {
    @Published var apiKey: String = UserDefaults.standard.string(forKey: "OpenAI_API_Key") ?? ""
    @Published var status: Binding<String>?
    @Published var errorMessage: Binding<String>?
    @Published var detailedErrorMessage: Binding<String>?
    @Published var stealthMode: Bool = UserDefaults.standard.bool(forKey: "Stealth_Mode")
    @Published var monitoringStarted: Bool = false

    private var previousContent: String? = nil
    private var timer: Timer? = nil

    func startMonitoring() {
        monitoringStarted = true
        startClipboardMonitoring()
        status?.wrappedValue = "Started monitoring clipboard."
    }

    private func startClipboardMonitoring() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.checkClipboard()
        }
    }

    private func checkClipboard() {
        guard monitoringStarted else { return }

        let pasteboard = NSPasteboard.general
        if let content = pasteboard.string(forType: .string) {
            if content != previousContent {
                previousContent = content
                print("Clipboard changed:", content)

                // Call GPT-4 API
                askGpt(question: content) { response, error in
                    DispatchQueue.main.async {
                        if let response = response {
                            pasteboard.clearContents()
                            pasteboard.setString(response, forType: .string)
                            if !self.stealthMode {
                                self.showNotification(message: "Ready")
                            }
                        } else if let error = error {
                            self.status?.wrappedValue = "Failed to get response from GPT-4"
                            self.errorMessage?.wrappedValue = "Failed to get response from GPT-4"
                            self.detailedErrorMessage?.wrappedValue = "Error: \(error.localizedDescription)\n\nResponse: \(error.userInfo)"
                        }
                    }
                }
            }
        }
    }

    private func askGpt(question: String, completion: @escaping (String?, NSError?) -> Void) {
        guard !apiKey.isEmpty else {
            let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "API Key is missing"])
            completion(nil, error)
            return
        }

        let url = URL(string: "https://api.openai.com/v1/completions")! // Updated endpoint
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let json: [String: Any] = [
            "model": "gpt-3.5-turbo", // Specify the model here
            "prompt": question,
            "max_tokens": 150
        ]

        let jsonData = try! JSONSerialization.data(withJSONObject: json, options: [])
        request.httpBody = jsonData

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                let nsError = error as NSError
                completion(nil, nsError)
                return
            }

            guard let data = data else {
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])
                print("No data received")
                completion(nil, error)
                return
            }

            do {
                if let responseJson = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let choices = responseJson["choices"] as? [[String: Any]],
                   let text = choices.first?["text"] as? String {
                    completion(text.trimmingCharacters(in: .whitespacesAndNewlines), nil)
                } else {
                    let responseString = String(data: data, encoding: .utf8) ?? "No response string"
                    let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response format", "response": responseString])
                    print("Invalid response format: \(responseString)")
                    completion(nil, error)
                }
            } catch {
                let responseString = String(data: data, encoding: .utf8) ?? "No response string"
                let nsError = error as NSError
                print("Failed to decode JSON: \(error.localizedDescription)")
                print("Response: \(responseString)")
                let error = NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: error.localizedDescription, "response": responseString])
                completion(nil, error)
            }
        }

        task.resume()
    }

    private func showNotification(message: String) {
        let notification = NSUserNotification()
        notification.title = "Script"
        notification.informativeText = message
        NSUserNotificationCenter.default.deliver(notification)
    }
}
