"""Build a plugin-free trial in a disposable workspace, never the main build.

Dart libraries remain available for shared reader types; plugin declarations are
removed only from private dependency copies. --no-pub preserves this explicit
package map. Generated registrants and the final bundle are checked fail-closed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess
import tempfile
from urllib.parse import unquote, urlsplit

REPO = Path(__file__).resolve().parents[1]
FORBIDDEN = (
    "accounts.google.com/gsi", "firebase-auth.js", "firebase-firestore.js",
    "identitytoolkit.googleapis.com", "securetoken.googleapis.com",
    "firestore.googleapis.com",
)


def package_path(uri, config_dir):
    parsed = urlsplit(uri)
    if parsed.scheme == "file":
        path = unquote(parsed.path)
        if re.match(r"^/[A-Za-z]:", path):
            path = path[1:]
        return Path(path)
    return (config_dir / unquote(uri)).resolve()


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--flutter", default="flutter")
    parser.add_argument("--api", required=True)
    parser.add_argument("--version", required=True)
    args = parser.parse_args()
    api = urlsplit(args.api)
    if api.scheme != "https" or not api.netloc or api.path or api.query or api.fragment:
        raise SystemExit("FAIL: calculator must be an exact HTTPS origin")
    if "knowme-astrology-api" in api.netloc:
        raise SystemExit("FAIL: signed-in Production API is forbidden")
    config_file = REPO / ".dart_tool/package_config.json"
    config = json.loads(config_file.read_text(encoding="utf-8"))
    parent = REPO / ".trial-build"
    parent.mkdir(exist_ok=True)
    stage = Path(tempfile.mkdtemp(prefix="stage-", dir=parent))
    for name in ("lib", "web", "assets", "knowledge"):
        shutil.copytree(REPO / name, stage / name)
    for name in ("pubspec.yaml", "pubspec.lock", "l10n.yaml", ".metadata"):
        shutil.copy2(REPO / name, stage / name)
    disabled = []
    for package in config["packages"]:
        root = package_path(package["rootUri"], config_file.parent)
        if package["name"] == "knowme":
            root = stage
        else:
            manifest = root / "pubspec.yaml"
            source = manifest.read_text(encoding="utf-8") if manifest.exists() else ""
            # Flutter discovers registrations from package manifests, not imports.
            if re.search(r"^  plugin:", source, re.M):
                private = stage / "dependencies" / package["name"]
                private.mkdir(parents=True)
                if (root / "lib").exists():
                    shutil.copytree(root / "lib", private / "lib")
                # Remove only the top-level Flutter metadata in this private copy.
                stripped = re.sub(r"^flutter:\s*\n(?:[ \t].*\n|\s*\n|#.*\n)*", "", source, flags=re.M)
                if re.search(r"^  plugin:", stripped, re.M):
                    raise SystemExit("FAIL: plugin metadata survived staging")
                (private / "pubspec.yaml").write_text(stripped, encoding="utf-8")
                root = private
                disabled.append(package["name"])
        package["rootUri"] = root.resolve().as_uri() + "/"
    (stage / ".dart_tool").mkdir()
    (stage / ".dart_tool/package_config.json").write_text(json.dumps(config), encoding="utf-8")
    subprocess.run([
        args.flutter, "build", "web", "--no-pub", "--release", "--no-wasm-dry-run",
        "--target", "lib/main_trial.dart",
        "--dart-define=KNOWME_OVERALL_PREVIEW=true",
        "--dart-define=ASTROLOGY_API_BASE_URL=" + args.api,
        "--dart-define=THAI_PUBLIC_EVIDENCE_BADGE_BETA=off",
    ], cwd=stage, check=True)
    registrants = list((stage / ".dart_tool/flutter_build").rglob("web_plugin_registrant.dart"))
    if not registrants:
        raise SystemExit("FAIL: no generated registrant to verify")
    for path in registrants:
        text = path.read_text(encoding="utf-8")
        if "registerWith(" in text or re.search(r"import 'package:(?!flutter_web_plugins/)", text):
            raise SystemExit("FAIL: a web plugin was registered: " + str(path))
    output = stage / "build/web"
    bundle = (output / "main.dart.js").read_text(encoding="utf-8")
    if args.api not in bundle or any(value in bundle for value in FORBIDDEN):
        raise SystemExit("FAIL: trial bundle API/privacy guard")
    for asset, old, new in (
        ("index.html", 'src="flutter_bootstrap.js"', 'src="flutter_bootstrap.js?v=' + args.version + '"'),
        ("flutter_bootstrap.js", "main.dart.js", "main.dart.js?v=" + args.version),
    ):
        path = output / asset
        text = path.read_text(encoding="utf-8")
        path.write_text(text.replace(old, new), encoding="utf-8")
    evidence = {
        "api": args.api, "version": args.version, "disabled_registrations": disabled,
        "registrant_verified": True,
        "sha256": {name: hashlib.sha256((output / name).read_bytes()).hexdigest()
                   for name in ("main.dart.js", "flutter_bootstrap.js", "index.html")},
    }
    (output / "trial-build-evidence.json").write_text(json.dumps(evidence, indent=2), encoding="utf-8")
    pointer = parent / "latest.json"
    pointer.write_text(json.dumps({"stage": str(stage), "output": str(output), **evidence}, indent=2), encoding="utf-8")
    print("PASS: plugin-free trial output: " + str(output))


if __name__ == "__main__":
    main()
