# AI Chat Application

This project provides a macOS SwiftUI frontend and a Python backend to interact with an Ollama model. The UI displays the model's streaming output and separates the model's internal reasoning (between `<think>` tags) in an expandable section.

## Backend (Python)

The backend uses FastAPI and streams the output of the model via WebSocket.

### Setup

```bash
cd backend
pip install -r requirements.txt
python server.py
```

The server starts on `http://localhost:8000` and exposes a WebSocket endpoint at `ws://localhost:8000/ws`.

## Frontend (SwiftUI)

The macOS app is located in `macos/AIChat`. It connects to the backend via WebSocket and renders the streamed Markdown response while showing the model's "thoughts" in a collapsible `DisclosureGroup`.

### Building

Open `macos/AIChat` in Xcode or build using Swift Package Manager:

```bash
cd macos/AIChat
swift build
```

Run the resulting app. Enter a prompt and watch the streamed reply; expand **Thoughts** to inspect the model's reasoning.
