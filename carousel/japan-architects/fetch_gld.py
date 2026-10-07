#!/usr/bin/env python3
"""Pull specific Wikimedia Commons photos out of the Google Landmarks Dataset v2
mirror on S3 (useful when Wikimedia itself is unreachable). Tars are sorted by
image id, so we read each tar's first header, pick the right tar and stream it
only until the wanted ids are passed.

Usage: python3 fetch_gld.py <image_id> [...]   -> gld/<id>.jpg
Ids/URLs: metadata/train.csv; authors/licenses: metadata/train_attribution.csv.
Used here: f66905c21651f40b (Tokyo Station), a86f12e092f2b84a (Yoyogi),
d395443d6a42f1dd + 0ea6bd9d19fa945e (Nakagin), 9e273a044b4e17e5 (Church of the Light).
"""
import sys, tarfile, urllib.request, bisect, os
from concurrent.futures import ThreadPoolExecutor
BASE = 'https://s3.amazonaws.com/google-landmark/train/images_{}.tar'
ids = sys.argv[1:]
os.makedirs('gld', exist_ok=True)
def first(i):
    t = f'{i:03d}'
    req = urllib.request.Request(BASE.format(t), headers={'Range': 'bytes=0-99'})
    return [t, urllib.request.urlopen(req, timeout=30).read().split(b'\0')[0].decode()]
with ThreadPoolExecutor(32) as ex:
    idx = sorted(ex.map(first, range(500)))
firsts = [p.rsplit('/',1)[1][:-4] for _, p in idx]
need = {}
for i in ids:
    t = idx[bisect.bisect_right(firsts, i) - 1][0]
    need.setdefault(t, set()).add(i)
for t, want in sorted(need.items()):
    last = max(want)
    r = urllib.request.urlopen(BASE.format(t), timeout=120)
    with tarfile.open(fileobj=r, mode='r|') as tf:
        for m in tf:
            name = os.path.basename(m.name)[:-4]
            if name in want:
                open(f'gld/{name}.jpg', 'wb').write(tf.extractfile(m).read()); print('got', name, t, flush=True)
            if name > last: break
    r.close()
