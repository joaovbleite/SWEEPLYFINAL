//
//  AIChatView.swift
//  SWEEPLYPRO
//
//  Created on 7/10/25.
//

import SwiftUI
import UIKit

// OpenAI API client
class OpenAIService {
    // API key should be stored securely in a configuration file or environment variable
    // For development purposes, enter your API key in the Settings screen of the app
    private var apiKey: String {
        // In a real app, this would be retrieved from secure storage
        return UserDefaults.standard.string(forKey: "openai_api_key") ?? ""
    }
    private let urlString = "https://api.openai.com/v1/chat/completions"
    
    // Check if API key is set and valid
    func isApiKeyValid() -> Bool {
        let key = apiKey.trimmingCharacters(in: .whitespacesAndNewlines)
        return !key.isEmpty && key.hasPrefix("sk-")
    }
    
    // Set API key (to be called from settings)
    static func setApiKey(_ key: String) {
        UserDefaults.standard.set(key, forKey: "openai_api_key")
    }
    
    func sendMessage(messages: [ChatMessage], completion: @escaping (Result<String, Error>) -> Void) {
        // Check if API key is valid
        if !isApiKeyValid() {
            completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "API key is missing or invalid. Please set a valid API key in the Settings."])))
            return
        }
        
        // Convert our ChatMessage objects to the format OpenAI expects
        var openAIMessages = [
            ["role": "system", "content": "You are a helpful assistant for a cleaning business app called Sweeply. You help users with scheduling, client management, invoicing, and business growth tips. Keep responses concise and focused on cleaning business needs. When answering pricing questions, provide specific price ranges (e.g. $25-$35) and clearly state the pricing unit (per hour, per room, per job, etc.). List 3-4 key factors that affect pricing as short bullet points, not paragraphs. Include a brief note about local market adjustments."]
        ]
        
        // Add user messages and AI responses
        for message in messages {
            let role = message.isUser ? "user" : "assistant"
            openAIMessages.append(["role": role, "content": message.content])
        }
        
        // Prepare the request body
        let requestBody: [String: Any] = [
            "model": "gpt-4o-mini", // Using a more widely available model
            "messages": openAIMessages,
            "temperature": 0.7,
            "max_tokens": 800
        ]
        
        // Create the request
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        // Ensure API key is properly formatted with Bearer prefix
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.timeoutInterval = 30
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        } catch {
            completion(.failure(error))
            return
        }
        
        // Make the API call
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
                return
            }
            
            do {
                if let httpResponse = response as? HTTPURLResponse {
                    print("API Response Status Code: \(httpResponse.statusCode)")
                    
                    // Log response data for debugging
                    if let responseString = String(data: data, encoding: .utf8) {
                        print("API Response: \(responseString)")
                    }
                    
                    // Check for HTTP error codes
                    if httpResponse.statusCode != 200 {
                        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                           let error = json["error"] as? [String: Any],
                           let message = error["message"] as? String {
                            completion(.failure(NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: \(message)"])))
                        } else {
                            completion(.failure(NSError(domain: "OpenAIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: HTTP \(httpResponse.statusCode)"])))
                        }
                        return
                    }
                }
                
                if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]],
                   let firstChoice = choices.first,
                   let message = firstChoice["message"] as? [String: Any],
                   let content = message["content"] as? String {
                    completion(.success(content))
                } else {
                    // Try to get error message
                    if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let error = json["error"] as? [String: Any],
                       let message = error["message"] as? String {
                        completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "API Error: \(message)"])))
                    } else {
                        completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response from OpenAI API"])))
                    }
                }
            } catch {
                print("JSON Parsing Error: \(error.localizedDescription)")
                completion(.failure(NSError(domain: "OpenAIService", code: 0, userInfo: [NSLocalizedDescriptionKey: "Error parsing API response: \(error.localizedDescription)"])))
            }
        }.resume()
    }
}

// Chat models
struct ChatMessage: Identifiable, Codable {
    let id: UUID
    let content: String
    let isUser: Bool
    let timestamp: Date
    let isVerifiedAI: Bool // Whether this is a verified AI response from OpenAI
    let messageType: MessageType // Type of message for special formatting
    
    // Initialize with default values
    init(content: String, isUser: Bool, timestamp: Date, isVerifiedAI: Bool = false, messageType: MessageType = .regular) {
        self.id = UUID()
        self.content = content
        self.isUser = isUser
        self.timestamp = timestamp
        self.isVerifiedAI = isVerifiedAI
        self.messageType = messageType
    }
    
    // Message types
    enum MessageType: String, Codable {
        case regular
        case pricingRecommendation
        case nextJobWidget
    }
}

struct ChatConversation: Identifiable, Codable {
    let id: UUID
    var title: String
    var messages: [ChatMessage]
    let createdAt: Date
    var updatedAt: Date
    
    init(title: String, messages: [ChatMessage], id: UUID = UUID(), createdAt: Date = Date(), updatedAt: Date = Date()) {
        self.id = id
        self.title = title
        self.messages = messages
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
}

// Chat history manager
class ChatHistoryManager {
    static let shared = ChatHistoryManager()
    
    private let userDefaults = UserDefaults.standard
    private let conversationsKey = "sweeply_chat_conversations"
    
    private init() {}
    
    // Load all conversations
    func loadConversations() -> [ChatConversation] {
        guard let data = userDefaults.data(forKey: conversationsKey) else {
            return []
        }
        
        do {
            let conversations = try JSONDecoder().decode([ChatConversation].self, from: data)
            return conversations
        } catch {
            print("Error loading conversations: \(error)")
            return []
        }
    }
    
    // Save all conversations
    func saveConversations(_ conversations: [ChatConversation]) {
        do {
            let data = try JSONEncoder().encode(conversations)
            userDefaults.set(data, forKey: conversationsKey)
        } catch {
            print("Error saving conversations: \(error)")
        }
    }
    
    // Save a single conversation
    func saveConversation(_ conversation: ChatConversation) {
        var conversations = loadConversations()
        
        // Update existing or add new
        if let index = conversations.firstIndex(where: { $0.id == conversation.id }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
        
        saveConversations(conversations)
    }
    
    // Delete a conversation
    func deleteConversation(withId id: UUID) {
        var conversations = loadConversations()
        conversations.removeAll { $0.id == id }
        saveConversations(conversations)
    }
    
    // Generate a title from the first user message
    func generateTitle(from messages: [ChatMessage]) -> String {
        if let firstUserMessage = messages.first(where: { $0.isUser }) {
            let content = firstUserMessage.content
            let maxLength = 30
            
            if content.count <= maxLength {
                return content
            } else {
                return content.prefix(maxLength) + "..."
            }
        }
        
        return "New Conversation"
    }
}

// Date formatter extension
extension Date {
    func timeAgo() -> String {
        let calendar = Calendar.current
        let now = Date()
        let components = calendar.dateComponents([.minute, .hour, .day, .weekOfYear, .month, .year], from: self, to: now)
        
        if let year = components.year, year >= 1 {
            return year == 1 ? "1 year ago" : "\(year) years ago"
        }
        
        if let month = components.month, month >= 1 {
            return month == 1 ? "1 month ago" : "\(month) months ago"
        }
        
        if let week = components.weekOfYear, week >= 1 {
            return week == 1 ? "1 week ago" : "\(week) weeks ago"
        }
        
        if let day = components.day, day >= 1 {
            return day == 1 ? "Yesterday" : "\(day) days ago"
        }
        
        if let hour = components.hour, hour >= 1 {
            return hour == 1 ? "1 hour ago" : "\(hour) hours ago"
        }
        
        if let minute = components.minute, minute >= 1 {
            return minute == 1 ? "1 minute ago" : "\(minute) minutes ago"
        }
        
        return "Just now"
    }
}

struct AIChatView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var messageText = ""
    @State private var messages: [ChatMessage] = []
    @State private var isTyping = false
    @FocusState private var isFocused: Bool
    @State private var showAttachmentMenu = false
    @State private var showChatHistory = false
    @State private var errorMessage: String? = nil
    @State private var showError = false
    @State private var conversations: [ChatConversation] = []
    @State private var currentConversationId: UUID? = nil
    
    // OpenAI service
    private let openAIService = OpenAIService()
    
    // Create a constant UUID for the typing indicator
    private let typingIndicatorID = UUID()
    
    // App colors
    private let primaryColor = Color(hex: "#246BFD") // Blue
    private let backgroundColor = Color(hex: "#F5F5F5") // Light grey
    private let textColor = Color(hex: "#1A1A1A") // Dark text
    private let secondaryTextColor = Color(hex: "#5E7380") // Grey text
    private let userBubbleColor = Color(hex: "#246BFD") // Blue for user messages
    private let aiBubbleColor = Color.white // White for AI messages
    private let borderColor = Color(hex: "#E5E5E5") // Light grey border
    
    // Welcome message
    private let welcomeMessage = "Hi there! I'm your Sweeply Assistant. How can I help you with your cleaning business today?"
    
    // Function to dismiss the keyboard
    private func dismissKeyboard() {
        isFocused = false
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header
            headerView
            
            // Messages
            ScrollViewReader { scrollView in
                ScrollView {
                    LazyVStack(spacing: 16) {
                        // Welcome message
                        if messages.isEmpty {
                            welcomeMessageView
                        }
                        
                        // Chat messages
                        ForEach(messages) { message in
                            chatBubble(for: message)
                        }
                        
                        // "AI is typing" indicator
                        if isTyping {
                            typingIndicator
                                .id(typingIndicatorID)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    .padding(.bottom, 8)
                    .contentShape(Rectangle()) // Make the entire content area tappable
                    .onTapGesture {
                        dismissKeyboard()
                    }
                }
                .onChange(of: messages.count) { oldValue, newValue in
                    withAnimation {
                        if let lastID = messages.last?.id {
                            scrollView.scrollTo(lastID, anchor: .bottom)
                        } else if isTyping {
                            scrollView.scrollTo(typingIndicatorID, anchor: .bottom)
                        }
                    }
                    
                    // Save conversation when messages change
                    saveCurrentConversation()
                }
                .onChange(of: isTyping) { oldValue, newValue in
                    withAnimation {
                        if isTyping {
                            scrollView.scrollTo(typingIndicatorID, anchor: .bottom)
                        }
                    }
                }
            }
            .simultaneousGesture(
                TapGesture().onEnded { _ in
                    dismissKeyboard()
                }
            )
            
            // Input area
            messageInputView
        }
        .background(backgroundColor)
        .onTapGesture {
            dismissKeyboard()
        }
        .onAppear {
            // Load conversations
            conversations = ChatHistoryManager.shared.loadConversations()
            
            // Create a new conversation if needed
            if currentConversationId == nil {
                startNewConversation()
            }
            
            // Check if API key needs to be set
            if UserDefaults.standard.string(forKey: "openai_api_key") == nil {
                // Show an alert or navigate to settings to prompt the user to enter their API key
                errorMessage = "Please set your OpenAI API key in the Settings"
                showError = true
            }
            
            // Add welcome message when view appears
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                if messages.isEmpty {
                    addAIMessage(welcomeMessage)
                }
            }
        }
        .toolbar {
            // Add "Done" button above keyboard
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                
                Button("Done") {
                    dismissKeyboard()
                }
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(primaryColor)
            }
        }
        .sheet(isPresented: $showChatHistory) {
            chatHistoryView
        }
        .alert("Error", isPresented: $showError, actions: {
            Button("OK", role: .cancel) {}
        }, message: {
            Text(errorMessage ?? "An unknown error occurred.")
        })
    }
    
    // MARK: - Chat History View
    private var chatHistoryView: some View {
        NavigationView {
            VStack {
                if conversations.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "bubble.left.and.bubble.right")
                            .font(.system(size: 60))
                            .foregroundColor(secondaryTextColor.opacity(0.5))
                        
                        Text("No conversations yet")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(textColor)
                        
                        Text("Your chat history will appear here")
                            .font(.system(size: 16))
                            .foregroundColor(secondaryTextColor)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        Section(header: Text("Recent Conversations")) {
                            ForEach(conversations.sorted(by: { $0.updatedAt > $1.updatedAt })) { conversation in
                                Button(action: {
                                    loadConversation(conversation)
                                    showChatHistory = false
                                }) {
                                    HStack {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(conversation.title)
                                                .font(.system(size: 16, weight: .medium))
                                                .foregroundColor(textColor)
                                                .lineLimit(1)
                                            
                                            Text(conversation.updatedAt.timeAgo())
                                                .font(.system(size: 14))
                                                .foregroundColor(secondaryTextColor)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .font(.system(size: 14))
                                            .foregroundColor(secondaryTextColor)
                                    }
                                }
                                .padding(.vertical, 8)
                                .swipeActions {
                                    Button(role: .destructive) {
                                        deleteConversation(conversation)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                            }
                        }
                    }
                }
                
                Button(action: {
                    startNewConversation()
                    showChatHistory = false
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .font(.system(size: 18))
                        
                        Text("New Conversation")
                            .font(.system(size: 16, weight: .medium))
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(primaryColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                    .padding()
                }
            }
            .navigationTitle("Chat History")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        showChatHistory = false
                    }
                }
            }
        }
    }
    
    // MARK: - Header View
    private var headerView: some View {
        HStack {
            Button(action: {
                dismiss()
            }) {
                Image(systemName: "xmark")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
            
            Spacer()
            
            Text("Sweeply Assistant")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(textColor)
            
            Spacer()
            
            // History button
            Button(action: {
                showChatHistory = true
            }) {
                Image(systemName: "clock.arrow.circlepath")
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(textColor)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .background(Color.white)
        .shadow(color: Color.black.opacity(0.05), radius: 3, x: 0, y: 2)
    }
    
    // MARK: - Welcome Message View
    private var welcomeMessageView: some View {
        HStack(alignment: .top) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 32, height: 32)
                
                Text("AI")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Message bubble
            VStack(alignment: .leading, spacing: 4) {
                Text("Sweeply Assistant")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(welcomeMessage)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(aiBubbleColor)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 1)
                    )
            }
            
            Spacer()
        }
    }
    
    // MARK: - Chat Bubble
    private func chatBubble(for message: ChatMessage) -> AnyView {
        if message.isUser {
            return AnyView(userMessageBubble(for: message))
        } else if message.messageType == .pricingRecommendation {
            return AnyView(pricingRecommendationBubble(for: message))
        } else if message.messageType == .nextJobWidget {
            return AnyView(nextJobWidgetBubble(for: message))
        } else {
            return AnyView(aiMessageBubble(for: message))
        }
    }

    private func userMessageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top) {
            Spacer()
            
            // User message
            VStack(alignment: .trailing, spacing: 4) {
                Text("You")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(textColor)
                
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(userBubbleColor)
                    .cornerRadius(16)
            }
            .padding(.leading, 60)
        }
        .id(message.id)
    }

    private func aiMessageBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 32, height: 32)
                
                Text("AI")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // AI message
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Sweeply Assistant")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                    
                    // Verification badge for real AI responses
                    if message.isVerifiedAI {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(primaryColor)
                            .help("Verified OpenAI Response")
                    }
                }
                
                Text(message.content)
                    .font(.system(size: 16))
                    .foregroundColor(textColor)
                    .padding(.vertical, 10)
                    .padding(.horizontal, 12)
                    .background(aiBubbleColor)
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(borderColor, lineWidth: 1)
                    )
            }
            
            Spacer()
        }
        .id(message.id)
    }

    private func pricingRecommendationBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 32, height: 32)
                
                Text("AI")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Parse the pricing content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Sweeply Assistant")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                    
                    // Verification badge for real AI responses
                    if message.isVerifiedAI {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(primaryColor)
                            .help("Verified OpenAI Response")
                    }
                }
                
                // Pricing recommendation widget
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text("Pricing Recommendation")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(textColor)
                    
                    // Extract pricing details from the message content
                    if let pricingData = parsePricingData(from: message.content) {
                        // Price range
                        HStack(spacing: 16) {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Recommended Price")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                Text(pricingData.priceRange)
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Per")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                Text(pricingData.pricingUnit)
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(textColor)
                            }
                        }
                        .padding(.vertical, 8)
                        
                        // Factors
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Key Factors")
                                .font(.system(size: 14, weight: .medium))
                                .foregroundColor(secondaryTextColor)
                            
                            // Improved factors display with grid layout
                            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 12) {
                                ForEach(pricingData.factors, id: \.self) { factor in
                                    HStack(alignment: .center, spacing: 6) {
                                        // Choose appropriate icon based on factor content
                                        Image(systemName: iconForFactor(factor))
                                            .font(.system(size: 14))
                                            .foregroundColor(primaryColor)
                                            .frame(width: 16)
                                        
                                        Text(factor)
                                            .font(.system(size: 14))
                                            .foregroundColor(textColor)
                                            .lineLimit(1)
                                    }
                                    .padding(.vertical, 4)
                                    .padding(.horizontal, 8)
                                    .background(Color(hex: "#F5F8FF"))
                                    .cornerRadius(6)
                                }
                            }
                        }
                        
                        // Notes
                        if !pricingData.notes.isEmpty {
                            Text(pricingData.notes)
                                .font(.system(size: 14, weight: .regular))
                                .foregroundColor(secondaryTextColor)
                                .padding(.top, 8)
                        }
                    } else {
                        // Fallback if parsing fails
                        Text(message.content)
                            .font(.system(size: 16))
                            .foregroundColor(textColor)
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(aiBubbleColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .id(message.id)
    }

    // Next Job Widget Bubble
    private func nextJobWidgetBubble(for message: ChatMessage) -> some View {
        HStack(alignment: .top) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 32, height: 32)
                
                Text("AI")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Next Job Widget content
            VStack(alignment: .leading, spacing: 4) {
                HStack(spacing: 4) {
                    Text("Sweeply Assistant")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(textColor)
                    
                    // Verification badge for real AI responses
                    if message.isVerifiedAI {
                        Image(systemName: "checkmark.seal.fill")
                            .font(.system(size: 12))
                            .foregroundColor(primaryColor)
                            .help("Verified OpenAI Response")
                    }
                }
                
                // Next Job widget
                VStack(alignment: .leading, spacing: 12) {
                    // Title
                    Text("Your Next Appointment")
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(textColor)
                    
                    // Mock job data
                    VStack(spacing: 16) {
                        // Client info
                        HStack(spacing: 16) {
                            // Time info
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Today")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                Text("2:30 PM")
                                    .font(.system(size: 20, weight: .bold))
                                    .foregroundColor(primaryColor)
                            }
                            
                            Divider()
                                .frame(height: 40)
                            
                            // Client name
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Client")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                HStack {
                                    Text("Johnson Residence")
                                        .font(.system(size: 16, weight: .semibold))
                                        .foregroundColor(textColor)
                                    
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 12))
                                        .foregroundColor(Color(hex: "#FFB800"))  // Gold star for repeat client
                                }
                            }
                            
                            Spacer()
                            
                            // Total amount
                            VStack(alignment: .trailing, spacing: 4) {
                                Text("Total")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(secondaryTextColor)
                                
                                Text("125.00")
                                    .font(.system(size: 18, weight: .bold))
                                    .foregroundColor(Color(hex: "#4CAF50"))  // Green color for price
                            }
                        }
                        .padding(.vertical, 8)
                        
                        Divider()
                        
                        // Job details
                        VStack(alignment: .leading, spacing: 12) {
                            // Location
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "location.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(primaryColor)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Location")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(secondaryTextColor)
                                    
                                    Text("123 Maple Street, Springfield")
                                        .font(.system(size: 15))
                                        .foregroundColor(textColor)
                                }
                            }
                            
                            // Service type
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "spray.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(primaryColor)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Service")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(secondaryTextColor)
                                    
                                    HStack {
                                        Text("Deep Cleaning")
                                            .font(.system(size: 15))
                                            .foregroundColor(textColor)
                                        
                                        Spacer()
                                        
                                        Text("125.00")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(hex: "#4CAF50"))  // Green color for price
                                    }
                                }
                            }
                            
                            // Duration
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "clock.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(primaryColor)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Duration")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(secondaryTextColor)
                                    
                                    Text("3 hours (2:30 PM - 5:30 PM)")
                                        .font(.system(size: 15))
                                        .foregroundColor(textColor)
                                }
                            }
                            
                            // Payment information
                            HStack(alignment: .top, spacing: 12) {
                                Image(systemName: "dollarsign.circle.fill")
                                    .font(.system(size: 16))
                                    .foregroundColor(primaryColor)
                                    .frame(width: 20)
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Payment")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(secondaryTextColor)
                                    
                                    HStack {
                                        Text("Credit Card")
                                            .font(.system(size: 15))
                                            .foregroundColor(textColor)
                                        
                                        Spacer()
                                        
                                        Text("$125.00")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(Color(hex: "#4CAF50"))  // Green color for price
                                    }
                                }
                            }
                        }
                        
                        // Action buttons
                        HStack(spacing: 12) {
                            Button(action: {
                                // Navigate to job details
                            }) {
                                Text("View Details")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(primaryColor)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(primaryColor, lineWidth: 1)
                                    )
                            }
                            
                            Button(action: {
                                // Navigate to maps
                            }) {
                                Text("Get Directions")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(.white)
                                    .padding(.vertical, 8)
                                    .padding(.horizontal, 16)
                                    .background(primaryColor)
                                    .cornerRadius(8)
                            }
                        }
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 14)
                .background(aiBubbleColor)
                .cornerRadius(16)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 1)
                )
            }
            
            Spacer()
        }
        .id(message.id)
    }

    // Pricing data structure
    struct PricingData {
        let priceRange: String
        let pricingUnit: String
        let factors: [String]
        let notes: String
    }

    // Parse pricing data from AI response
    private func parsePricingData(from content: String) -> PricingData? {
        // Extract price range using regex
        var priceRange: String = "$75-$150"  // Default value
        
        if let priceMatch = content.range(of: "\\$\\d+(?:\\.\\d+)?(?:\\s*-\\s*\\$\\d+(?:\\.\\d+)?)?", options: .regularExpression) {
            priceRange = String(content[priceMatch])
        } else if let priceMatch = content.range(of: "\\d+(?:\\.\\d+)?(?:\\s*-\\s*\\d+(?:\\.\\d+)?)?\\s*dollars", options: .regularExpression) {
            let price = String(content[priceMatch])
            priceRange = price.replacingOccurrences(of: "dollars", with: "").trimmingCharacters(in: .whitespaces)
            if !priceRange.contains("$") {
                priceRange = "$" + priceRange
            }
        }
        
        // Extract pricing unit
        let pricingUnit: String
        if content.contains("per hour") || content.contains("hourly") || content.contains("per hr") {
            pricingUnit = "Hour"
        } else if content.contains("per room") {
            pricingUnit = "Room"
        } else if content.contains("per square foot") || content.contains("per sq ft") || content.contains("per sq. ft.") {
            pricingUnit = "Sq. Ft."
        } else if content.contains("per job") || content.contains("flat rate") || content.contains("per service") {
            pricingUnit = "Job"
        } else {
            pricingUnit = "Service"
        }
        
        // Extract factors - look for bullet points, numbered lists, or key phrases
        var factors: [String] = []
        
        // First try to find bullet points or numbered lists
        let factorPatterns = ["•\\s*([^\\n•]+)", "\\d+\\.\\s*([^\\n]+)", "-\\s*([^\\n]+)", "\\*\\s*([^\\n]+)"]
        
        for pattern in factorPatterns {
            let regex = try? NSRegularExpression(pattern: pattern, options: [])
            let nsString = content as NSString
            let matches = regex?.matches(in: content, options: [], range: NSRange(location: 0, length: nsString.length)) ?? []
            
            for match in matches {
                if match.numberOfRanges > 1 {
                    let factorRange = match.range(at: 1)
                    var factor = nsString.substring(with: factorRange).trimmingCharacters(in: .whitespacesAndNewlines)
                    
                    // Limit factor length and add ellipsis if needed
                    if factor.count > 40 {
                        let index = factor.index(factor.startIndex, offsetBy: 37)
                        factor = String(factor[..<index]) + "..."
                    }
                    
                    factors.append(factor)
                }
            }
            
            if !factors.isEmpty {
                break
            }
        }
        
        // If no factors found, look for key phrases
        if factors.isEmpty {
            let keyPhrases = [
                "size": ["size", "square footage", "sq ft", "property size", "home size"],
                "frequency": ["frequency", "regular", "recurring", "weekly", "biweekly", "monthly"],
                "type": ["type of cleaning", "cleaning type", "deep clean", "standard clean", "basic clean"],
                "location": ["location", "area", "region", "market", "city"],
                "supplies": ["supplies", "equipment", "materials", "products"]
            ]
            
            for (category, phrases) in keyPhrases {
                for phrase in phrases {
                    if content.lowercased().contains(phrase) {
                        switch category {
                        case "size":
                            factors.append("Property size")
                        case "frequency":
                            factors.append("Cleaning frequency")
                        case "type":
                            factors.append("Service type")
                        case "location":
                            factors.append("Location")
                        case "supplies":
                            factors.append("Supplies included")
                        default:
                            break
                        }
                        break
                    }
                }
            }
            
            // Add default factors if still empty
            if factors.isEmpty {
                factors = ["Property size", "Cleaning type", "Location", "Service frequency"]
            }
        }
        
        // Limit to 4 factors maximum
        if factors.count > 4 {
            factors = Array(factors.prefix(4))
        }
        
        // Extract a note (anything after "Note:" or similar)
        let notes: String
        if let noteMatch = content.range(of: "(?:Note|Remember|Consider|Tip|Important):[^\\n]+", options: .regularExpression) {
            notes = String(content[noteMatch])
        } else {
            notes = "Adjust pricing based on your local market and specific job requirements."
        }
        
        return PricingData(
            priceRange: priceRange,
            pricingUnit: pricingUnit,
            factors: factors,
            notes: notes
        )
    }
    
    // Helper function to select appropriate icon for each factor
    private func iconForFactor(_ factor: String) -> String {
        let lowercasedFactor = factor.lowercased()
        
        if lowercasedFactor.contains("size") || lowercasedFactor.contains("square") || lowercasedFactor.contains("property") {
            return "ruler"
        } else if lowercasedFactor.contains("frequency") || lowercasedFactor.contains("regular") || lowercasedFactor.contains("recurring") {
            return "calendar"
        } else if lowercasedFactor.contains("type") || lowercasedFactor.contains("clean") || lowercasedFactor.contains("service") {
            return "sparkles"
        } else if lowercasedFactor.contains("location") || lowercasedFactor.contains("area") || lowercasedFactor.contains("region") {
            return "mappin.and.ellipse"
        } else if lowercasedFactor.contains("supplies") || lowercasedFactor.contains("equipment") || lowercasedFactor.contains("materials") {
            return "spray.fill"
        } else if lowercasedFactor.contains("time") || lowercasedFactor.contains("hour") || lowercasedFactor.contains("duration") {
            return "clock"
        } else if lowercasedFactor.contains("staff") || lowercasedFactor.contains("person") || lowercasedFactor.contains("team") {
            return "person.2"
        } else if lowercasedFactor.contains("experience") || lowercasedFactor.contains("skill") {
            return "star"
        } else {
            return "checkmark.circle"
        }
    }
    
    // MARK: - Typing Indicator
    private var typingIndicator: some View {
        HStack(alignment: .top) {
            // AI avatar
            ZStack {
                Circle()
                    .fill(primaryColor)
                    .frame(width: 32, height: 32)
                
                Text("AI")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
            }
            
            // Typing bubble
            HStack(spacing: 4) {
                ForEach(0..<3) { index in
                    Circle()
                        .fill(secondaryTextColor)
                        .frame(width: 8, height: 8)
                        .opacity(0.7)
                        .scaleEffect(1 + 0.3 * sin(Double(index) * 0.5 + Date().timeIntervalSince1970 * 3))
                        .animation(Animation.easeInOut(duration: 0.5).repeatForever(autoreverses: true), value: Date().timeIntervalSince1970)
                }
            }
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(aiBubbleColor)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(borderColor, lineWidth: 1)
            )
            
            Spacer()
        }
    }
    
    // MARK: - Message Input View
    private var messageInputView: some View {
        VStack(spacing: 0) {
            Divider()
            
            HStack(spacing: 12) {
                // Add attachment button
                Button(action: {
                    showAttachmentMenu = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(primaryColor)
                }
                .confirmationDialog("Add to message", isPresented: $showAttachmentMenu, titleVisibility: .visible) {
                    Button("Take Photo") {
                        // Handle taking photo
                    }
                    
                    Button("Choose Image") {
                        // Handle choosing image
                    }
                    
                    Button("Attach File") {
                        // Handle attaching file
                    }
                    
                    Button("Cancel", role: .cancel) {}
                }
                
                // Text field
                ZStack(alignment: .trailing) {
                    TextField("Type a message...", text: $messageText, axis: .vertical)
                        .font(.system(size: 16))
                        .padding(.vertical, 10)
                        .padding(.horizontal, 12)
                        .background(Color.white)
                        .cornerRadius(20)
                        .overlay(
                            RoundedRectangle(cornerRadius: 20)
                                .stroke(borderColor, lineWidth: 1)
                        )
                        .focused($isFocused)
                        .lineLimit(1...5)
                }
                
                // Send button
                Button(action: sendMessage) {
                    Image(systemName: "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundColor(messageText.isEmpty ? secondaryTextColor : primaryColor)
                }
                .disabled(messageText.isEmpty)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.white)
        }
    }
    
    // MARK: - Conversation Management
    private func startNewConversation() {
        messages = []
        currentConversationId = UUID()
    }
    
    private func saveCurrentConversation() {
        guard !messages.isEmpty, let id = currentConversationId else { return }
        
        let title = ChatHistoryManager.shared.generateTitle(from: messages)
        let conversation = ChatConversation(
            title: title,
            messages: messages,
            id: id,
            createdAt: conversations.first(where: { $0.id == id })?.createdAt ?? Date(),
            updatedAt: Date()
        )
        
        ChatHistoryManager.shared.saveConversation(conversation)
        
        // Update local conversations array
        if let index = conversations.firstIndex(where: { $0.id == id }) {
            conversations[index] = conversation
        } else {
            conversations.append(conversation)
        }
    }
    
    private func loadConversation(_ conversation: ChatConversation) {
        messages = conversation.messages
        currentConversationId = conversation.id
    }
    
    private func deleteConversation(_ conversation: ChatConversation) {
        ChatHistoryManager.shared.deleteConversation(withId: conversation.id)
        conversations.removeAll { $0.id == conversation.id }
        
        // If we deleted the current conversation, start a new one
        if conversation.id == currentConversationId {
            startNewConversation()
        }
    }
    
    // MARK: - Helper Methods
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        
        // Add user message
        let userMessage = ChatMessage(content: messageText, isUser: true, timestamp: Date())
        messages.append(userMessage)
        
        // Clear input field
        let userText = messageText
        messageText = ""
        
        // Check if this is a pricing question or next job question
        let isPricingQuestion = checkIfPricingQuestion(userText)
        let isNextJobQuestion = checkIfNextJobQuestion(userText)
        
        // If it's a next job question, show the next job widget immediately
        if isNextJobQuestion {
            // Add a brief text response
            addAIMessage("Here's your next scheduled appointment:", isVerifiedAI: true)
            
            // Add the next job widget
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                addAIMessage("Next job details", isVerifiedAI: true, messageType: .nextJobWidget)
            }
            return
        }
        
        // Show typing indicator
        isTyping = true
        
        // Call OpenAI API
        openAIService.sendMessage(messages: messages) { result in
            DispatchQueue.main.async {
                isTyping = false
                
                switch result {
                case .success(let response):
                    if isPricingQuestion {
                        // Create a pricing recommendation message
                        addAIMessage(response, isVerifiedAI: true, messageType: .pricingRecommendation)
                    } else {
                        // Regular message
                        addAIMessage(response, isVerifiedAI: true)
                    }
                case .failure(let error):
                    // Display detailed error for debugging
                    errorMessage = "Error: \(error.localizedDescription)"
                    showError = true
                    print("OpenAI API Error: \(error.localizedDescription)")
                    
                    // Add a user-friendly message
                    if error.localizedDescription.contains("API key") {
                        addAIMessage("I'm having trouble with my API connection. The API key might be incorrect or expired. Please contact support for assistance.")
                    } else {
                        addAIMessage("I'm having trouble connecting to my servers. Please try again later.")
                    }
                }
            }
        }
    }

    // Check if the message is asking about pricing
    private func checkIfPricingQuestion(_ message: String) -> Bool {
        let lowercasedMessage = message.lowercased()
        
        // Keywords related to pricing questions
        let pricingKeywords = [
            "how much should i charge", "pricing", "price", "charge", "cost", "rate", "fee",
            "how much for", "what to charge", "what should i charge", "fair price",
            "pricing guide", "price range", "hourly rate", "estimate", "quote", 
            "what does it cost", "how much does", "how much is", "what is the price",
            "pricing strategy", "pricing model", "competitive pricing", "market rate",
            "affordable price", "premium price", "budget friendly", "calculate price",
            "pricing calculator", "pricing formula", "average cost", "typical price"
        ]
        
        // Check if any pricing keyword is in the message
        for keyword in pricingKeywords {
            if lowercasedMessage.contains(keyword) {
                return true
            }
        }
        
        // Check for pricing-related questions
        let pricingPhrases = [
            "what should i", "how do i", "help me", "can you help", "need advice"
        ]
        
        let pricingContexts = [
            "cleaning", "house cleaning", "office cleaning", "residential", "commercial",
            "deep clean", "regular clean", "move out", "move in"
        ]
        
        // Check for combinations of phrases and contexts
        for phrase in pricingPhrases {
            if lowercasedMessage.contains(phrase) {
                for context in pricingContexts {
                    if lowercasedMessage.contains(context) && 
                       (lowercasedMessage.contains("price") || 
                        lowercasedMessage.contains("cost") || 
                        lowercasedMessage.contains("charge") ||
                        lowercasedMessage.contains("rate")) {
                        return true
                    }
                }
            }
        }
        
        return false
    }
    
    // Check if the message is asking about next job or client
    private func checkIfNextJobQuestion(_ message: String) -> Bool {
        let lowercasedMessage = message.lowercased()
        
        // Keywords related to next job questions
        let nextJobKeywords = [
            "next client", "next job", "next appointment", "next scheduled", "upcoming job",
            "upcoming client", "upcoming appointment", "next on schedule", "who is next",
            "what's my next", "what is my next", "when is my next", "today's schedule",
            "who do i have next", "what job is next"
        ]
        
        // Check if any next job keyword is in the message
        for keyword in nextJobKeywords {
            if lowercasedMessage.contains(keyword) {
                return true
            }
        }
        
        return false
    }

    private func addAIMessage(_ text: String, isVerifiedAI: Bool = false, messageType: ChatMessage.MessageType = .regular) {
        let aiMessage = ChatMessage(content: text, isUser: false, timestamp: Date(), isVerifiedAI: isVerifiedAI, messageType: messageType)
        messages.append(aiMessage)
    }
}

#Preview {
    AIChatView()
} 