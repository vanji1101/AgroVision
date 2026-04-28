from fastapi import APIRouter, HTTPException
from models.schemas import ChatRequest, ChatResponse
from services.intent_service import intent_service
from services.chatbot_service import chatbot_service
from utils.logger import get_logger

logger = get_logger(__name__)
router = APIRouter()

@router.post("/chat", response_model=ChatResponse)
async def chat_endpoint(request: ChatRequest):
    try:
        logger.info(f"Received chat request: {request.message}")
        
        # 1. Detect Intent
        intent = intent_service.detect_intent(request.message)
        
        # 2. Get Mock Data / Domain specific context based on intent
        mock_context, mock_data = intent_service.get_mock_data(intent, request.message)
        
        # Combine user context with our mock domain context
        combined_context = f"{request.context or ''} {mock_context}".strip()
        
        # 3. Generate response using Gemma
        response_text = chatbot_service.generate_response(
            prompt=request.message,
            context=combined_context,
            language=request.language
        )
        
        return ChatResponse(
            response=response_text,
            intent=intent,
            data=mock_data
        )
        
    except Exception as e:
        logger.error(f"Error in chat endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
