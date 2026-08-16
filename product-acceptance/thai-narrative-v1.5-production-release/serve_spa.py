from __future__ import annotations

import argparse
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path


class SpaHandler(SimpleHTTPRequestHandler):
    def do_GET(self) -> None:
        request_path = self.path.split("?", 1)[0].split("#", 1)[0]
        candidate = Path(self.directory) / request_path.lstrip("/")
        if request_path != "/" and not candidate.is_file():
            self.path = "/index.html"
        super().do_GET()


parser = argparse.ArgumentParser()
parser.add_argument("--directory", required=True)
parser.add_argument("--port", type=int, required=True)
args = parser.parse_args()

server = ThreadingHTTPServer(
    ("127.0.0.1", args.port),
    lambda *handler_args, **handler_kwargs: SpaHandler(
        *handler_args, directory=args.directory, **handler_kwargs
    ),
)
server.serve_forever()
