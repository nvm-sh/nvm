#!/usr/bin/env python3
"""Download real photos (buildings + architect portraits) from Wikimedia Commons
into assets/photos/ and write credits.js for the on-slide photo credits.

Usage:  python3 fetch_photos.py            # search Commons for each slot
        python3 fetch_photos.py --force    # re-download existing files
Pin a specific Commons file by putting its title in PINNED, e.g. "File:Foo.jpg".
Then run:  node render.js
"""
import html, json, os, re, sys, urllib.parse, urllib.request

HERE = os.path.dirname(os.path.abspath(__file__))
OUT = os.path.join(HERE, "assets", "photos")
API = "https://commons.wikimedia.org/w/api.php"
UA = "giorno-carousel/1.0 (architecture carousel; contact via GitHub newdoom228-sudo)"

# slot -> (search query, min width)
SLOTS = {
    "tokyo-station":   ("Tokyo Station Marunouchi building facade", 1200),
    "yoyogi":          ("Yoyogi National Gymnasium", 1200),
    "nakagin":         ("Nakagin Capsule Tower", 1200),
    "church-of-light": ("Church of the Light Ibaraki Ando", 1000),
    "grand-ring":      ("Grand Ring Expo 2025 Osaka", 1200),
    "tatsuno":         ("Tatsuno Kingo portrait", 300),
    "tange":           ("Kenzo Tange", 300),
    "kurokawa":        ("Kisho Kurokawa", 300),
    "ando":            ("Tadao Ando portrait", 300),
    "fujimoto":        ("Sou Fujimoto architect", 300),
}
PINNED = {}  # e.g. {"tange": "File:Kenzo Tange.jpg"}


def get(params):
    url = API + "?" + urllib.parse.urlencode({**params, "format": "json"})
    with urllib.request.urlopen(urllib.request.Request(url, headers={"User-Agent": UA}), timeout=30) as r:
        return json.load(r)


def strip(s):
    return html.unescape(re.sub(r"<[^>]+>", "", s or "")).strip()


def candidates(slot):
    base = {"action": "query", "prop": "imageinfo", "iiprop": "url|size|mime|extmetadata", "iiurlwidth": 1800}
    if slot in PINNED:
        data = get({**base, "titles": PINNED[slot]})
    else:
        data = get({**base, "generator": "search", "gsrnamespace": 6, "gsrlimit": 15, "gsrsearch": SLOTS[slot][0]})
    pages = sorted(data.get("query", {}).get("pages", {}).values(), key=lambda p: p.get("index", 0))
    return pages


def main():
    force = "--force" in sys.argv
    os.makedirs(OUT, exist_ok=True)
    credits = {}
    for slot, (query, min_w) in SLOTS.items():
        dest = os.path.join(OUT, slot + ".jpg")
        for page in candidates(slot):
            info = (page.get("imageinfo") or [{}])[0]
            if info.get("mime") not in ("image/jpeg", "image/png") or info.get("width", 0) < min_w:
                continue
            meta = info.get("extmetadata", {})
            author = strip(meta.get("Artist", {}).get("value")) or "unknown"
            lic = strip(meta.get("LicenseShortName", {}).get("value")) or "see Commons"
            credits[slot] = f"{author[:60]} / {lic} / WIKIMEDIA COMMONS".upper()
            if force or not os.path.exists(dest):
                req = urllib.request.Request(info.get("thumburl") or info["url"], headers={"User-Agent": UA})
                with urllib.request.urlopen(req, timeout=60) as r, open(dest, "wb") as f:
                    f.write(r.read())
            print(f"{slot:16} <- {page['title']}  ({credits[slot]})")
            break
        else:
            print(f"{slot:16} !! nothing suitable for {query!r} — pin a file in PINNED")
    with open(os.path.join(OUT, "credits.js"), "w") as f:
        f.write("window.CREDITS = " + json.dumps(credits, ensure_ascii=False, indent=1) + ";\n")


if __name__ == "__main__":
    main()
