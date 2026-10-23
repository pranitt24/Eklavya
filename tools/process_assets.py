"""Turns the raw Gemini exports into the clean asset pack.
Run:  python tools/process_assets.py <raw_dir_with_ch_and_bg> <out_dir>
Expects <raw>/ch/*.png (sprites) and <raw>/bg/background_assets/* (backgrounds). Needs Pillow, numpy, scipy."""
import json, os, shutil, sys
from collections import defaultdict
import numpy as np
from PIL import Image
from scipy import ndimage

RAW = sys.argv[1] if len(sys.argv) > 1 else "/tmp/a"
OUT = sys.argv[2] if len(sys.argv) > 2 else "nova_assets"


def fix_grey(im):
    """Father sprites ship with a semi-transparent grey (127,127,127,~200) box. Flood from the edges and clear it."""
    a = np.array(im.convert("RGBA")).astype(int)
    grey = (abs(a[..., 0] - 127) < 10) & (abs(a[..., 1] - 127) < 10) & (abs(a[..., 2] - 127) < 10) & (a[..., 3] > 100)
    lab, _ = ndimage.label(grey)
    edge = set(lab[0, :]) | set(lab[-1, :]) | set(lab[:, 0]) | set(lab[:, -1]); edge.discard(0)
    mask = np.isin(lab, list(edge))
    mask = ndimage.binary_dilation(mask, iterations=1) & (grey | (a[..., 3] < 255))
    a[mask, 3] = 0
    return Image.fromarray(a.astype("uint8"), "RGBA")


SPRITES = [  # (raw filename stem, clean id, group)
 ("standngboy","char_boy_standing","characters"),("jumping_boy","char_boy_jumping","characters"),("jumping_boy_frontvew","char_boy_jumping_front","characters"),
 ("pointing_boy","char_boy_pointing","characters"),("shocked_boy","char_boy_shocked","characters"),("thinking_boy","char_boy_thinking","characters"),
 ("side_img_boy","char_boy_side","characters"),("side_running_boy","char_boy_running","characters"),("walking_side_img_boy","char_boy_walking","characters"),
 ("standing_girl","char_girl_standing","characters"),("jumping_girl","char_girl_jumping","characters"),("jumping_frontview_girl","char_girl_jumping_front","characters"),
 ("thinking_girl","char_girl_thinking","characters"),("waving_girl","char_girl_waving","characters"),("side_img_girl","char_girl_side","characters"),
 ("running_side_girl","char_girl_running","characters"),("walking_img_girl","char_girl_walking","characters"),("walking_side_img_girl","char_girl_walking_side","characters"),
 ("standing_mother","char_mother_standing","characters"),("jumping_mother","char_mother_jumping","characters"),("teaching_mother","char_mother_teaching","characters"),
 ("thinking_mother","char_mother_thinking","characters"),("walking_mother","char_mother_walking","characters"),
 ("standing_father","char_father_standing","characters"),("happy_father","char_father_happy","characters"),("jumping_father","char_father_jumping","characters"),
 ("thinking_father","char_father_thinking","characters"),("waving_father","char_father_waving","characters"),
 ("standing_grandfather","char_grandmother_standing","characters"),("happy_grandfather","char_grandfather_happy","characters"),("angry_grandfather","char_grandfather_angry","characters"),
 ("teaching_grandfather","char_grandfather_teaching","characters"),("waving_grandfather","char_grandmother_waving","characters"),
 ("reading_book_grandfather","char_grandmother_reading","characters"),("grandfather_standingbook","char_grandfather_holding_book","characters"),
 ("teaching_grandmother","char_grandmother_teaching","characters"),("walking_grandmother","char_grandmother_walking","characters"),
 ("standing_postman","char_postman_standing","characters"),("waving_postman","char_postman_waving","characters"),("reading_postman","char_postman_reading","characters"),
 ("standingshopkeeper","char_shopkeeper_standing","characters"),("wavingshopkeeper","char_shopkeeper_waving","characters"),("welcomingshopkepper","char_shopkeeper_welcoming","characters"),
 ("measuringweightshopkepper","char_shopkeeper_weighing","characters"),("writingshopperinbook","char_shopkeeper_writing","characters"),
 ("holdingvegetablesshopper","char_shopper_vegetables","characters"),
 ("cow","animal_cow_standing","animals"),("walking_cow","animal_cow_walking","animals"),("eating_cow","animal_cow_eating","animals"),("shoutng_cow","animal_cow_calling","animals"),
 ("sleepngcow","animal_cow_sleeping","animals"),("dog","animal_dog_standing","animals"),("sleepngdog","animal_dog_sleeping","animals"),
 ("parot","animal_parrot_perched","animals"),("flyngparroat","animal_parrot_flying","animals"),("chllyparroat","animal_parrot_chilli","animals"),
 ("sparow1","animal_sparrow_perched","animals"),("flyngsparow","animal_sparrow_flying","animals"),("chrpngsaprow","animal_sparrow_chirping","animals"),
 ("normalfish","animal_fish_normal","animals"),("smilingfish","animal_fish_smiling","animals"),("jumpingfish","animal_fish_jumping","animals"),
 ("bubblingfish","animal_fish_bubbling","animals"),("goinginwaterfish","animal_fish_diving","animals"),
 ("10rupeenote","prop_note_10","props"),("50rupee","prop_note_50","props"),("100rupee","prop_note_100","props"),("500rupee","prop_note_500","props"),
 ("rupee_gold","prop_coin_gold","props"),("smallpile_coins","prop_coins_small","props"),("moderate_pileofgold","prop_coins_medium","props"),("largepilegold","prop_coins_large","props"),
 ("pots","prop_pots","props"),("lanten","prop_lantern","props"),("glob","prop_globe","props"),("cart","prop_cart","props"),("bench","prop_bench","props"),
 ("bookstand","prop_bookstand","props"),("board","prop_board_marathi","props"),("posterboard","prop_noticeboard","props"),
 ("tree","env_banyan_tree","environment"),("well","env_well","environment"),("waterpump","env_handpump","environment"),("tractor","env_tractor_front","environment"),
 ("backviewtractor","env_tractor_back","environment"),("sideviewtrator","env_tractor_side","environment"),("frontviewbus","env_bus_front","environment"),
 ("backviewbus","env_bus_back","environment"),("sideviewbus","env_bus_side","environment"),("sideviewbus2","env_bus_side2","environment"),("sidebackview","env_bus_side_back","environment"),
]
BACKGROUNDS = [("banyan_tree","bg_banyan_tree"),("cowshed","bg_cowshed"),("farm","bg_farm"),("mango_trees","bg_mango_trees"),("river","bg_river"),
 ("river_bank","bg_river_bank"),("temple_area","bg_temple"),("village_handpump","bg_handpump"),("village_house_courtyard","bg_house_courtyard"),
 ("village_market","bg_market"),("village_overview","bg_village_overview"),("village_road","bg_village_road"),("village_school","bg_school")]

manifest = {"version": 1, "note": "generated by tools/process_assets.py", "assets": []}
for stem, cid, group in SPRITES:
    im = Image.open(f"{RAW}/ch/{stem}.png").convert("RGBA")
    fixed = "father" in stem
    if fixed:
        im = fix_grey(im)
    bbox = im.getbbox()
    if bbox:
        im = im.crop(bbox)
    im.save(f"{OUT}/{group}/{cid}.webp", "WEBP", quality=90, method=6)
    manifest["assets"].append(dict(id=cid, group=group, file=f"{group}/{cid}.webp", w=im.width, h=im.height,
                                   low_res=im.height < 300, bg_fixed=fixed))
for stem, cid in BACKGROUNDS:
    f = [x for x in os.listdir(f"{RAW}/bg/background_assets") if x.startswith(stem + ".")][0]
    im = Image.open(f"{RAW}/bg/background_assets/{f}").convert("RGB").resize((1280, 720), Image.LANCZOS)
    im.save(f"{OUT}/backgrounds/{cid}.webp", "WEBP", quality=82, method=6)
    manifest["assets"].append(dict(id=cid, group="backgrounds", file=f"backgrounds/{cid}.webp", w=1280, h=720))
shutil.copy(f"{RAW}/ch/shopkeeper.png", f"{OUT}/_unsorted/shopkeeper_sheet.png")  # a multi-pose sheet, not a sprite

poses = defaultdict(list)
for a in manifest["assets"]:
    if a["group"] in ("characters", "animals"):
        parts = a["id"].split("_")
        poses[f"{parts[0]}_{parts[1]}"].append("_".join(parts[2:]))
manifest["actors_and_poses"] = dict(poses)
json.dump(manifest, open(f"{OUT}/manifest.json", "w"), indent=2)
print(len(manifest["assets"]), "assets")
for k, v in poses.items():
    print(k, v)


# ---------------------------------------------------------------------------
# Scene config: single source of truth shared by backend/catalog.py and the Flutter client.
# `expression` (contract) -> pose (art). Missing poses fall back to the actor's first pose.
# ---------------------------------------------------------------------------
EXPR = ["idle", "happy", "curious", "encouraging", "surprised"]
POSE_MAP = {
 "char_boy":        ["standing", "jumping", "thinking", "pointing", "shocked"],
 "char_girl":       ["standing", "jumping", "thinking", "waving", "jumping_front"],
 "char_mother":     ["standing", "jumping", "thinking", "teaching", "jumping"],
 "char_father":     ["standing", "happy", "thinking", "waving", "jumping"],
 "char_grandfather":["holding_book", "happy", "holding_book", "teaching", "happy"],
 "char_grandmother":["standing", "waving", "reading", "teaching", "waving"],
 "char_postman":    ["standing", "waving", "reading", "waving", "waving"],
 "char_shopkeeper": ["standing", "welcoming", "weighing", "waving", "welcoming"],
 "animal_cow":      ["standing", "calling", "eating", "walking", "calling"],
 "animal_dog":      ["standing", "standing", "standing", "standing", "standing"],
}
COUNTABLE_ANIMALS = ["animal_fish_normal", "animal_fish_smiling", "animal_parrot_perched", "animal_sparrow_perched"]

m2 = json.load(open(f"{OUT}/manifest.json"))
ids = {a["id"] for a in m2["assets"]}
actors = {}
for aid, pmap in POSE_MAP.items():
    group = "characters" if aid.startswith("char_") else "animals"
    poses = sorted(i[len(aid) + 1:] for i in ids if i.startswith(aid + "_"))
    for p in pmap:
        assert p in poses, (aid, p, poses)
    actors[aid] = {"group": group, "poses": poses, "pose_map": dict(zip(EXPR, pmap))}
m2["actors"] = actors
m2["backdrops"] = sorted(i for i in ids if i.startswith("bg_"))
m2["props"] = sorted([i for i in ids if i.startswith(("prop_", "env_"))] + COUNTABLE_ANIMALS)
m2["countable_props"] = ["prop_coin_gold", "prop_pots", "prop_lantern", "prop_note_10", "prop_note_50", "prop_note_100"] + COUNTABLE_ANIMALS
m2.pop("actors_and_poses", None)
json.dump(m2, open(f"{OUT}/manifest.json", "w"), indent=2)
print("scene config:", len(actors), "actors,", len(m2["backdrops"]), "backdrops,", len(m2["props"]), "props")
