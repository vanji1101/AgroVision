import os
import tempfile
import whisper
from TTS.api import TTS
from utils.logger import get_logger

logger = get_logger(__name__)

class VoiceService:
    def __init__(self):
        self.whisper_model = None
        self.tts = None
        self.audio_output_dir = os.path.join(os.path.dirname(__file__), "..", "static", "audio")
        os.makedirs(self.audio_output_dir, exist_ok=True)
        
    def _load_whisper(self):
        if self.whisper_model is None:
            logger.info("Loading Whisper model (base)...")
            # Use base or tiny for faster local inference
            self.whisper_model = whisper.load_model("base") 
            
    def _load_tts(self):
        if self.tts is None:
            logger.info("Loading Coqui TTS model...")
            # Use a multilingual model to support English and Tamil if possible, 
            # or a fast English model for now.
            # Example: tts_models/multilingual/multi-dataset/xtts_v2 is good but heavy.
            # Using a basic English model to ensure it runs locally smoothly.
            self.tts = TTS("tts_models/en/ljspeech/fast_pitch")

    def transcribe_audio(self, file_path: str) -> str:
        try:
            self._load_whisper()
            logger.info(f"Transcribing audio file: {file_path}")
            result = self.whisper_model.transcribe(file_path)
            text = result["text"].strip()
            logger.info(f"Transcription result: {text}")
            return text
        except Exception as e:
            logger.error(f"Error during transcription: {e}")
            return ""

    def synthesize_speech(self, text: str, filename: str = "response.wav") -> str:
        try:
            self._load_tts()
            output_path = os.path.join(self.audio_output_dir, filename)
            logger.info(f"Synthesizing speech to {output_path}")
            self.tts.tts_to_file(text=text, file_path=output_path)
            return output_path
        except Exception as e:
            logger.error(f"Error during TTS synthesis: {e}")
            return ""

voice_service = VoiceService()
