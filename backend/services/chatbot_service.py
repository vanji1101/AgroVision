import requests
import json
from utils.logger import get_logger

logger = get_logger(__name__)

class ChatbotService:
    def __init__(self, ollama_url: str = "http://localhost:11434", model: str = "gemma"): # or gemma4:e2b
        self.ollama_url = ollama_url
        self.model = model
        self.generate_endpoint = f"{self.ollama_url}/api/generate"
        
        self.system_prompt = """You are AgroVision, an AI agriculture assistant. 
You help farmers with crop diseases, weather, market prices, and farming techniques. 
Keep your answers brief, practical, and easy to understand. 
If the user speaks Tamil or Tanglish, reply in Tamil (or simple Tanglish). 
Do not use complex jargon."""

    def generate_response(self, prompt: str, context: str = "", language: str = "en") -> str:
        try:
            full_prompt = f"{self.system_prompt}\n"
            if context:
                full_prompt += f"\nContext information: {context}\n"
            
            full_prompt += f"\nUser: {prompt}\nAgroVision:"

            payload = {
                "model": self.model,
                "prompt": full_prompt,
                "stream": False
            }
            
            logger.info(f"Sending request to Ollama ({self.model})")
            response = requests.post(self.generate_endpoint, json=payload, timeout=30)
            
            if response.status_code == 200:
                result = response.json()
                return result.get("response", "Sorry, I could not generate a response.")
            else:
                logger.error(f"Ollama API error: {response.status_code} - {response.text}")
                return "Sorry, I am having trouble connecting to my brain right now."
                
        except requests.exceptions.RequestException as e:
            logger.error(f"Failed to connect to Ollama: {e}")
            return "Sorry, I cannot connect to the AI model. Make sure Ollama is running locally."

chatbot_service = ChatbotService()
