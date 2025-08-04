import asyncio
import json
from fastapi import FastAPI, WebSocket, WebSocketDisconnect
import uvicorn

MODEL = "goekdenizguelmez/JOSIEFIED-Qwen3:4b-q5_k_m"

app = FastAPI()

async def stream_ollama(prompt: str, ws: WebSocket):
    """Run ollama and stream output to websocket, splitting thought and answer."""
    process = await asyncio.create_subprocess_exec(
        "ollama", "run", MODEL, prompt,
        stdout=asyncio.subprocess.PIPE,
        stderr=asyncio.subprocess.STDOUT,
    )

    mode = "answer"
    buffer = ""
    try:
        while True:
            chunk = await process.stdout.read(64)
            if not chunk:
                break
            text = chunk.decode("utf-8", errors="ignore")
            buffer += text
            while buffer:
                if mode == "answer":
                    idx = buffer.find("<think>")
                    if idx != -1:
                        pre = buffer[:idx]
                        if pre:
                            await ws.send_text(json.dumps({"type": "answer", "data": pre}))
                        buffer = buffer[idx + len("<think>") :]
                        mode = "thought"
                    else:
                        await ws.send_text(json.dumps({"type": "answer", "data": buffer}))
                        buffer = ""
                else:
                    idx = buffer.find("</think>")
                    if idx != -1:
                        pre = buffer[:idx]
                        if pre:
                            await ws.send_text(json.dumps({"type": "thought", "data": pre}))
                        buffer = buffer[idx + len("</think>") :]
                        mode = "answer"
                    else:
                        await ws.send_text(json.dumps({"type": "thought", "data": buffer}))
                        buffer = ""
        await process.wait()
    finally:
        await ws.send_text(json.dumps({"type": "done"}))

@app.websocket("/ws")
async def websocket_endpoint(websocket: WebSocket):
    await websocket.accept()
    try:
        data = await websocket.receive_text()
        try:
            payload = json.loads(data)
            prompt = payload.get("prompt", "")
        except json.JSONDecodeError:
            prompt = data
        await stream_ollama(prompt, websocket)
    except WebSocketDisconnect:
        pass

if __name__ == "__main__":
    uvicorn.run(app, host="0.0.0.0", port=8000)
