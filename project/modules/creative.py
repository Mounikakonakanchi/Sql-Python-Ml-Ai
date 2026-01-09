import streamlit as st
import random

IDEAS = [
    "Sketch something you see ✏️",
    "Cook a comfort dish 🍲",
    "Write 3 good things about today ✨",
    "Learn a new word and use it 📝",
    "Go for a small walk 🚶‍♀️‍➡️",
    "Have some coffee 🍵",
    "Listen to music 🎼"

]

def get_creative_suggestion():
    return random.choice(IDEAS)

def show_creative_ui():
    if st.button("Give me an idea!"):
        st.success(get_creative_suggestion())
