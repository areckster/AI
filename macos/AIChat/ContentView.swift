import SwiftUI

class ChatModel: ObservableObject {
    @Published var thoughts: String = ""
    @Published var response: String = ""
    private var task: URLSessionWebSocketTask?

    func send(prompt: String) {
        thoughts = ""
        response = ""
        task?.cancel()
        guard let url = URL(string: "ws://localhost:8000/ws") else { return }
        task = URLSession.shared.webSocketTask(with: url)
        task?.resume()
        let payload = ["prompt": prompt]
        if let data = try? JSONSerialization.data(withJSONObject: payload),
           let text = String(data: data, encoding: .utf8) {
            task?.send(.string(text)) { error in
                if let error = error { print("Send error: \(error)") }
            }
        }
        receive()
    }

    private func receive() {
        task?.receive { [weak self] result in
            switch result {
            case .failure(let error):
                print("Receive error: \(error)")
            case .success(let message):
                if case let .string(text) = message,
                   let data = text.data(using: .utf8),
                   let json = try? JSONSerialization.jsonObject(with: data) as? [String: String],
                   let type = json["type"] {
                    DispatchQueue.main.async {
                        if type == "thought" {
                            self?.thoughts += json["data"] ?? ""
                        } else if type == "answer" {
                            self?.response += json["data"] ?? ""
                        } else if type == "done" {
                            self?.task?.cancel()
                            self?.task = nil
                        }
                    }
                }
                self?.receive()
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var model = ChatModel()
    @State private var prompt: String = ""
    @State private var showThoughts: Bool = false

    var body: some View {
        VStack {
            DisclosureGroup("Thoughts", isExpanded: $showThoughts) {
                ScrollView {
                    Text(model.thoughts)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                }
                .frame(height: 150)
            }
            .padding()

            ScrollView {
                if let attributed = try? AttributedString(markdown: model.response) {
                    Text(attributed)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                } else {
                    Text(model.response)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(4)
                }
            }
            .padding()

            HStack {
                TextEditor(text: $prompt)
                    .frame(height: 80)
                    .overlay(RoundedRectangle(cornerRadius: 4).stroke(Color.gray))
                Button("Send") {
                    model.send(prompt: prompt)
                }
            }
            .padding()
        }
        .frame(minWidth: 600, minHeight: 500)
    }
}
