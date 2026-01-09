import sys
import os

# Add project root to Python path BEFORE any module imports
PROJECT_ROOT = os.path.dirname(__file__)
if PROJECT_ROOT not in sys.path:
    sys.path.append(PROJECT_ROOT)

import streamlit as st

# Import modules AFTER path is set
from modules import mood, study, reminders,cooking, creative, chatbot

st.title("📌 Personal Assistant")

with st.expander("Mood Tracker 😊"):
    mood.show_mood_ui()

with st.expander("Study Tracker 📚"):
    study.show_study_ui()

with st.expander("Reminders ⏰"):
    reminders.show_reminders_ui()

with st.expander("Cooking Companion 🍳"):
    cooking.show_cooking_ui()

with st.expander("Creativity Booster ✨"):
    creative.show_creative_ui()

with st.expander("Insight Bot 🤖"):
    chatbot.show_chatbot_ui()

