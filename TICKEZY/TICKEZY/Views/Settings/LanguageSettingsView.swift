//
//  LanguageSettingsView.swift
//  TICKEZY
//
//  Created by Antigravity on 12/27/25.
//

import SwiftUI

struct LanguageSettingsView: View {
    @Environment(\.dismiss) var dismiss
    @State private var selectedLanguage = "en"
    @State private var searchText = ""
    
    let languages = [
        Language(id: "en", name: "English", nativeName: "English", flag: "🇺🇸"),
        Language(id: "fr", name: "French", nativeName: "Français", flag: "🇫🇷"),
        Language(id: "rw", name: "Kinyarwanda", nativeName: "Ikinyarwanda", flag: "🇷🇼"),
        Language(id: "es", name: "Spanish", nativeName: "Español", flag: "🇪🇸"),
        Language(id: "de", name: "German", nativeName: "Deutsch", flag: "🇩🇪")
    ]
    
    var filteredLanguages: [Language] {
        if searchText.isEmpty {
            return languages
        } else {
            return languages.filter { $0.name.localizedCaseInsensitiveContains(searchText) || $0.nativeName.localizedCaseInsensitiveContains(searchText) }
        }
    }
    
    var body: some View {
        ZStack {
            Color.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Search Bar
                searchBar
                    .padding()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // Current Selection info
                        currentSelectionCard
                        
                        // Language List
                        VStack(alignment: .leading, spacing: 12) {
                            Text("All Languages".uppercased())
                                .font(.caption2.bold())
                                .foregroundColor(.textTertiary)
                                .padding(.leading, 8)
                            
                            VStack(spacing: 0) {
                                ForEach(filteredLanguages) { language in
                                    LanguageRow(
                                        language: language,
                                        isSelected: selectedLanguage == language.id
                                    ) {
                                        withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                                            selectedLanguage = language.id
                                            UIImpactFeedbackGenerator(style: .medium).impactOccurred()
                                        }
                                    }
                                    
                                    if language.id != filteredLanguages.last?.id {
                                        Divider()
                                            .padding(.leading, 56)
                                    }
                                }
                            }
                            .background(Color.surface)
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom, 30)
                }
            }
        }
        .navigationTitle("Language")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private var searchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.textTertiary)
            
            TextField("Search languages...", text: $searchText)
                .font(.subheadline)
            
            if !searchText.isEmpty {
                Button {
                    searchText = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.textTertiary)
                }
            }
        }
        .padding(12)
        .background(Color.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(Color.brandBorder.opacity(0.5), lineWidth: 1)
        )
    }
    
    private var currentSelectionCard: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color.brandPrimary.opacity(0.1))
                    .frame(width: 48, height: 48)
                
                Text(languages.first(where: { $0.id == selectedLanguage })?.flag ?? "🌐")
                    .font(.title2)
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text("App Language")
                    .font(.caption2.bold())
                    .foregroundColor(.brandPrimary)
                
                Text(languages.first(where: { $0.id == selectedLanguage })?.name ?? "Default")
                    .font(.headline)
                    .foregroundColor(.textPrimary)
            }
            
            Spacer()
            
            Image(systemName: "checkmark.seal.fill")
                .foregroundColor(.brandPrimary)
                .font(.title3)
        }
        .padding()
        .background(Color.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.brandPrimary.opacity(0.2), lineWidth: 1)
        )
    }
}

struct LanguageRow: View {
    let language: Language
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Text(language.flag)
                    .font(.title3)
                    .frame(width: 24)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(language.name)
                        .font(.subheadline.bold())
                        .foregroundColor(isSelected ? .brandPrimary : .textPrimary)
                    
                    Text(language.nativeName)
                        .font(.caption)
                        .foregroundColor(.textSecondary)
                }
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.brandPrimary)
                        .font(.body.bold())
                        .transition(.scale.combined(with: .opacity))
                }
            }
            .padding()
            .contentShape(Rectangle())
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct Language: Identifiable {
    let id: String
    let name: String
    let nativeName: String
    let flag: String
}

#Preview {
    NavigationStack {
        LanguageSettingsView()
    }
}
