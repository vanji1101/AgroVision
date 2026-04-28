import os
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from routes import health, chat, voice
from utils.logger import get_logger

logger = get_logger(__name__)

app = FastAPI(
    title="AgroVision AI Backend",
    description="Backend system for AgroVision AI-powered agriculture assistant",
    version="1.0.0"
)

# CORS configuration
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], # Allow all for local development
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include routers
app.include_router(health.router, tags=["Health"])
app.include_router(chat.router, tags=["Chat"])
app.include_router(voice.router, tags=["Voice"])

# Ensure static/audio directory exists for TTS output
os.makedirs(os.path.join(os.path.dirname(__file__), "static", "audio"), exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

@app.on_event("startup")
async def startup_event():
    logger.info("AgroVision Backend Server started successfully.")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
