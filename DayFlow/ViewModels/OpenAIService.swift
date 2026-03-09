import Foundation

struct ParsedTask: Codable {
    var title: String
    var startHour: Int
    var startMinute: Int
    var durationMinutes: Int
    var emoji: String
    var category: String
}

enum OpenAIError: Error {
    case missingAPIKey
    case invalidResponse
    case parseError(String)
}

struct OpenAIService {
    // Store your API key in the app's Info.plist under "OPENAI_API_KEY"
    // or replace with a direct string for development.
    static var apiKey: String {
        Bundle.main.infoDictionary?["OPENAI_API_KEY"] as? String ?? ""
    }

    static func parseVoiceTask(_ transcript: String) async throws -> ParsedTask {
        guard !apiKey.isEmpty else { throw OpenAIError.missingAPIKey }

        let prompt = """
        Extract task details from this voice input: "\(transcript)"
        Return ONLY valid JSON with these exact fields:
        {
          "title": string,
          "startHour": integer 0-23,
          "startMinute": integer 0 or 30,
          "durationMinutes": integer (15/30/45/60/90/120),
          "emoji": single emoji character,
          "category": one of "work"/"health"/"personal"/"other"
        }
        If no time mentioned, use startHour: 9, startMinute: 0.
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "max_tokens": 150,
            "messages": [
                ["role": "system", "content": "You are a task parser. Return only valid JSON, no markdown."],
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { var content: String }
                var message: Message
            }
            var choices: [Choice]
        }

        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = response.choices.first?.message.content,
              let jsonData = content.data(using: .utf8) else {
            throw OpenAIError.invalidResponse
        }

        return try JSONDecoder().decode(ParsedTask.self, from: jsonData)
    }

    static func prioritizeTasks(_ tasks: [DFTask]) async throws -> [DFTask] {
        guard !apiKey.isEmpty else { return tasks }

        let taskList = tasks.enumerated().map { "\($0.offset): \($0.element.title) (\($0.element.category.rawValue))" }.joined(separator: "\n")
        let prompt = """
        Given these tasks, return a JSON array of indices sorted by priority (most urgent/important first):
        \(taskList)
        Return only a JSON array of integers like [2, 0, 1, 3]
        """

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "max_tokens": 100,
            "messages": [
                ["role": "system", "content": "Return only valid JSON."],
                ["role": "user", "content": prompt]
            ]
        ]

        var request = URLRequest(url: URL(string: "https://api.openai.com/v1/chat/completions")!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)

        struct ChatResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable { var content: String }
                var message: Message
            }
            var choices: [Choice]
        }

        let response = try JSONDecoder().decode(ChatResponse.self, from: data)
        guard let content = response.choices.first?.message.content,
              let jsonData = content.data(using: .utf8),
              let indices = try? JSONDecoder().decode([Int].self, from: jsonData) else {
            return tasks
        }

        return indices.compactMap { tasks.indices.contains($0) ? tasks[$0] : nil }
    }
}
