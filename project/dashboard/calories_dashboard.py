import streamlit as st
import altair as alt
import pandas as pd
import json
import os
from datetime import date

def show_calories_chart():
    # Path to calories.json
    DATA_FILE = os.path.join("data", "calories_log.json")

    if not os.path.exists(DATA_FILE):
        st.info("No calorie data found.")
        return

    # Load data
    with open(DATA_FILE, "r", encoding="utf-8") as f:
        data = json.load(f)

    if not data:
        st.info("No calorie data found.")
        return

    df = pd.DataFrame(data)

    # Ensure required columns exist
    for col in ['date', 'recipe', 'calories']:
        if col not in df.columns:
            st.error(f"Column '{col}' missing in calories.json")
            return

    # Clean columns
    df['recipe'] = df['recipe'].astype(str).str.strip()
    df['date'] = df['date'].astype(str).str.strip()
    df['calories'] = pd.to_numeric(df['calories'], errors='coerce').fillna(0)

    # Filter only today's entries
    today_str = date.today().isoformat()
    df_today = df[df['date'] == today_str]

    if df_today.empty:
        st.info("No calories logged for today.")
        return

    # Sort by calories descending
    df_today = df_today.sort_values('calories', ascending=False)

    # Plot as bar chart with recipe names on X-axis
    chart = alt.Chart(df_today).mark_bar(color='green',size=20).encode(
        x=alt.X('recipe:N', title='Recipe', sort=None),  # sort=None preserves JSON order
        y=alt.Y('calories:Q', title='Calories'),
        tooltip=['recipe:N', 'calories:Q', 'date:N']
    ).properties(
        title=f"Calories Consumed Today ({today_str})",
        width=700,
        height=400
    )

    st.altair_chart(chart, use_container_width=True)
