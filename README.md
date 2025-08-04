# AI Chat Application

This project provides a Python backend and a browser-based frontend to interact with an [Ollama](https://ollama.com) model. The UI streams the model's output in real time and displays the model's internal reasoning, enclosed in `<think>` tags, inside an expandable section above each reply.

## Requirements

- Python 3.9+
- [Ollama](https://ollama.com) with the model `goekdenizguelmez/JOSIEFIED-Qwen3:4b-q5_k_m`

## Running the App

1. Install Python dependencies:
   ```bash
   pip install -r backend/requirements.txt
   ```
2. Start the backend server:
   ```bash
   python backend/server.py
   ```
3. Open `http://localhost:8000` in your browser.

Enter a prompt in the text box and click **Send**. The model's response will stream in real time. Expand the **Model thinking...** section to view the reasoning text captured between `<think>` and `</think>`.
