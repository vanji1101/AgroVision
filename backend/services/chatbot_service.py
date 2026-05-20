import requests
import traceback
import re
from typing import Optional
from utils.logger import get_logger

logger = get_logger(__name__)

OLLAMA_BASE_URL = "http://localhost:11434"
OLLAMA_GENERATE_URL = f"{OLLAMA_BASE_URL}/api/generate"
OLLAMA_TAGS_URL = f"{OLLAMA_BASE_URL}/api/tags"

BASE_PROMPT = """You are AgroVision, an AI farming assistant for Tamil Nadu farmers.
You must answer agriculture-related questions in simple Tamil or Tanglish.
You can help with crop disease, treatment, prevention, fertilizer, irrigation, soil health, weather advice, market price guidance, and crop planning.
Do not reject weather, irrigation, soil, market, or disease questions because they are agriculture-related.
Give practical, short, safe advice.
If live data is not available, clearly say live data is not available and give general farming guidance.

IMPORTANT RESPONSE RULES:
1. For disease/treatment questions, give: possible cause, treatment, prevention, and when to consult agriculture officer.
2. Reply strictly in the language requested.
3. Keep answer short and farmer-friendly.
4. Do not use complex markdown formatting like **bold** or # headings.

{language_instruction}
"""

def detect_language(text: str) -> str:
    """Detects if the input is Tamil, Tanglish, or English."""
    # Check for Tamil unicode characters
    if any('\u0B80' <= c <= '\u0BFF' for c in text):
        return "tamil"
    
    # Check for common Tanglish agriculture keywords
    text_lower = text.lower()
    tanglish_keywords = ['epdi', 'enna', 'uram', 'mann', 'thakkali', 'vivasayam', 'nel', 'nadavu', 'marunthu', 'thanni', 'mazhai', 'valarpu', 'payir', 'eppadi', 'seiyalam', 'sollu', 'varuma']
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
        # Tamil
        'விவசாயம்', 'மண்', 'உரம்', 'நீர்', 'நோய்', 'மழை', 'விதை', 'பயிர்', 'தக்காளி', 'நெல்', 'விலை', 'மருந்து', 'தடுப்பு', 'வானிலை', 'இன்றைக்கு', 'என்ன',
        # Tanglish
        'vivasayam', 'mann', 'uram', 'thanni', 'neer', 'noi', 'malai', 'mazhai', 
        'vidhai', 'payir', 'thakkali', 'nel', 'nadavu', 'valarpu', 'vilai', 'marunthu', 'thaduppu', 'weather', 'rain', 'sollu', 'varuma'
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


TARGET_MODEL = "gemma:2b"

class ChatbotService:
    def __init__(self):
        self.installed_models = []
        self.current_model = None
        self.ollama_running = False
        self.startup_validation()

    def startup_validation(self):
        """Verifies Ollama is reachable and detects available models."""
        try:
            response = requests.get(OLLAMA_TAGS_URL, timeout=5)
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
        """Robust model matching supporting partial name or tags match"""
        if not self.installed_models:
            return None
            
        # 1. Exact match
        if TARGET_MODEL in self.installed_models:
            return TARGET_MODEL
            
        # 2. Match standard tag variation
        for m in self.installed_models:
            if m.startswith(TARGET_MODEL) or TARGET_MODEL.startswith(m):
                return m
                
        # 3. Substring match
        for m in self.installed_models:
            if "gemma" in m.lower():
                return m
                
        # 4. Fallback to first available
        return self.installed_models[0]

    def get_status(self):
        return {
            "ollama_running": self.ollama_running,
            "installed_models": self.installed_models,
            "current_model": self.current_model,
            "provider": "ollama"
        }

    def generate_response(self, prompt: str, context: str = "", language: Optional[str] = "en") -> str:
        if not language:
            language = "en"
        logger.info(f"Processing query: {prompt}")
        
        # 1. Intent Detection
        is_agri = is_agriculture_query(prompt)
        logger.info(f"Is Agriculture Query: {is_agri}")
        
        # Local intent detection for accurate high-quality fallbacks
        detected_intent = "general"
        prompt_lower = prompt.lower()
        if any(kw in prompt_lower for kw in ["water", "irrigation", "dry", "பாசனம்", "நீர்", "தண்ணீர்"]):
            detected_intent = "irrigation"
        elif any(kw in prompt_lower for kw in ["soil", "earth", "clay", "மண்", "mann"]):
            detected_intent = "soil"
        elif any(kw in prompt_lower for kw in ["disease", "sick", "spot", "rot", "காளான்", "நோய்"]):
            detected_intent = "disease"
        elif any(kw in prompt_lower for kw in ["fertilizer", "urea", "npk", "உரம்"]):
            detected_intent = "fertilizer"
        elif any(kw in prompt_lower for kw in ["weather", "rain", "temperature", "மழை", "வானிலை"]):
            detected_intent = "weather"
        elif any(kw in prompt_lower for kw in ["price", "market", "sell", "விலை", "சந்தை"]):
            detected_intent = "market"

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
        
        # 3. Prompt Routing & Predefined High-Quality Fallbacks
        if detected_lang == "tamil":
            lang_instruction = "REPLY STRICTLY ONLY IN SIMPLE TAMIL. DO NOT USE ENGLISH."
            fallback_responses = {
                "irrigation": "சொட்டு நீர் பாசனம் என்பது தாவரங்களின் வேர்களுக்கு அருகில் சிறிய குழாய்கள் மூலம் மெதுவாக நீரை வழங்கும் ஒரு முறையாகும். இது நீரைச் சேமித்து பயிர் வளர்ச்சியை மேம்படுத்துகிறது.",
                "fertilizer": "பயிர் வளர்ச்சிக்கு மண் பரிசோதனை செய்து உரம் போடுவது நல்லது. தழைச்சத்து இலை வளர்ச்சிக்கும், மணிச்சத்து வேர் வளர்ச்சிக்கும், சாம்பல்ச்சத்து காய் வளர்ச்சிக்கும் உதவுகிறது.",
                "disease": "பாதிக்கப்பட்ட இலையை அக்ரோவிஷன் நோய் கண்டறிதல் கருவி மூலம் ஸணே் செய்யுமாறு அல்லது உள்ளூர் விவசாய அதிகாரியிடம் ஆலோசனை பெறுமாறு பரிந்துரைக்கப்படுகிறது.",
                "soil": "மண்ணின் தரத்தை மேம்படுத்த மண்புழு உரம், தொழு உரம் போன்ற இயற்கை உரங்களை மண்ணில் சேர்த்து ஆழமாக உழவு செய்ய வேண்டும்.",
                "weather": "அதிக மழையினால் உரங்கள் அடித்துச் செல்லப்படுவதைத் தவிர்க்க, வானிலை முன்னறிவிப்பைப் பார்த்து உரமிடுவது நல்லது.",
                "market": "அறுவடைக்கு சிறந்த விலையைப் பெற உள்ளூர் சந்தை விலைகள் அல்லது அக்ரோவிஷன் விலை கண்காணிப்புப் பக்கத்தை தினமும் சரிபார்க்கவும்.",
                "general": "நான் விவசாயம், உரம், பயிர் வளர்ப்பு மற்றும் நீர்ப்பாசனம் தொடர்பான கேள்விகளுக்கு உதவ முடியும். நான் உங்களுக்கு எவ்வாறு உதவ வேண்டும்?"
            }
        elif detected_lang == "tanglish":
            lang_instruction = "REPLY STRICTLY IN TANGLISH (Tamil words written in English alphabet) OR MIXED TAMIL-ENGLISH SIMPLE STYLE."
            fallback_responses = {
                "irrigation": "Drip irrigation nu solra suttu neer pasanam thanniya semichu payir valarchiya nalla vachukum. Ithu direct a veruku thanni tharum.",
                "fertilizer": "Payir nalla valara mann parisotanai panni uram podunga. Urea valarchikum, NPK matha nutritional needs kum helpful a irukum.",
                "disease": "Elai noi ah kandupdika namma AgroVision leaf scanner use pannunga, illa local agri expert ah consult pannunga.",
                "soil": "Mann valatha athigamaka iyarkai uram matrum compost uram podunga, ithu mann eerapathatha nalla vachukum.",
                "weather": "Nalla mazhai peiyum pothu uram podathiga, mazhai peithu mudithathum pottal uram veenagathu.",
                "market": "Unga vilachaluku nalla vilai kidaika local market details matrum AgroVision app tracker parunga.",
                "general": "Naan vivasayam, uram, neer pasanam, noi viratti pathi solla mudiyum. Ungaluku enna udhavi venum?"
            }
        else:
            lang_instruction = "REPLY STRICTLY ONLY IN SIMPLE ENGLISH."
            fallback_responses = {
                "irrigation": "Drip irrigation is a method of watering plants by slowly delivering water near the roots through small pipes. It saves water and improves crop growth.",
                "fertilizer": "For optimal crop growth, apply NPK fertilizer based on soil testing. Nitrogen helps leaf growth, Phosphorus helps roots, and Potassium helps fruit development.",
                "disease": "It is recommended to scan the leaf using AgroVision's disease detector or consult a local agricultural extension expert to identify the exact pathogen.",
                "soil": "To improve soil health, regularly add organic matter such as compost or manure and avoid over-tilling.",
                "weather": "Always monitor the local weather forecast before applying fertilizers or pesticides to avoid run-off from heavy rains.",
                "market": "Check the local APMC market prices or AgroVision's price tracker daily to negotiate the best price for your harvest.",
                "general": "I am here to help you with crop cultivation, fertilizer recommendations, pest management, and irrigation tips. How can I assist you today?"
            }

        fallback_msg = fallback_responses.get(detected_intent, fallback_responses["general"])

        # Startup validation fallback if not initialized
        if not self.ollama_running or not self.current_model:
            self.startup_validation()
            if not self.ollama_running or not self.current_model:
                logger.warning("Ollama not running or model not found. Returning high-quality fallback.")
                return fallback_msg

        full_prompt = BASE_PROMPT.replace("{language_instruction}", lang_instruction) + "\n"
        if context:
            full_prompt += f"Context Information: {context}\n"
            
        full_prompt += f"\nFarmer: {prompt}\nAgroVision AI:"

        # 4. Ollama Optimization
        payload = {
            "model": self.current_model,
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
            import time
            start_time = time.time()
            
            response = requests.post(OLLAMA_GENERATE_URL, json=payload, timeout=25)
            
            end_time = time.time()
            logger.info(f"Ollama Response Time: {round(end_time - start_time, 2)} seconds")
            
            if response.status_code != 200:
                logger.error(f"Raw Ollama Error Response: {response.text}")
                return fallback_msg
                
            response.raise_for_status()
            data = response.json()
            
            # 5. Parse Ollama response correctly
            raw_text = data.get("response", "").strip()
            if not raw_text:
                logger.warning("Ollama returned empty output. Using fallback.")
                return fallback_msg
                
            # 6. Response Cleanup
            final_text = clean_response(raw_text)
            if not final_text:
                return fallback_msg
                
            return final_text
            
        except Exception as e:
            logger.error(f"Error querying Ollama: {e}")
            logger.error(f"Stack Trace:\n{traceback.format_exc()}")
            return fallback_msg

    def generate_disease_advice(self, crop: str, disease: str, raw_label: str, language: str = "en") -> dict[str, str]:
        """
        Generates dynamic, crop-disease-specific treatment and prevention recommendations
        using Ollama, falling back to the local database if Ollama is offline or fails.
        """
        # Step 1: Get the static fallback info
        from services.treatment_service import get_treatment_info
        fallback = get_treatment_info(raw_label)
        
        # Step 2: Validate Ollama status
        if not self.ollama_running or not self.current_model:
            self.startup_validation()
            if not self.ollama_running or not self.current_model:
                logger.warning("Ollama is not running. Returning static fallback.")
                return fallback
                
        # Step 3: Determine language-specific instructions
        lang_instruction = "REPLY STRICTLY ONLY IN SIMPLE FARMER-FRIENDLY ENGLISH."
        if language.lower() in ["ta", "tamil"]:
            lang_instruction = "REPLY STRICTLY ONLY IN CLEAN SIMPLE TAMIL SCRIPT. DO NOT USE ENGLISH (EXCEPT FOR THE REQUIRED HEADERS BELOW)."
        elif language.lower() == "tanglish":
            lang_instruction = "REPLY STRICTLY ONLY IN TANGLISH (Tamil words written in English alphabet). DO NOT USE TAMIL SCRIPT (EXCEPT FOR THE REQUIRED HEADERS BELOW)."
            
        prompt = f"""You are AgroVision AI, a senior plant pathologist and expert agricultural advisor.
A farmer has a {crop} crop with {disease} disease.
Provide practical, step-by-step treatment suggestions and effective prevention tips.

{lang_instruction}

You MUST start the first section with 'TREATMENT:' and the second section with 'PREVENTION:'.

Format your response exactly as follows:
TREATMENT:
- [Step 1 in {language}]
- [Step 2 in {language}]
- [Step 3 in {language}]

PREVENTION:
- [Step 1 in {language}]
- [Step 2 in {language}]
- [Step 3 in {language}]
"""

        # Step 4: Query Ollama
        payload = {
            "model": self.current_model,
            "prompt": prompt,
            "stream": False,
            "options": {
                "temperature": 0.3,
                "top_p": 0.7,
                "repeat_penalty": 1.2,
                "num_predict": 250
            }
        }
        
        try:
            import time
            start_time = time.time()
            response = requests.post(OLLAMA_GENERATE_URL, json=payload, timeout=20)
            end_time = time.time()
            logger.info(f"Ollama Disease Advice Response Time: {round(end_time - start_time, 2)} seconds")
            
            if response.status_code != 200:
                logger.error(f"Ollama returned status {response.status_code}. Using static fallback.")
                return fallback
                
            data = response.json()
            raw_text = data.get("response", "").strip()
            if not raw_text:
                return fallback
                
            # Clean and parse sections
            final_text = clean_response(raw_text)
            
            treatment = ""
            prevention = ""
            
            if "PREVENTION:" in final_text:
                parts = final_text.split("PREVENTION:")
                treatment_part = parts[0]
                prevention_part = parts[1]
                
                if "TREATMENT:" in treatment_part:
                    treatment = treatment_part.split("TREATMENT:")[1].strip()
                else:
                    treatment = treatment_part.strip()
                prevention = prevention_part.strip()
            else:
                # Fallback parse line by line
                lines = final_text.split("\n")
                t_lines = []
                p_lines = []
                is_prev = False
                for line in lines:
                    if any(k in line.lower() for k in ["prevention", "prevent"]):
                        is_prev = True
                        continue
                    if any(k in line.lower() for k in ["treatment", "treat"]):
                        continue
                    if is_prev:
                        p_lines.append(line)
                    else:
                        t_lines.append(line)
                treatment = "\n".join(t_lines).strip()
                prevention = "\n".join(p_lines).strip()
                
            # Final validation: if parsed text is too short or empty, return fallback
            if len(treatment) < 15 or len(prevention) < 15:
                logger.warning("LLM generated output was too short/malformed. Using static fallback.")
                return fallback
                
            return {
                "treatment": treatment,
                "prevention": prevention
            }
            
        except Exception as exc:
            logger.error(f"Error querying Ollama for crop disease advice: {exc}")
            return fallback

chatbot_service = ChatbotService()
