import streamlit as st
import altair as alt
import pandas as pd
import json
import os
from datetime import date

def show_study_chart():
    DATA_FILE = os.path.join("data", "study.json")

    if not os.path.exists(DATA_FILE):
        st.info("No study data found.")
        return

    with open(DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not data:
        st.info("No study data found.")
        return

    df = pd.DataFrame(data)

    # Strip spaces and ensure columns exist
    for col in ['date', 'time', 'duration', 'subject']:
        if col not in df.columns:
            st.error(f"Column '{col}' missing in study.json")
            return
        df[col] = df[col].astype(str).str.strip()

    # Convert duration to numeric
    df['duration'] = pd.to_numeric(df['duration'], errors='coerce').fillna(0)

    # Combine date and time to datetime
    df['datetime'] = pd.to_datetime(df['date'] + ' ' + df['time'], errors='coerce')

    # Drop rows with invalid datetime
    df = df.dropna(subset=['datetime'])

    # Filter only today
    today_str = date.today().isoformat()
    df_today = df[df['date'] == today_str]

    if df_today.empty:
        st.info("No study sessions logged for today.")
        return

    # Sort by datetime
    df_today = df_today.sort_values('datetime')

    # Plot
    chart = alt.Chart(df_today).mark_bar(color='green').encode(
        x=alt.X('datetime:T', title='Time'),
        y=alt.Y('duration:Q', title='Duration (minutes)'),
        tooltip=['subject', 'time', 'duration']
    ).properties(
        title=f"Today's Study Sessions ({today_str})",
        width=700,
        height=400
    )

    st.altair_chart(chart, use_container_width=True)
