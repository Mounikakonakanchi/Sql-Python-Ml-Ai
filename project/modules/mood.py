import os
import streamlit as st
from datetime import date, datetime
from modules.storage import load_json, save_json  # absolute import

# Absolute path to mood.json
PROJECT_ROOT = os.path.dirname(os.path.dirname(__file__))
MOOD_FILE = os.path.join(PROJECT_ROOT, "data", "mood.json")
os.makedirs(os.path.dirname(MOOD_FILE), exist_ok=True)

# Log Mood 
def log_mood(score, note=""):
    moods = load_json(MOOD_FILE, default=[])
    if not isinstance(moods, list):
        moods = []

    current_time = datetime.now().strftime("%I:%M %p")
    new_entry = {
        "date": str(date.today()),
        "time": current_time,
        "score": score,
        "note": note
    }
    moods.append(new_entry)
    save_json(MOOD_FILE, moods)

    # Update session state for immediate display
    if "today_moods" not in st.session_state:
        st.session_state.today_moods = []
    st.session_state.today_moods.append(new_entry)

# Get Today's Mood 
def get_today_mood():
    if "today_moods" in st.session_state:
        return st.session_state.today_moods
    #load from JSON
    moods = load_json(MOOD_FILE, default=[])
    today = str(date.today())
    today_moods = []
    for m in moods:
        if isinstance(m, dict) and m.get("date") == today:
            if not m.get("time"):
                m["time"] = "00:00"
            today_moods.append(m)
    st.session_state.today_moods = today_moods
    return today_moods

#  Streamlit UI 
def show_mood_ui():
    st.header("📝 Mood Tracker")

    # Input fields
    score = st.slider("Mood Score (0=bad, 10=great)", 0, 10, 5)
    note = st.text_input("Notes (optional)")

    # Log mood button
    if st.button("Log Mood"):
        log_mood(score, note)
        st.success(f"Mood logged at {datetime.now().strftime('%I:%M %p')}!")

    # Show recent entries
    st.markdown("**Recent Entries Today**")
    moods = get_today_mood()
    if moods:
        for m in moods[-10:]:
            time_str = m.get('time', "00:00")
            st.write(f"{m.get('date')} — ⏰{time_str} — {m.get('score')} — {m.get('note','')}")
    else:
        st.write("No mood logged today.")
