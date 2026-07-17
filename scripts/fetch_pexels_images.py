#!/usr/bin/env python3
"""Fetch real, verified product photography from the Pexels API.

Every URL in the output map comes back from a live Pexels API call — none
are guessed or hand-typed. Run this before the Cloudinary sync step so
each catalog entity (category/product/bundle/recipe) gets a real photo
that matches its name, instead of the current shared placeholder images.

Usage:
    source .env.development
    python3 scripts/fetch_pexels_images.py
    python3 scripts/fetch_pexels_images.py --export=build/reports/pexels_image_map.json
"""
import json
import os
import sys
import time
import urllib.request
import urllib.parse

PEXELS_SEARCH_URL = "https://api.pexels.com/v1/search"

# id -> search query. Queries are hand-tuned per entity so results are
# visually on-topic (e.g. "cooking oil bottle" beats a bare "oil").
QUERIES = {
    # Categories
    "category_dairy_eggs": "milk eggs dairy",
    "category_bakery": "bakery bread pastries",
    "category_frozen_foods": "ice cream frozen food",
    "category_pantry_staples": "pantry spices cooking oil",
    "category_meat_seafood": "butcher shop meat display",
    # Products
    "product_perrys_ice_cream_banana_800gm": "banana ice cream scoop",
    "product_vanilla_ice_cream_banana_500gm": "vanilla ice cream bowl",
    "product_premium_meat_selection_1kg": "raw beef meat cuts",
    "product_organic_onions_1kg": "fresh onions",
    "product_fresh_tomatoes_1kg": "fresh red tomatoes",
    "product_premium_cooking_oil_1litre": "olive oil pouring glass bottle kitchen",
    "product_sea_salt_premium_grade_500gm": "sea salt crystals macro",
    "product_mixed_spice_collection_250gm": "spices collection",
    "product_fresh_whole_milk_1litre": "milk bottle glass",
    # Bundles
    "bundle_essential_cooking_pack": "cooking ingredients onions oil",
    "bundle_premium_spices": "spices variety jars",
    "bundle_frozen_dessert": "ice cream dessert",
    "bundle_complete_breakfast": "breakfast milk bread eggs table",
    # Recipes
    "recipe_001": "beef stew pot",
    "recipe_002": "sauteed tomatoes and onions skillet",
}


def fetch_one(api_key: str, query: str) -> dict | None:
    url = f"{PEXELS_SEARCH_URL}?{urllib.parse.urlencode({'query': query, 'per_page': 1, 'orientation': 'square'})}"
    req = urllib.request.Request(
        url,
        headers={
            "Authorization": api_key,
            "User-Agent": "Mozilla/5.0 (compatible; ProGroceryImageFetcher/1.0)",
        },
    )
    with urllib.request.urlopen(req, timeout=15) as resp:
        data = json.loads(resp.read().decode())
    photos = data.get("photos") or []
    if not photos:
        return None
    photo = photos[0]
    return {
        "id": photo["id"],
        "url": photo["src"]["large"],
        "urlLarge2x": photo["src"]["large2x"],
        "photographer": photo["photographer"],
        "photographerUrl": photo["photographer_url"],
        "pexelsPageUrl": photo["url"],
    }


def main() -> int:
    api_key = os.environ.get("PEXELS_API_KEY")
    if not api_key:
        print("ERROR: PEXELS_API_KEY not set. Run: source .env.development", file=sys.stderr)
        return 1

    export_path = "build/reports/pexels_image_map.json"
    for arg in sys.argv[1:]:
        if arg.startswith("--export="):
            export_path = arg.split("=", 1)[1]

    results = {}
    failures = []

    for entity_id, query in QUERIES.items():
        try:
            match = fetch_one(api_key, query)
        except Exception as exc:  # noqa: BLE001
            failures.append((entity_id, query, str(exc)))
            continue

        if match is None:
            failures.append((entity_id, query, "no results"))
            continue

        results[entity_id] = {"query": query, **match}
        print(f"  {entity_id:45s} <- \"{query}\" -> {match['url']}")
        time.sleep(0.25)  # stay well under Pexels rate limits

    os.makedirs(os.path.dirname(export_path), exist_ok=True)
    with open(export_path, "w") as f:
        json.dump(
            {
                "generatedAt": time.strftime("%Y-%m-%dT%H:%M:%SZ", time.gmtime()),
                "source": "Pexels API (https://api.pexels.com/v1/search)",
                "entries": results,
            },
            f,
            indent=2,
        )

    print(f"\nFetched {len(results)}/{len(QUERIES)} images.")
    print(f"Map written to: {export_path}")

    if failures:
        print("\nFailures:")
        for entity_id, query, reason in failures:
            print(f"  {entity_id} (\"{query}\"): {reason}")
        return 1

    return 0


if __name__ == "__main__":
    raise SystemExit(main())
