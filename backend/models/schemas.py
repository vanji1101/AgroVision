from pydantic import BaseModel
from typing import Optional, Dict, Any

class ChatRequest(BaseModel):
    message: str
    context: Optional[str] = None
    language: Optional[str] = "en" # "en" or "ta"

class ChatResponse(BaseModel):
    response: str
    intent: Optional[str] = None
    data: Optional[Dict[str, Any]] = None

class VoiceResponse(BaseModel):
    response_text: str
    intent: Optional[str] = None
    audio_url: Optional[str] = None
