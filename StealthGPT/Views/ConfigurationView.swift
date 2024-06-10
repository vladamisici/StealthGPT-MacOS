//
//  ConfigurationView.swift
//  StealthGPT
//
//  Created by Vlada Misici on 11.06.2024.
//

import SwiftUI

struct ConfigurationView: View {
    @Binding var selectedLanguage: String
    @Binding var selectedField: String
    @Binding var selectedModel: String
    @Environment(\.dismiss) var dismiss

    let languages = ["English", "Romanian", "French", "Spanish", "German", "Chinese"]
    let fields = ["General", "Technology", "Healthcare", "Finance", "Education"]
    let models = ["gpt-3.5-turbo", "gpt-4"]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("Configuration")
                .font(.largeTitle)
                .fontWeight(.bold)
            Picker("Select Language", selection: $selectedLanguage) {
                ForEach(languages.sorted(), id: \.self) { language in
                    Text(language).tag(language)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Picker("Select Field", selection: $selectedField) {
                ForEach(fields.sorted(), id: \.self) { field in
                    Text(field).tag(field)
                }
            }
            .pickerStyle(MenuPickerStyle())
            Picker("Select Model", selection: $selectedModel) {
                ForEach(models, id: \.self) { model in
                    Text(model).tag(model)
                }
            }
            .pickerStyle(MenuPickerStyle())

            Spacer()

            HStack {
                Spacer()
                Button("Close") {
                    dismiss()
                }
                .buttonStyle(DefaultButtonStyle())
            }
        }
        .padding()
    }
}

#Preview {
    ConfigurationView(
        selectedLanguage: .constant("English"),
        selectedField: .constant("General"),
        selectedModel: .constant("gpt-3.5-turbo")
    )
    .frame(width: 400, height: 300)
}

