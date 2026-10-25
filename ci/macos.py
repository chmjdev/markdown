"""Build only on the estate's Sonoma VM runner; target Universal (arm64 + x86_64) macOS."""
import hashlib
import json
import os
import platform
import plistlib
import subprocess
from pathlib import Path

assert os.environ.get("GITLAB_CI") == "true" and os.environ.get("CI_DEBUG_TRACE") != "true"
assert platform.system() == "Darwin", "macOS VM required"
assert os.environ.get("CI_RUNNER_ID") == "5", "Use the registered Sonoma cloud VM, never Air13"

env = os.environ.copy()
extra_paths = [
    "/Users/desktop/Documents/OSINTDeskCI/toolchain/node-v22.23.4-darwin-x64/bin",
    "/opt/homebrew/bin",
    "/usr/local/bin",
]
env["PATH"] = ":".join(extra_paths + [env.get("PATH", "")])

subprocess.run(["npm", "ci", "--no-audit", "--no-fund"], env=env, check=True)
subprocess.run(["bash", "build.sh"], env=env, check=True)

app = Path("build/markdown.app")
subprocess.run(["codesign", "--verify", "--deep", "--strict", str(app)], check=True)
info = plistlib.loads((app / "Contents/Info.plist").read_bytes())
assert info["CFBundleIdentifier"] == "app.jola.markdown"

archs = subprocess.check_output(["lipo", "-archs", str(app / "Contents/MacOS/markdown")], text=True).strip().split()
assert "arm64" in archs and "x86_64" in archs, f"Expected universal binary, got {archs}"
assert not list(app.rglob(".env*"))

out = Path("build/macos")
out.mkdir(parents=True, exist_ok=True)
archive = out / "markdown-macOS-universal.zip"
subprocess.run(["ditto", "-c", "-k", "--sequesterRsrc", "--keepParent", str(app), str(archive)], check=True)
sha = hashlib.sha256(archive.read_bytes()).hexdigest()
(out / "markdown-macOS-universal.zip.sha256").write_text(f"{sha}  {archive.name}\n")
(out / "build.json").write_text(
    json.dumps(
        {
            "source_revision": os.environ["CI_COMMIT_SHA"],
            "runner_id": 5,
            "target": "darwin-universal",
            "archs": archs,
            "bundle_id": info["CFBundleIdentifier"],
            "version": info.get("CFBundleShortVersionString"),
            "ad_hoc_signature_verified": True,
            "notarized": False,
            "device_acceptance": False,
        },
        indent=2,
    )
    + "\n"
)
print("Sonoma VM built and verified markdown.app for Universal macOS (arm64 + x86_64).")
