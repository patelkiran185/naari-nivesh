import base64
import os
import requests
from dotenv import load_dotenv
from flask import Flask, jsonify, request
from flask_cors import CORS
import google.generativeai as genai
import re
import json


# Load environment variables
load_dotenv()

# Initialize Flask app
app = Flask(__name__)
CORS(app)

# Configure Gemini API
genai.configure(api_key=os.getenv('GOOGLE_API_KEY'))
model = genai.GenerativeModel('gemini-pro')

# Define levels
LEVELS = {
    1: "Basic Emergency",
    2: "Health Crisis",
    3: "Job Loss",
    4: "Financial Debt",
    5: "Family Emergency",
    6: "Natural Disaster"
}

def extract_keywords(text, num_keywords=5):
    """Extract key phrases from the generated scenario text."""
    words = re.findall(r'\b[A-Za-z]{4,}\b', text)
    return ", ".join(words[:num_keywords])

def generate_image(level):
    """Generate an image based on the crisis level and return Base64."""
    image_path = None

    if level == 1:
        image_path = "basic_emer1.png"  
    elif level == 2:
        image_path = "health_crisis1.png"  
    elif level == 3:
        image_path = "job_loss1.jpg"  
    elif level == 4:
        image_path = "fin_debt1.jpg"  
    elif level == 5:
        image_path = "family_emer1.png"  
    elif level == 6:
        image_path = "natural_disas1.png"  

    if image_path and os.path.exists(image_path):
        with open(image_path, "rb") as image_file:
            return base64.b64encode(image_file.read()).decode("utf-8")
    else:
        return None

def extract_options_from_json(ai_response):
    """Extract scenario and options from the AI response formatted as JSON."""
    try:
        response_json = json.loads(ai_response)  # Parse AI output as JSON
        scenario = response_json.get("scenario", "").strip()
        options = response_json.get("options", [])

        if not scenario or len(options) != 4:
            raise ValueError("Invalid JSON format from AI")

        return scenario, options
    except Exception as e:
        print(f"Error parsing AI response: {str(e)}")
        return None, None

@app.route('/scenario/<int:level>', methods=['GET'])
def get_scenario(level):
    """Generate a scenario dynamically based on the crisis level."""
    if level not in LEVELS:
        return jsonify({"error": "Invalid level"}), 404

    prompt = f'''
    Imagine you are a rural woman running a small business or trying to become financially independent.
    Suddenly, a crisis occurs that threatens your ability to sustain yourself. Describe the situation in the
    second person ("you") as if the woman is experiencing it herself. The crisis should be a "{LEVELS[level]}".
    Make the scenario emotionally engaging and very clear.

    Provide exactly four multiple-choice options for how she can respond to the crisis.
    The options should be realistic and relevant to her situation.

    Return the output as a JSON object with the following structure:

    {{
    "scenario": "[A very clear and emotionally engaging situation]",
    "options": [
        "Option 1",
        "Option 2",
        "Option 3",
        "Option 4"
    ]
    }}

    Do NOT include any explanations beyond the scenario and the four choices.
    Do NOT add unnecessary text.
    Do NOT repeat the answer format in the output.
    '''

    try:
        response = model.generate_content(prompt)
        scenario_text = response.text.strip()

        # Extract scenario and response options from JSON
        scenario, options = extract_options_from_json(scenario_text)

        if not scenario or not options:
            return jsonify({"error": "AI response format incorrect, try again."}), 500

        # Generate image based on scenario keywords
        keywords = extract_keywords(scenario)
        image_base64 = generate_image(level)  # Get Base64 encoded image

        return jsonify({
            "scenario": scenario,
            "image_base64": image_base64 if image_base64 else None,
            "response_options": options  # Send extracted response options
        })

    except Exception as e:
        print(f"Error generating scenario: {str(e)}")
        return jsonify({"error": "Failed to generate scenario"}), 500

@app.route('/evaluate', methods=['POST'])
def evaluate_choice():
    """Endpoint to evaluate user's choice using Gemini"""
    data = request.get_json()
    choice = data.get('choice')
    scenario = data.get('scenario')

    if not choice or not scenario:
        return jsonify({"error": "Invalid input"}), 400

    # Prompt for Gemini
    prompt = f"""As a crisis management expert, evaluate this response to an emergency scenario:

    Scenario: {scenario}

    User's Response: {choice}

    Provide a brief, constructive feedback (2-3 sentences) on this choice. Consider:
    1. The immediate safety impact
    2. The long-term consequences
    3. Best practices in emergency response

    Format your response to the user (this is a crisis readiness planner and everything is a simulation).
    Focus on what they did well and/or how they could improve their response.
    Keep it very breif, educational and encouraging. If the answer is incorrect, kindly suggest they try again."""

    try:
        # Generate response using Gemini
        response = model.generate_content(prompt)
        feedback = response.text.strip()

        return jsonify({"feedback": feedback})
    
    except Exception as e:
        print(f"Error generating feedback: {str(e)}")
        return jsonify({
            "error": "Failed to generate feedback",
            "feedback": "We're having trouble evaluating your response. Please try again."
        }), 500

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
