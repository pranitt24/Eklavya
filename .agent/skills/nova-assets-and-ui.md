# Nova: assets and UI rules

## Assets
- All art is generated with Gemini by the team, then cleaned up by hand. The owner supplies the asset list. Do not generate or invent assets yourself.
- Raster images (WebP preferred, PNG acceptable) are allowed. The old "no PNG/JPG" rule is retired. Keep sizes reasonable: characters about 150 KB or less each, backdrops about 400 KB or less each, unless the owner says otherwise.
- Characters are sets of images, one per mood. The default moods are `idle`, `happy`, `curious`, `encouraging`. Add more only when the owner asks.
- Naming: `char_<name>_<mood>.webp`, `bg_<name>.webp`, `prop_<name>.webp`. Lowercase, underscores only.
- Character images: transparent background, same canvas size for every mood of a character, same anchor (bottom centre) so swapping moods does not make the character jump.
- Every asset must be registered in the asset catalogue before the LLM or the app can use it. An asset that is not in the catalogue does not exist.
- Do not rename or delete existing assets without asking.

## Motion
Characters are animated with whole-image transforms in Flutter driven by the level JSON (bounce, jump, tilt, shake, slide-in) plus a cross-fade between mood images. Unknown motion or mood names must fall back to `idle` without crashing.

## UI
- No emojis in UI text or labels.
- Do not use stock Material icons where an illustration belongs.
- Avoid generic gradients and default purple palettes. Use a small deliberate palette (4–5 colours).
- Marathi and English must both render correctly. The chosen fonts must include Devanagari glyphs, and this must be checked on a real device.
- Young children read slowly: every prompt needs audio and a picture, and touch targets must be large.
- Do not build new screens until the UI mockup has been approved by the owner.
