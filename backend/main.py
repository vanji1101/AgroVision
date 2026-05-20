import os
from contextlib import asynccontextmanager
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles

from routes import health, chat, voice, crop_disease
from services import prediction_service
from utils.logger import get_logger

logger = get_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("AgroVision Backend Server started successfully.")
    # Load the crop-disease ML model once so every request is fast
    prediction_service.initialize()
    if prediction_service.is_model_loaded():
        logger.info("Crop disease model is READY.")
    else:
        logger.warning(
            "Crop disease model NOT loaded. "
            "Place 'best_model.keras' in backend/models/ and restart. "
            f"Reason: {prediction_service.get_load_error()}"
        )
    yield

app = FastAPI(
    title="AgroVision AI Backend",
    description="Backend system for AgroVision AI-powered agriculture assistant",
    version="1.0.0",
    lifespan=lifespan
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
app.include_router(crop_disease.router)   # Crop Disease Detection module

# Ensure static/audio directory exists for TTS output
os.makedirs(os.path.join(os.path.dirname(__file__), "static", "audio"), exist_ok=True)
app.mount("/static", StaticFiles(directory="static"), name="static")

if __name__ == "__main__":
    import uvicorn
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)
