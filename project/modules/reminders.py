import streamlit as st
import os
from datetime import date
from .storage import load_json, save_json

BASE_DIR = os.path.dirname(os.path.dirname(__file__))    # Path to reminders.json
REMINDER_FILE = os.path.join(BASE_DIR, "data", "reminders.json")

#loading and saving data to json
def add_reminder(text, time):
    reminders = load_json(REMINDER_FILE, default=[])

    if not isinstance(reminders, list):
        reminders = []

    reminders.append({
        "date": str(date.today()),
        "time": time,
        "text": text
    })

    save_json(REMINDER_FILE, reminders)


def get_today_reminders():
    reminders = load_json(REMINDER_FILE, default=[])
    today = str(date.today())

    return [
        r for r in reminders
        if isinstance(r, dict) and r.get("date") == today
    ]

#streamlit ui
def show_reminders_ui():
    st.subheader("Reminders ⏰ ")

    task = st.text_input("Task")
    col1, col2 = st.columns([2,1])
    with col1:
        time_input = st.text_input("Time (HH:MM)")
    with col2:
        am_pm = st.selectbox("AM/PM", ["AM", "PM"])

    time = f"{time_input} {am_pm}" if time_input else ""

    if st.button("Add Reminder"):
        if task and time_input:
            add_reminder(task, time)
            st.success(f"Reminder added for {time}!")
        else:
            st.warning("Enter task and time")

    st.markdown("**Today's Reminders**")

    reminders = get_today_reminders()
    if reminders:
        for r in reminders:
            st.write(f"{r['text']} — ⏰ {r['time']}")
    else:
        st.write("No reminders today.")
