import re
from typing import Dict, Any, Tuple
from utils.logger import get_logger

logger = get_logger(__name__)

class IntentService:
    def __init__(self):
        # Basic keyword matching for intents
        self.intents = {
            "crop disease": [r"disease", r"sick", r"spot", r"rot", r"நோய்", r"நொய்", r"kalan", r"puchi", r"yellow", r"மஞ்சள்"],
            "treatment": [r"treatment", r"cure", r"medicine", r"marunthu", r"மருந்து", r"theervu", r"என்ன செய்யலாம்", r"enna seiyalam"],
            "prevention": [r"prevent", r"stop", r"avoid", r"thaduppu", r"தடுப்பு"],
            "weather": [r"weather", r"rain", r"temperature", r"hot", r"வானிலை", r"மழை", r"malai", r"mazhai", r"today weather sollu", r"rain varuma"],
            "market price": [r"price", r"market", r"sell", r"buy", r"விலை", r"சந்தை", r"vilai"],
            "fertilizer": [r"fertilizer", r"urea", r"npk", r"compost", r"உரம்", r"uram"],
            "irrigation": [r"water", r"irrigation", r"dry", r"தண்ணீர்", r"பாசனம்", r"thanni", r"neer"],
            "soil": [r"soil", r"earth", r"sand", r"மண்", r"mann"],
            "crop advice": [r"crop", r"grow", r"plant", r"advice", r"பயிர்", r"valarpu", r"payir"]
        }

    def detect_intent(self, text: str) -> str:
        text_lower = text.lower()
        for intent, patterns in self.intents.items():
            for pattern in patterns:
                if re.search(pattern, text_lower):
                    logger.info(f"Detected intent: {intent}")
                    return intent
        return "general"

    def get_mock_data(self, intent: str, text: str) -> Tuple[str, Dict[str, Any]]:
        """
        Returns a context string and mock data based on the detected intent.
        In a real scenario, this would call external APIs or databases.
        """
        if intent == "weather":
            data = {"status": "unavailable"}
            context = "Live weather data is currently unavailable. Provide general farming guidance, such as: 'உங்கள் இடத்தின் live weather data இப்போது கிடைக்கவில்லை. ஆனால் மழை வாய்ப்பு இருந்தால் நீர்ப்பாசனத்தை தவிர்க்கவும், பயிரை பாதுகாக்கவும்.'"
            return context, data
            
        elif intent == "market price":
            data = {"status": "unavailable"}
            context = "Live market data is currently unavailable."
            return context, data
            
        elif intent in ["crop disease", "treatment", "prevention"]:
            data = {"action": "disease_info"}
            context = "For disease/treatment questions, structure the answer with: possible cause, treatment, prevention, when to consult agriculture officer."
            return context, data
            
        return "", {}

intent_service = IntentService()
