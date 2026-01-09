import os
import sys
import json
import datetime
import streamlit as st

# path of project
PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))
if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)

# importing modules
from modules.storage import load_json, save_json
from modules.mood import get_today_mood
from modules.study import get_today_study
from modules.reminders import get_today_reminders
from modules.creative import get_creative_suggestion

# importing dashboards
from dashboard.mood_dashboard import show_mood_chart
from dashboard.calories_dashboard import show_calories_chart
from dashboard.study_dashboard import show_study_chart


# path of json files
CHAT_LOG = os.path.join(PROJECT_ROOT, "data", "chat.json")
CAL_LOG_FILE = os.path.join(PROJECT_ROOT, "data", "calories_log.json")
RECIPES_FILE = os.path.join(PROJECT_ROOT, "data", "recipes.json")
DAILY_CAL_LIMIT = 1300

# loading and saving data to json
def safe_load_json(path, default=None):
    if default is None:
        default = []
    if not os.path.exists(path) or os.path.getsize(path) == 0:
        return default
    try:
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            return json.load(f)
    except (json.JSONDecodeError, UnicodeDecodeError):
        return default

#getting caolories from recipes
def get_recipe_calories(meal_name):
    recipes = safe_load_json(RECIPES_FILE, [])
    meal_name = meal_name.lower().strip()
    for r in recipes:
        if r.get("name","").lower().strip() == meal_name:
            try:
                return int(r.get("calories",0))
            except ValueError:
                return 0
    return None

#storing calories in json
def log_calories(meal_name, calories=0):
    today = datetime.date.today().isoformat()
    log = safe_load_json(CAL_LOG_FILE, [])
    log.append({"recipe": meal_name, "calories": calories, "date": today})
    os.makedirs(os.path.dirname(CAL_LOG_FILE), exist_ok=True)
    with open(CAL_LOG_FILE, "w", encoding="utf-8") as f:
        json.dump(log, f, indent=2, ensure_ascii=False)
    return calories

#caluclating total calories
def get_today_calories():
    today = datetime.date.today().isoformat()
    log = safe_load_json(CAL_LOG_FILE, [])
    total = 0
    for e in log:
        if e.get("date","") == today:
            try:
                total += int(e.get("calories",0))
            except ValueError:
                total += 0
    return total

#feedback for calories
def calorie_feedback():
    total = get_today_calories()
    if total > DAILY_CAL_LIMIT:
        return f"🔥 You have eaten {total} calories today. Try to stay under {DAILY_CAL_LIMIT}."
    return f"✅ You have eaten {total} calories today. Keep it up!"

# reply from insightbot
def reply(msg):
    msg_lower = msg.lower().strip()

    # Logging food
    if msg_lower.startswith("i had "):
        meal_name = msg[6:].strip()
        calories = get_recipe_calories(meal_name)
        if calories is None:
            return f"❌ '{meal_name}' not found in recipes."
        log_calories(meal_name, calories)
        return f"🍽 Logged {calories} calories for {meal_name}."

    # Calories info
    if "calorie" in msg_lower or "calories" in msg_lower:
        return calorie_feedback()

    # Mood info
    if "mood" in msg_lower:
        mood = get_today_mood()
        if mood:
            try:
                score = int(mood[-1].get("score",0))
            except ValueError:
                score = 0
            return f"Your mood today: {score}/10"
        return "No mood logged today."

    # Study info
    if "study" in msg_lower:
        study = get_today_study()
        total = 0
        if study:
            for s in study:
                try:
                    total += int(s.get("duration",0))
                except ValueError:
                    total += 0
        return f"You studied {total} minutes today." if total else "No study logged today."

    # Reminders
    if "reminder" in msg_lower or "appointment" in msg_lower:
        reminders = get_today_reminders()
        if reminders:
            return "\n".join(f"- {r.get('text','Unknown')} at {r.get('time','Unknown')}" for r in reminders)
        return "No reminders today."

    # Creative ideas
    if "idea" in msg_lower or "creative" in msg_lower:
        return get_creative_suggestion()

    # Summary
    if msg_lower in ["summary", "today"]:
        return (
            "📊 **Today Summary**\n"
            f"- Calories: {get_today_calories()}\n"
            f"- {calorie_feedback()}"
        )

    return "Try asking about calories, mood, study, reminders, creative ideas, or summary."

# Streamlit UI 
def show_chatbot_ui():
    st.write("💬 Chat with your assistant")
    history = load_json(CHAT_LOG, default=[])

    for h in history[-10:]:
        role = "You" if h.get("role","") == "user" else "Assistant"
        st.write(f"**{role}:** {h.get('text','')}")

    if "chat_input" not in st.session_state:
        st.session_state.chat_input = ""

    st.session_state.chat_input = st.text_input("Your message", st.session_state.chat_input)

    if st.button("Send Message"):
        msg = st.session_state.chat_input.strip()
        if msg:
            history.append({"role":"user","text":msg})
            response = reply(msg)
            history.append({"role":"bot","text":response})
            st.write(response)

            #  loading dashboards 
            msg_lower = msg.lower()
            if "mood" in msg_lower and ("data visualization" in msg_lower or "chart" in msg_lower or "dashboard" in msg_lower):
                show_mood_chart()
            if "calorie" in msg_lower and ("data visualization" in msg_lower or "chart" in msg_lower or "dashboard" in msg_lower):
                show_calories_chart()
            if "study" in msg_lower and ("data visualization" in msg_lower or "chart" in msg_lower or "dashboard" in msg_lower):
                show_study_chart()
            save_json(CHAT_LOG, history)

            st.session_state.chat_input = ""
