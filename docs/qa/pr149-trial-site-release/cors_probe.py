import argparse
import json
import urllib.error
import urllib.request
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument('output', type=Path)
args = parser.parse_args()

api = 'https://knowme-overall-pr149-preview-avbyttircq-as.a.run.app'
origins = [
    'https://knowme-trial-694e1.web.app',
    'https://knowme-app-694e1--pr-149-overall-safe-c41ic92g.web.app',
    'https://unapproved-pr149.example.invalid',
]
results = []
for endpoint in ('calculate-bazi', 'calculate-chart'):
    for origin in origins:
        request = urllib.request.Request(
            api + '/v1/' + endpoint,
            method='OPTIONS',
            headers={
                'Origin': origin,
                'Access-Control-Request-Method': 'POST',
                'Access-Control-Request-Headers': 'content-type',
            },
        )
        try:
            response = urllib.request.urlopen(request, timeout=20)
        except urllib.error.HTTPError as error:
            response = error
        with response:
            results.append({
                'endpoint': endpoint,
                'origin': origin,
                'status': response.status,
                'allow_origin': response.headers.get('Access-Control-Allow-Origin'),
                'allow_methods': response.headers.get('Access-Control-Allow-Methods'),
            })
args.output.write_text(json.dumps(results, indent=2) + '\n', encoding='utf-8')
print(json.dumps(results, indent=2))
