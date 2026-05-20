# =============================================================
# services/llm_advisory_service.py
# Generates crop-disease advisory using local Ollama LLM
# with confidence threshold, timeout, and static fallback.
# =============================================================

import re
import requests
import time
from typing import Optional
from utils.logger import get_logger
from services.treatment_service import get_treatment_info

logger = get_logger(__name__)

OLLAMA_GENERATE_URL = "http://localhost:11434/api/generate"
MODEL_NAME = "gemma:2b"
TIMEOUT_SECONDS = 20.0
CONFIDENCE_THRESHOLD = 75.0


def clean_response(response: str) -> str:
    """Removes markdown format elements and cleans up spacing from the LLM output."""
    # Remove markdown bold/italics
    cleaned = re.sub(r'\*\*(.*?)\*\*', r'\1', response)
    cleaned = re.sub(r'\*(.*?)\*', r'\1', cleaned)
    # Remove headers
    cleaned = re.sub(r'#+\s*', '', cleaned)
    
    # Strip whitespace, split lines, filter empty ones
    lines = [line.strip() for line in cleaned.split('\n') if line.strip()]
    return '\n'.join(lines)


def parse_sections(text: str) -> tuple[str, str]:
    """
    Parses the cleaned text into distinct treatment and prevention sections
    using standard headers or line-by-line fallback.
    """
    treatment = ""
    prevention = ""
    
    if "PREVENTION:" in text:
        parts = text.split("PREVENTION:")
        treatment_part = parts[0]
        prevention_part = parts[1]
        
        if "TREATMENT:" in treatment_part:
            treatment = treatment_part.split("TREATMENT:")[1].strip()
        else:
            treatment = treatment_part.strip()
        prevention = prevention_part.strip()
    else:
        # Fallback line-by-line parsing if the section headers are missing or slightly malformed
        lines = text.split("\n")
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
        
    return treatment, prevention


def generate_disease_advisory(
    crop: str, 
    disease: str, 
    confidence: float, 
    raw_label: Optional[str] = None, 
    language: str = "en"
) -> dict[str, str]:
    """
    Generates treatment and prevention advice for the predicted crop and disease.
    
    Args:
        crop: Predicted crop name (e.g. 'Corn')
        disease: Predicted disease name (e.g. 'Common Rust')
        confidence: Prediction confidence score as a percentage (e.g. 85.42)
        raw_label: Raw disease label (e.g. 'corn___common_rust') used for fallback lookup
        language: ISO-style language identifier ('en', 'ta', etc.)
        
    Returns:
        dict containing 'treatment', 'prevention', and 'advisory_source' keys.
    """
    
    # ── 1. Confidence Threshold Check ──────────────────────────────────────
    if confidence < CONFIDENCE_THRESHOLD:
        warning_msg = "Prediction confidence is low. Please upload a clearer image of a supported crop leaf."
        
        logger.info(f"Prediction result: crop={crop}, disease={disease}, confidence={confidence:.2f}%")
        logger.info(f"Confidence is below threshold ({CONFIDENCE_THRESHOLD}%). Returning warning.")
        logger.info("Advisory Source: warning")
        
        return {
            "treatment": warning_msg,
            "prevention": "",
            "advisory_source": "warning"
        }

    # ── 2. Get static fallback details in advance ─────────────────────────
    if not raw_label:
        # Reconstruct standard normalized label if not explicitly provided
        raw_label = f"{crop}___{disease}".replace(" ", "_").lower()
        
    fallback_info = get_treatment_info(raw_label)
    
    # ── 3. Build Prompt with Strict Constraints ─────────────────────────────
    lang_instruction = "REPLY STRICTLY ONLY IN SIMPLE FARMER-FRIENDLY ENGLISH."
    if language.lower() in ["ta", "tamil"]:
        lang_instruction = "REPLY STRICTLY ONLY IN CLEAN SIMPLE TAMIL SCRIPT. DO NOT USE ENGLISH (EXCEPT FOR THE REQUIRED HEADERS BELOW)."
    elif language.lower() == "tanglish":
        lang_instruction = "REPLY STRICTLY ONLY IN TANGLISH (Tamil words written in English alphabet). DO NOT USE TAMIL SCRIPT (EXCEPT FOR THE REQUIRED HEADERS BELOW)."

    prompt = f"""You are AgroVision AI, a senior plant pathologist and expert agricultural advisor.
A farmer has a {crop} crop with {disease} disease.
Provide simple, practical, step-by-step treatment suggestions and effective prevention tips using clear, simple, farmer-friendly language.

CRITICAL INSTRUCTIONS:
1. Avoid making dangerous chemical dosage claims.
2. Recommend consulting the local agricultural officer or extension officer for precise chemical dosage.
3. Keep the advice actionable, clear, and highly relevant to {crop} and {disease}.
4. You MUST separate your response into two distinct sections: 'TREATMENT:' and 'PREVENTION:'.

{lang_instruction}

Format your response exactly as follows:
TREATMENT:
- [Step 1]
- [Step 2]
- [Step 3]

PREVENTION:
- [Step 1]
- [Step 2]
- [Step 3]
"""

    payload = {
        "model": MODEL_NAME,
        "prompt": prompt,
        "stream": False,
        "options": {
            "temperature": 0.3,
            "top_p": 0.7,
            "repeat_penalty": 1.2,
            "num_predict": 300
        }
    }

    # ── 4. Query Ollama with Timeout ───────────────────────────────────────
    logger.info(f"Querying Ollama ({MODEL_NAME}) for crop={crop}, disease={disease}, confidence={confidence:.2f}%...")
    start_time = time.time()
    
    try:
        response = requests.post(OLLAMA_GENERATE_URL, json=payload, timeout=TIMEOUT_SECONDS)
        elapsed_time = time.time() - start_time
        
        if response.status_code != 200:
            logger.warning(
                f"Ollama returned status {response.status_code} in {elapsed_time:.2f}s. "
                "Falling back to static treatment database."
            )
            logger.info("Advisory Source: fallback")
            return {
                "treatment": fallback_info["treatment"],
                "prevention": fallback_info["prevention"],
                "advisory_source": "fallback"
            }
            
        data = response.json()
        raw_response_text = data.get("response", "").strip()
        
        if not raw_response_text:
            logger.warning(f"Ollama returned empty response in {elapsed_time:.2f}s. Falling back.")
            logger.info("Advisory Source: fallback")
            return {
                "treatment": fallback_info["treatment"],
                "prevention": fallback_info["prevention"],
                "advisory_source": "fallback"
            }
            
        # Clean and parse sections from LLM output
        clean_text = clean_response(raw_response_text)
        treatment, prevention = parse_sections(clean_text)
        
        # Validate that we successfully parsed meaningful content
        if len(treatment) < 15 or len(prevention) < 15:
            logger.warning(
                f"LLM generated response in {elapsed_time:.2f}s was too short or malformed. "
                "Falling back to static treatment."
            )
            logger.info("Advisory Source: fallback")
            return {
                "treatment": fallback_info["treatment"],
                "prevention": fallback_info["prevention"],
                "advisory_source": "fallback"
            }
            
        logger.info(f"Successfully generated dynamic LLM advisory in {elapsed_time:.2f}s.")
        logger.info("Advisory Source: llm")
        return {
            "treatment": treatment,
            "prevention": prevention,
            "advisory_source": "llm"
        }
        
    except requests.exceptions.Timeout:
        logger.error(f"Ollama request TIMED OUT after {TIMEOUT_SECONDS} seconds limit. Falling back.")
        logger.info("Advisory Source: fallback")
        return {
            "treatment": fallback_info["treatment"],
            "prevention": fallback_info["prevention"],
            "advisory_source": "fallback"
        }
    except Exception as exc:
        logger.error(f"Error querying Ollama: {exc}. Falling back to static database.")
        logger.info("Advisory Source: fallback")
        return {
            "treatment": fallback_info["treatment"],
            "prevention": fallback_info["prevention"],
            "advisory_source": "fallback"
        }
