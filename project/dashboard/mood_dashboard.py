import streamlit as st
import altair as alt
import pandas as pd
import json
import os
from datetime import date

def show_mood_chart():
    DATA_FILE = os.path.join("data", "mood.json")

    if not os.path.exists(DATA_FILE):
        st.info("No mood data found.")
        return

    with open(DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not data:
        st.info("No mood data found.")
        return

    df = pd.DataFrame(data)

    # Ensure required columns exist
    for col in ['date', 'time', 'score', 'note']:
        if col not in df.columns:
            st.error(f"Column '{col}' missing in mood.json")
            return
        df[col] = df[col].astype(str).str.strip()

    # Convert score to numeric
    df['score'] = pd.to_numeric(df['score'], errors='coerce').fillna(0)

    # Fill missing time with 12:00 AM (for AM/PM format)
    df['time'] = df['time'].fillna('12:00 AM')

    # Combine date and time to datetime (AM/PM format)
    df['datetime'] = pd.to_datetime(df['date'] + ' ' + df['time'], format='%Y-%m-%d %I:%M %p', errors='coerce')

    # Drop rows with invalid datetime
    df = df.dropna(subset=['datetime'])

    # Filter only today's entries
    today_str = date.today().isoformat()
    df_today = df[df['date'] == today_str]

    if df_today.empty:
        st.info("No mood logged for today.")
        return

    # Sort by datetime
    df_today = df_today.sort_values('datetime')

    # Plot as bar chart (single green color)
    chart = alt.Chart(df_today).mark_bar(color='green').encode(
        x=alt.X('datetime:T', title='Time'),
        y=alt.Y('score:Q', title='Mood Score (0-10)'),
        tooltip=['time', 'score', 'note']
    ).properties(
        title=f"Today's Mood Logs ({today_str})",
        width=700,
        height=400
    )

    st.altair_chart(chart, use_container_width=True)
