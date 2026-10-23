"""Asset catalogue. SINGLE SOURCE OF TRUTH = backend/asset_manifest.json, which is a copy of
assets/nova/manifest.json produced by tools/process_assets.py. Do not hand-edit ids here:
update the art / script, regenerate the manifest, copy it to backend/asset_manifest.json."""
import json
from pathlib import Path

MANIFEST = json.loads((Path(__file__).parent / "asset_manifest.json").read_text(encoding="utf-8"))

BACKDROPS = set(MANIFEST["backdrops"])
ACTORS = MANIFEST["actors"]                       # id -> {group, poses, pose_map}
CHARACTERS = set(ACTORS)                          # validator name for "things that can stand in a slot"
PROPS = set(MANIFEST["props"])
COUNTABLE_PROPS = set(MANIFEST["countable_props"])  # safe to use with question.counts_prop
EXPRESSIONS = {"idle", "happy", "curious", "encouraging", "surprised"}
MOTIONS = {"walk_in_left", "walk_in_right", "slide_in", "pop_in_staggered", "fade_in",
           "idle_bounce", "jump", "head_tilt", "shake", "wave", "point_at"}
ACTOR_SLOTS = {"left", "center", "right"}
PROP_SLOTS = {"ground_left", "ground_center", "ground_right", "sky", "hand"}
SFX = {"sfx_cheer", "sfx_oops", "sfx_pop", "sfx_whoosh"}   # no audio files yet: client must ignore missing sfx
TIMELINE_ACTIONS = {"narrate", "show_question", "point_at", "play", "set_expression"}
QUESTION_TYPES = {"voice_input", "match_following", "spot_item", "fill_blanks"}
LANGS = ("mr", "en")
MAX_ACTORS = 3
MAX_SCENES = 6
MAX_WORDS_PER_SCENE = {1: 25, 2: 30, 3: 40, 4: 50}   # per language, by grade
BANNED_WORDS_EN = {"kill", "die", "dead", "blood", "ghost", "monster", "gun", "fight", "hurt", "scary"}


def pose_for(actor_id, expression):
    """expression -> pose name for an actor; falls back to first available pose."""
    a = ACTORS[actor_id]
    pose = a["pose_map"].get(expression or "idle")
    return pose if pose in a["poses"] else a["poses"][0]
