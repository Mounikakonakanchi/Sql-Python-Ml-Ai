import os
import streamlit as st
import json

# Path to recipes.json inside data folder
RECIPES_FILE = "data/recipes.json"


# Loading recipes
def load_recipes():       
    if not os.path.exists(RECIPES_FILE):
        st.warning(f"{RECIPES_FILE} not found! No recipes available.")
        return []
    
    try:
        with open(RECIPES_FILE, "r", encoding="utf-8") as f:
            data = json.load(f)
            if isinstance(data, list):
                return data
            st.error(f"{RECIPES_FILE} is invalid. It should be a list of recipes.")
            return []
    except json.JSONDecodeError:
        st.error(f"{RECIPES_FILE} is not valid JSON!")
        return []


# Search for recipes
def search_by_ingredient_or_title(query):
    query = query.lower().strip()
    recipes = load_recipes()
    results = []
    for r in recipes:
        if isinstance(r, dict):
            ingredients = [i.lower().strip() for i in r.get("ingredients", [])]
            name_lower = r.get("name", "").lower().strip()
            if query in name_lower or any(query in i for i in ingredients):
                results.append(r["name"])
    return results


# Get recipe steps and calories
def get_recipe_steps(name):
    name = name.lower().strip()
    recipes = load_recipes()
    for r in recipes:
        if r.get("name", "").lower().strip() == name:
            return r.get("steps", []), r.get("calories", 0)
    return [], 0


# Streamlit UI
def show_cooking_ui():
    st.title("Cooking Companion 🍳")

    if "search_query" not in st.session_state:
        st.session_state.search_query = ""
    if "search_results" not in st.session_state:
        st.session_state.search_results = []
    if "selected_recipe" not in st.session_state:
        st.session_state.selected_recipe = ""

    # Input for search
    query = st.text_input("Search Recipes by Ingredient or Name", value=st.session_state.search_query)

    if st.button("Search Recipes"):
        st.session_state.search_query = query
        st.session_state.search_results = search_by_ingredient_or_title(query)
        st.session_state.selected_recipe = ""  # reset selected recipe

    # Show search results
    if st.session_state.search_results:
        st.write("**Recipes Found:**")
        st.session_state.selected_recipe = st.selectbox(
            "Select a recipe to see steps",
            st.session_state.search_results,
            index=st.session_state.search_results.index(st.session_state.selected_recipe)
            if st.session_state.selected_recipe in st.session_state.search_results
            else 0
        )

    # Show steps, calories
    if st.session_state.selected_recipe:
        steps, calories = get_recipe_steps(st.session_state.selected_recipe)
        if steps:
            st.write(f"**Steps for {st.session_state.selected_recipe}:**")
            for i, s in enumerate(steps, 1):
                st.write(f"{i}. {s}")
            st.write(f"🔥 Calories: {calories}")
