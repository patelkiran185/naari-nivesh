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
model = genai.GenerativeModel('gemini-1.5-pro')
# GEMINI_API_KEY = os.getenv('GOOGLE_API_KEY') 

GEMINI_API_KEY="AIzaSyDGlfkDJJofi332TBSmSkiyJP0Qy3i8JUI"

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
    print(ai_response)
    try:
        if not ai_response:
            raise ValueError("AI response is empty")

        # Remove Markdown formatting (```json and ```)
        ai_response = re.sub(r"^```json\s*|\s*```$", "", ai_response, flags=re.DOTALL).strip()

        # Parse JSON
        response_json = json.loads(ai_response)

        # Extract scenario and options
        scenario = response_json.get("scenario", "").strip()
        options = response_json.get("options", [])

        if not scenario or not isinstance(options, list) or len(options) != 4:
            raise ValueError("Invalid JSON format: Missing scenario or incorrect number of options.")

        return scenario, options
    
    except Exception as e:
        print(f"Error parsing AI response: {str(e)}")
        return None, None

@app.route('/scenario/<int:level>', methods=['GET'])
def get_scenario(level):
    """Generate a scenario dynamically based on the crisis level."""
    if level not in LEVELS:
        return jsonify({"error": "Invalid level"}), 404

    language = request.args.get('language', 'English')  # Default to English

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
    **VALID JSON FORMAT***
    '''

    if language == "Hindi":
        prompt += "\n\nGenerate the response in Hindi."

    if language == "Telugu":
        prompt += "\n\nGenerate the response in Telugu."

    if language == "Tamil":
        prompt += "\n\nGenerate the response in Tamil."

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
    language = data.get('language', 'English')  # Default to English

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
    Keep it very brief, educational and encouraging. If the answer is incorrect, kindly suggest they try again."""

    if language == "Hindi":
        prompt += "\n\nGenerate the response in Hindi."

    if language == "Telugu":
        prompt += "\n\nGenerate the response in Telugu."

    if language == "Tamil":
        prompt += "\n\nGenerate the response in Tamil."

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

# Predefined Lessons
LESSONS = {
    "beginner": [
        {"title": "Understanding Money", "description": "Learn the basics of money, currency, and financial transactions."},
        {"title": "Creating a Budget", "description": "How to create a simple budget to manage income and expenses."},
        {"title": "Savings & Emergency Funds", "description": "Understanding the importance of savings and emergency funds."},
        {"title": "Basic Banking", "description": "How to open and use a bank account for financial security."},
        {"title": "Understanding Credit & Debt", "description": "Basics of credit, loans, and how to avoid debt traps."}
    ],
    "intermediate": [
        {"title": "Smart Spending Habits", "description": "How to prioritize spending and avoid unnecessary expenses."},
        {"title": "Different Types of Bank Accounts", "description": "Savings, current, and fixed deposit accounts explained."},
        {"title": "Introduction to Investing", "description": "Learn about stocks, bonds, and mutual funds."},
        {"title": "Understanding Interest Rates", "description": "How interest rates impact savings and loans."},
        {"title": "Managing Loans Wisely", "description": "How to take loans responsibly and repay efficiently."}
    ],
    "advanced": [
        {"title": "Building a Long-Term Investment Plan", "description": "How to create a sustainable investment strategy."},
        {"title": "Tax Planning & Benefits", "description": "Understanding tax structures and savings options."},
        {"title": "Stock Market Basics", "description": "How to analyze stocks and invest wisely."},
        {"title": "Retirement Planning", "description": "Planning financial security for retirement."},
        {"title": "Entrepreneurship & Financial Growth", "description": "How to start and manage a business financially."}
    ]
}

@app.route("/selected_level", methods=["POST"])
def selected_level():
    data = request.get_json()
    if not data or "level" not in data:
        return jsonify({"error": "Invalid request, level is required"}), 400

    level = data["level"].lower()
    if level not in LESSONS:
        return jsonify({"error": "Invalid level"}), 400

    return jsonify({"message": f"Level {level} selected successfully"}), 200


# Endpoint to Get Lessons Based on Level
@app.route('/lessons/<level>', methods=['GET'])
def get_lessons(level):
    if level not in LESSONS:
        return jsonify({"error": "Invalid level"}), 404

    language = request.args.get('language', 'English')  # Default to English

    lessons = LESSONS.get(level, [])
    
    if language == "Hindi":
        # Modify the prompt to generate content in Hindi
        for lesson in lessons:
            lesson["title"] = f"{lesson['title']} (हिंदी)"
            lesson["description"] = f"{lesson['description']} (हिंदी)"

    if language == "Tamil":
        # Modify the prompt to generate content in Tamil
        for lesson in lessons:
            lesson["title"] = f"{lesson['title']} (தமிழ்)"
            lesson["description"] = f"{lesson['description']} (தமிழ்)"

    if language == "Telugu":
        # Modify the prompt to generate content in Telugu
        for lesson in lessons:
            lesson["title"] = f"{lesson['title']} (తెలుగు)"
            lesson["description"] = f"{lesson['description']} (తెలుగు)"


    return jsonify(lessons)

@app.route('/generate_lesson/<topic>', methods=['GET'])
def generate_lesson(topic):
    try:
        language = request.args.get('language', 'English')  # Default to English

        # Prompt for lesson content
        prompt_lesson = f'''
        Generate a detailed educational lesson on the topic: "{topic}". Explain in simple terms, include examples and practical tips.

        Structure it as follows:
        1. **Introduction**: Explain why this topic is important.
        2. **Key Concepts**: Provide 3-5 key points in bullet format.
        3. **Real-Life Example**: Show a practical scenario where this is useful.
        4. **Conclusion & Next Steps**: Summarize key takeaways and suggest what the user should do next.

        Do NOT generate any quiz questions in this response.
        Return ONLY the lesson content in simple markdown format.
        '''

        if language == "Hindi":
            prompt_lesson += "\n\nGenerate the response in Hindi."

        if language == "Telugu":
            prompt_lesson += "\n\nGenerate the response in Telugu."  # Fixed: Use prompt_lesson instead of prompt

        if language == "Tamil":
            prompt_lesson += "\n\nGenerate the response in Tamil."  # Fixed: Use prompt_lesson instead of prompt

        # Generate lesson content using Gemini API
        response = model.generate_content(prompt_lesson)
        lesson_content = response.text.strip()

        # Prompt for quiz questions
        prompt_quiz = f'''
        Create exactly five multiple-choice questions (MCQs) based on the lesson topic "{topic}". 
        Each question should be related to the lesson content and have four answer choices.

        Return the output as a JSON array with the following structure:

        [
            {{
              "question": "[MCQ 1 question]",
              "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
              ],
              "answer": "[Correct option]"
            }},
            {{
              "question": "[MCQ 2 question]",
              "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
              ],
              "answer": "[Correct option]"
            }},
            {{
              "question": "[MCQ 3 question]",
              "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
              ],
              "answer": "[Correct option]"
            }},
            {{
              "question": "[MCQ 4 question]",
              "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
              ],
              "answer": "[Correct option]"
            }},
            {{
              "question": "[MCQ 5 question]",
              "options": [
                "Option 1",
                "Option 2",
                "Option 3",
                "Option 4"
              ],
              "answer": "[Correct option]"
            }}
        ]

        Do NOT include any explanations or unnecessary text. Ensure that the response is a **valid JSON array** with no additional text.
        '''

        if language == "Hindi":
            prompt_quiz += "\n\nGenerate the response in Hindi."

        if language == "Telugu":
            prompt_quiz += "\n\nGenerate the response in Telugu."  # Fixed: Use prompt_quiz instead of prompt

        if language == "Tamil":
            prompt_quiz += "\n\nGenerate the response in Tamil."  # Fixed: Use prompt_quiz instead of prompt

        # Generate quiz questions using Gemini API
        quiz_response = model.generate_content(prompt_quiz)
        quiz_content = quiz_response.text.strip()

        # Parse quiz content
        try:
            if "```json" in quiz_content:
                quiz_content = quiz_content.replace("```json", "").replace("```", "").strip()
            quiz_questions = json.loads(quiz_content)
        except Exception as e:
            print(f"Error parsing quiz content: {e}")
            quiz_questions = []

        return jsonify({
            "content": lesson_content,
            "mcqs": quiz_questions
        })
    except Exception as e:
        return jsonify({"error": str(e)}), 500
    
if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000, debug=True)
