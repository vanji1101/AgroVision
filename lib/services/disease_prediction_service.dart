class DiseasePredictionService {
  static List<String> predict({
    required String crop,
    required double temp,
    required double humidity,
    required double rain,
  }) {
    List<String> risks = [];
    crop = crop.toLowerCase();

    // 🌾 தானியங்கள் (Grains)
    if (crop == "rice" || crop == "நெல்") {
      if (humidity > 80 && temp >= 25 && temp <= 35) risks.add("🦠 குலை நோய் (Leaf Blast) பரவ அதிக வாய்ப்புள்ளது. (ஈரப்பதம் > 80%)");
      if (rain > 20) risks.add("🌧 இலைகருகல் நோய் (Bacterial Blight) வரலாம், கவனிக்கவும்.");
    }
    else if (crop == "pearl millet" || crop == "கம்பு" || crop == "sorghum" || crop == "சோளம்" || crop == "ragi" || crop == "ராகி") {
      if (crop.contains("ragi") || crop.contains("ராகி")) {
        if (humidity > 80) risks.add("🦠 குலை நோய் (Blast Disease) வர வாய்ப்பு அதிகம்.");
        if (temp > 35 && rain < 2) risks.add("🦠 வறட்சியால் மொசைக் நோய் (Mosaic Disease) பரவ வாய்ப்புள்ளது.");
      }
      if (humidity > 75 && rain > 10) risks.add("🦠 தண்டுத் துளைப்பான் மற்றும் குருத்து ஈ தாக்குதல் கூடும்.");
    }
    else if (crop == "black gram" || crop == "உளுந்து") {
      if (temp > 30 && humidity > 70) risks.add("🦠 வெள்ளை ஈ மற்றும் மஞ்சள் தேமல் நோய் (Yellow Mosaic) பரவலாம்.");
    }

    // 🌿 பணப்பயிர்கள் (Cash Crops)
    else if (crop == "sugarcane" || crop == "கரும்பு") {
      if (humidity > 80 && temp > 30) risks.add("🦠 செவ்வழுகல் நோய் (Red Rot) வருவதற்கான சாத்தியம் அதிகம்.");
    }
    else if (crop == "cotton" || crop == "பருத்தி") {
      if (humidity > 70 && temp < 30) risks.add("🦠 இலைச்சுருட்டுப் புழு மற்றும் சாறுறிஞ்சும் பூச்சிகள் தாக்கலாம்.");
    }
    else if (crop == "groundnut" || crop == "நிலக்கடலை") {
      if (humidity > 80 && temp > 25) risks.add("🦠 டிக்கா இலைப்புள்ளி நோய் (Tikka Disease) வர வாய்ப்புள்ளது.");
    }

    // 🍎 பழங்கள் & காய்கறிகள் (Fruits & Veggies)
    else if (crop == "banana" || crop == "வாழை") {
      if (temp > 30 && rain > 10) risks.add("🦠 எர்வினியா அழுகல் நோய் (Erwinia Rot): வெப்பம் மற்றும் ஈரப்பதமான சூழலில் இது அதிகமாகத் தாக்கும்.");
      if (rain > 20) risks.add("🌊 பாணமா வாடல் நோய் (Panama Wilt): வயலில் நீர் தேங்கினால் இது பரவும்.");
      if (humidity > 85 && rain > 10) risks.add("🦠 சிகடோகா இலைப்புள்ளி நோய் (Sigatoka Leaf Spot) பரவலாம்.");
    }
    else if (crop == "mango" || crop == "மா") {
      if (humidity > 75 && temp > 28) risks.add("🦠 மாம்பூக்களில் தேமல் மற்றும் தத்துப்பூச்சி (Hopper) தாக்குதல் வரலாம்.");
    }
    else if (crop == "tomato" || crop == "தக்காளி" || crop == "onion" || crop == "வெங்காயம்") {
      if (humidity > 80 && temp > 25) risks.add("🦠 வேர் அழுகல் மற்றும் தண்டு அழுகல் நோய் வரலாம்.");
    }

    // 🌴 மரங்கள் (Trees & Plantations)
    else if (crop == "coconut" || crop == "தென்னை") {
      if (humidity > 80 && temp > 28) risks.add("🦠 காண்டாமிருக வண்டு (Rhinoceros Beetle) தாக்குதல் அதிகரிக்கலாம்.");
      if (rain > 15) risks.add("🦠 தஞ்சாவூர் வாடல் நோய் (Root Wilt) பரவாமல் இருக்க வடிகால் அவசியம்.");
    }
    else if (crop == "cashew" || crop == "முந்திரி" || crop == "teak" || crop == "தேக்கு" || crop == "casuarina" || crop == "சவுக்கு") {
      if (humidity > 75 && temp > 30) risks.add("🦠 தேயிலை கொசு (Tea Mosquito Bug) முந்திரியைத் தாக்க வாய்ப்புள்ளது.");
    }

    return risks;
  }
}
