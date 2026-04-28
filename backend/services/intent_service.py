import re
from typing import Dict, Any, Tuple
from utils.logger import get_logger

logger = get_logger(__name__)

class IntentService:
    def __init__(self):
        # Basic keyword matching for intents
        self.intents = {
            "disease": [r"disease", r"sick", r"spot", r"rot", r"நோய்", r"நொய்"],
            "weather": [r"weather", r"rain", r"temperature", r"hot", r"வானிலை", r"மழை"],
            "market": [r"price", r"market", r"sell", r"buy", r"விலை", r"சந்தை"],
            "fertilizer": [r"fertilizer", r"urea", r"npk", r"compost", r"உரம்"],
            "irrigation": [r"water", r"irrigation", r"dry", r"தண்ணீர்", r"பாசனம்"]
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
            data = {"temperature": "32°C", "condition": "Sunny", "humidity": "60%"}
            context = "Current weather is 32°C and Sunny with 60% humidity."
            return context, data
            
        elif intent == "market":
            # Just mock some prices
            data = {"tomato": "₹40/kg", "onion": "₹35/kg", "potato": "₹25/kg"}
            context = "Current market prices: Tomato ₹40/kg, Onion ₹35/kg, Potato ₹25/kg."
            return context, data
            
        elif intent == "disease":
            data = {"action": "Consult local agricultural extension or use image scanner."}
            context = "The user is asking about a crop disease. Advise them to use the app's image scanner feature or consult a local expert."
            return context, data
            
        return "", {}

intent_service = IntentService()
