import argparse
import hashlib
import json
import urllib.request
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('origin')
parser.add_argument('output', type=Path)
args = parser.parse_args()

files = {}
for name in ('index.html', 'flutter_bootstrap.js', 'main.dart.js'):
    request = urllib.request.Request(
        args.origin.rstrip('/') + '/' + name,
        headers={'Cache-Control': 'no-cache', 'Accept-Encoding': 'identity'},
    )
    with urllib.request.urlopen(request, timeout=60) as response:
        digest = hashlib.sha256()
        length = 0
        while chunk := response.read(1024 * 1024):
            digest.update(chunk)
            length += len(chunk)
        files[name] = {
            'status': response.status,
            'sha256': digest.hexdigest(),
            'bytes': length,
            'cache_control': response.headers.get('Cache-Control'),
        }
args.output.write_text(json.dumps({'origin': args.origin, 'files': files}, indent=2)
                       + '\n', encoding='utf-8')
print(json.dumps({'origin': args.origin, 'files': files}, indent=2))
