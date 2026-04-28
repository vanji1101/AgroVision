import os
import shutil
import uuid
from fastapi import APIRouter, UploadFile, File, HTTPException
from fastapi.responses import FileResponse
from services.voice_service import voice_service
from services.intent_service import intent_service
from services.chatbot_service import chatbot_service
from utils.logger import get_logger

logger = get_logger(__name__)
router = APIRouter()

@router.post("/voice")
async def voice_endpoint(audio: UploadFile = File(...)):
    try:
        # 1. Save uploaded file temporarily
        temp_input_path = f"temp_{uuid.uuid4()}.wav"
        with open(temp_input_path, "wb") as buffer:
            shutil.copyfileobj(audio.file, buffer)
            
        logger.info(f"Saved audio input to {temp_input_path}")
        
        # 2. Speech to Text (Whisper)
        transcribed_text = voice_service.transcribe_audio(temp_input_path)
        
        # Clean up input file
        if os.path.exists(temp_input_path):
            os.remove(temp_input_path)
            
        if not transcribed_text:
            raise HTTPException(status_code=400, detail="Could not transcribe audio")
            
        # 3. Intent & Chatbot (Gemma) processing
        intent = intent_service.detect_intent(transcribed_text)
        mock_context, mock_data = intent_service.get_mock_data(intent, transcribed_text)
        
        response_text = chatbot_service.generate_response(
            prompt=transcribed_text,
            context=mock_context
        )
        
        # 4. Text to Speech (Coqui)
        output_filename = f"response_{uuid.uuid4()}.wav"
        audio_output_path = voice_service.synthesize_speech(response_text, output_filename)
        
        if not audio_output_path or not os.path.exists(audio_output_path):
            raise HTTPException(status_code=500, detail="Failed to generate audio response")
            
        # Returning the generated audio file
        # In a real API, you might want to return JSON with an audio URL, but returning FileResponse is simpler for direct testing.
        return FileResponse(
            path=audio_output_path, 
            media_type="audio/wav", 
            filename="response.wav",
            headers={
                "X-Transcribed-Text": transcribed_text,
                "X-Response-Text": response_text.replace('\n', ' ')
            }
        )
        
    except Exception as e:
        logger.error(f"Error in voice endpoint: {e}")
        raise HTTPException(status_code=500, detail=str(e))
