from fastapi import APIRouter
from services.chatbot_service import chatbot_service

router = APIRouter()

@router.get("/health")
def health_check():
    return {"status": "ok", "service": "AgroVision Backend", "version": "1.0.0"}

@router.get("/model-status")
def model_status():
    # If not running, re-validate to ensure latest state
    if not chatbot_service.ollama_running:
        chatbot_service.startup_validation()
    return chatbot_service.get_status()
