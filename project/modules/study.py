import streamlit as st
import os
from datetime import date, datetime
from .storage import load_json, save_json

# Absolute path to data/study.json
BASE_DIR = os.path.dirname(os.path.dirname(__file__))
STUDY_FILE = os.path.join(BASE_DIR, "data", "study.json")

#loading and saving data to json
def log_study(subject, duration):
    sessions = load_json(STUDY_FILE, default=[])

    if not isinstance(sessions, list):
        sessions = []

    sessions.append({
        "date": str(date.today()),
        "time": datetime.now().strftime("%I:%M %p"),
        "subject": subject,
        "duration": duration
    })

    save_json(STUDY_FILE, sessions)


def get_today_study():
    sessions = load_json(STUDY_FILE, default=[])
    today = str(date.today())

    return [
        s for s in sessions
        if isinstance(s, dict) and s.get("date") == today
    ]

#streamlit 
def show_study_ui():
    st.subheader("📘 Study Tracker")

    subject = st.text_input("Subject")
    duration = st.number_input("Duration (minutes)", min_value=1)

    if st.button("Log Study"):
        if subject and duration > 0:
            log_study(subject, duration)
            st.success("Study session logged!")
        else:
            st.warning("Enter subject and duration")

    st.markdown("**Today's Study Sessions**")

    sessions = get_today_study()
    if sessions:
        for s in sessions[-5:]:
            time = s.get("time", "Unknown")
            st.write(
                f"{s.get('date')} — ⏰ {time} — "
                f"{s.get('subject')} — {s.get('duration')} min"
            )
    else:
        st.write("No study logged today.")
