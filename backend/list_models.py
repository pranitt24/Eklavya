"""python -m backend.list_models   -> prints model names your key can use for generateContent."""
import json, os, urllib.request, urllib.error
from .pipeline import load_env
load_env()
req = urllib.request.Request("https://generativelanguage.googleapis.com/v1beta/models?pageSize=100",
                             headers={"x-goog-api-key": os.environ.get("GEMINI_API_KEY", "")})
try:
    for m in json.load(urllib.request.urlopen(req, timeout=20))["models"]:
        if "generateContent" in m.get("supportedGenerationMethods", []):
            print(m["name"].replace("models/", ""))
except urllib.error.HTTPError as e:
    print("HTTP", e.code, e.read().decode()[:400])
