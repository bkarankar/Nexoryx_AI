from fastapi import FastAPI
import subprocess

app = FastAPI()

@app.get("/")
def root():
    return {"status": "AI Workspace Running"}

@app.get("/health")
def health():
    return {"status": "healthy"}

@app.get("/models")
def models():
    result = subprocess.run(
        ["ollama", "list"],
        capture_output=True,
        text=True
    )

    return {"models": result.stdout}