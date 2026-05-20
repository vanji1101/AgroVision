import requests
import traceback
import re
from utils.logger import get_logger

logger = get_logger(__name__)

OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_GENERATE_URL = f"{OLLAMA_BASE_URL}/api/generate"
OLLAMA_TAGS_URL = f"{OLLAMA_BASE_URL}/api/tags"

BASE_PROMPT = """You are AgroVision AI, a strict agriculture-only professional smart farming assistant.
Your job is to help farmers with crop cultivation, tomato farming, paddy farming, fertilizer guidance, soil improvement, irrigation, pest/disease management, weather-based farming advice, harvesting, market guidance, and navigating government agricultural schemes, subsidies, and financial assistance programs.

IMPORTANT RESPONSE RULES:
1. Answer ONLY agriculture-related questions, including government farming schemes.
2. Give direct practical answers.
3. Avoid generic AI explanations.
4. Use short farmer-friendly sentences.
5. Give step-by-step farming guidance.
6. Never repeat the same idea.
7. Do not give unnecessary warnings.
8. Sound like an agriculture expert, not a chatbot.
9. Keep answers under 8 lines unless providing scheme details.
10. Do not use markdown formatting like **bold** or # headings.

When explaining Government Schemes, follow this structure:
திட்டத்தின் பெயர்: [Scheme name in Tamil]
என்ன உதவி கிடைக்கும்: [Brief benefit]
யார் விண்ணப்பிக்கலாம்: [Eligibility points]
தேவையான ஆவணங்கள்: [Documents]
எப்படி விண்ணப்பிப்பது: [Simple steps]
விண்ணப்பிக்க: [Direct link]
கடைசி தேதி: [Deadline]

Response format:
* Step-by-step
* Clear spacing
* Action-oriented

{language_instruction}
"""

def detect_language(text: str) -> str:
    """Detects if the input is Tamil, Tanglish, or English."""
    # Check for Tamil unicode characters
    if any('\u0B80' <= c <= '\u0BFF' for c in text):
        return "tamil"
    
    # Check for common Tanglish agriculture keywords
    text_lower = text.lower()
    tanglish_keywords = ['epdi', 'enna', 'uram', 'mann', 'thakkali', 'vivasayam', 'nel', 'nadavu', 'marunthu', 'thanni', 'mazhai', 'valarpu', 'payir', 'eppadi']
    for kw in tanglish_keywords:
        if kw in text_lower.split():
            return "tanglish"
            
    # Default to English
    return "english"

def is_agriculture_query(text: str) -> bool:
    """Strictly checks if the query is agriculture related."""
    text_lower = text.lower()
    agri_keywords = [
        # English
        'crop', 'soil', 'fertilizer', 'irrigation', 'weather', 'disease', 'pest', 
        'market', 'harvest', 'organic', 'seed', 'tractor', 'farm', 'tomato', 
        'paddy', 'rice', 'agriculture', 'water', 'rain', 'yield', 'plant', 'grow', 'price',
        'scheme', 'subsidy', 'loan', 'kisan', 'insurance', 'pmfby', 'pm-kisan', 'kcc',
        # Tamil
        'விவசாயம்', 'மண்', 'உரம்', 'நீர்', 'நோய்', 'மழை', 'விதை', 'பயிர்', 'தக்காளி', 'நெல்', 'விலை',
        'திட்டம்', 'மானியம்', 'கடன்', 'காப்பீடு', 'உதவி',
        # Tanglish
        'vivasayam', 'mann', 'uram', 'thanni', 'neer', 'noi', 'malai', 'mazhai', 
        'vidhai', 'payir', 'thakkali', 'nel', 'nadavu', 'valarpu', 'vilai',
        'thittam', 'maniyam', 'kadan', 'kappidu', 'udhavi'
    ]
    
    for kw in agri_keywords:
        if kw in text_lower:
            return True
            
    # Allow simple greetings
    if text_lower.strip() in ['hi', 'hello', 'vanakkam', 'வணக்கம்']:
        return True
        
    return False

def clean_response(response: str) -> str:
    """Removes markdown and cleans up the AI response."""
    # Remove markdown bold/italics
    cleaned = re.sub(r'\*\*(.*?)\*\*', r'\1', response)
    cleaned = re.sub(r'\*(.*?)\*', r'\1', cleaned)
    # Remove headers
    cleaned = re.sub(r'#+\s*', '', cleaned)
    # Remove bullet points if it's already using numbers or just clean it up
    cleaned = cleaned.replace('- ', '')
    
    # Ensure concise lines, skip empty ones
    lines = [line.strip() for line in cleaned.split('\n') if line.strip()]
    return '\n'.join(lines)


TARGET_MODEL = "gemma4:e2b"

class ChatbotService:
    def __init__(self):
        self.installed_models = []
        self.current_model = None
        self.ollama_running = False
        self.startup_validation()

    def startup_validation(self):
        """Verifies Ollama is reachable and detects available models."""
        try:
            response = requests.get(OLLAMA_TAGS_URL, timeout=10)
            response.raise_for_status()
            data = response.json()
            
            self.installed_models = [m["name"] for m in data.get("models", [])]
            self.ollama_running = True
            
            logger.info(f"Ollama is running. Installed models: {self.installed_models}")
            logger.info(f"Required model: {TARGET_MODEL}")
            
            # Select strict model
            self.current_model = self._select_strict_model()
            if self.current_model:
                logger.info(f"Selected model for AgroVision: {self.current_model}")
            else:
                logger.error(f"Required Ollama model {TARGET_MODEL} is not installed. Please run: ollama pull {TARGET_MODEL}")
                
        except requests.exceptions.RequestException as e:
            self.ollama_running = False
            logger.error(f"Failed to connect to Ollama during startup: {e}")

    def _select_strict_model(self):
        """Forces the use of TARGET_MODEL without falling back to gemma:2b"""
        if not self.installed_models:
            return None
            
        if TARGET_MODEL in self.installed_models:
            return TARGET_MODEL
                
        return None

    def get_status(self):
        return {
            "ollama_running": self.ollama_running,
            "installed_models": self.installed_models,
            "current_model": self.current_model,
            "provider": "ollama"
        }

    def generate_response(self, prompt: str, context: str = "", language: str = "en") -> str:
        logger.info(f"Processing query: {prompt}")
        
        # 1. Intent Detection
        is_agri = is_agriculture_query(prompt)
        logger.info(f"Is Agriculture Query: {is_agri}")
        
        if not is_agri:
            lang = detect_language(prompt)
            if lang == "tamil":
                return "நான் விவசாயம் தொடர்பான கேள்விகளுக்கு மட்டும் உதவ முடியும்."
            elif lang == "tanglish":
                return "Naan vivasayam related questions ku mattum help panna mudiyum."
            else:
                return "I can help only with agriculture-related questions."
        
        # 2. Language Detection
        detected_lang = detect_language(prompt)
        logger.info(f"Detected Language: {detected_lang}")
        
        # 3. Prompt Routing
        if detected_lang == "tamil":
            lang_instruction = "REPLY STRICTLY ONLY IN CLEAN SIMPLE TAMIL SCRIPT. DO NOT USE ENGLISH."
        elif detected_lang == "tanglish":
            lang_instruction = "REPLY STRICTLY ONLY IN TANGLISH (Tamil words written in English alphabet). DO NOT USE TAMIL SCRIPT OR PURE ENGLISH."
        else:
            lang_instruction = "REPLY STRICTLY ONLY IN SIMPLE ENGLISH."

        if not self.ollama_running or not self.current_model:
            # Try to re-validate just in case Ollama started later
            self.startup_validation()
            if not self.ollama_running:
                return "Sorry, the local AI model (Ollama) is not running or unreachable."
            if not self.current_model:
                return f"Sorry, no suitable model installed. Available: {self.installed_models}"

        full_prompt = BASE_PROMPT.replace("{language_instruction}", lang_instruction) + "\n"
        if context:
            full_prompt += f"Context Information: {context}\n"
            
        full_prompt += f"\nFarmer: {prompt}\nAgroVision AI:"

        # 4. Ollama Optimization
        payload = {
            "model": self.current_model, # Should automatically pick gemma:2b or user's exact installed model
            "prompt": full_prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,
                "top_p": 0.7,
                "repeat_penalty": 1.2,
                "num_predict": 180
            }
        }

        logger.info(f"Ollama URL: {OLLAMA_GENERATE_URL}")
        logger.info(f"Model Name: {self.current_model}")
        
        try:
            start_time = requests.utils.default_timer() if hasattr(requests.utils, 'default_timer') else 0 # simple fallback
            import time
            start_time = time.time()
            
            response = requests.post(OLLAMA_GENERATE_URL, json=payload, timeout=120)
            
            end_time = time.time()
            logger.info(f"Ollama Response Time: {round(end_time - start_time, 2)} seconds")
            
            if response.status_code != 200:
                logger.error(f"Raw Ollama Error Response: {response.text}")
                
            response.raise_for_status()
            data = response.json()
            
            raw_text = data.get("response", "").strip()
            
            # 5. Response Cleanup
            final_text = clean_response(raw_text)
            
            return final_text
            
        except requests.exceptions.HTTPError as e:
            logger.error(f"Ollama HTTP Error: {e}")
            logger.error(f"Stack Trace:\n{traceback.format_exc()}")
            return "The AI model encountered an internal error processing your request."
        except requests.exceptions.ConnectionError:
            logger.error("Failed to connect to Ollama.")
            logger.error(f"Stack Trace:\n{traceback.format_exc()}")
            return "Sorry, the local AI model (Ollama) is not reachable."
        except requests.exceptions.Timeout:
            logger.error("Ollama request timed out.")
            return "Sorry, the AI model took too long to respond."
        except Exception as e:
            logger.error(f"Error querying Ollama: {e}")
            logger.error(f"Stack Trace:\n{traceback.format_exc()}")
            return "An unexpected error occurred while generating the response."

chatbot_service = ChatbotService()
