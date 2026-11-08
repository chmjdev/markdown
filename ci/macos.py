"""Build and package markdown.app for Universal (arm64 + x86_64) macOS (24 GB M5 Pro MacBook Pro per rules.md #52/#60)."""
import hashlib
import json
import os
import platform
import plistlib
import shutil
import subprocess
from pathlib import Path

assert platform.system() == "Darwin", "macOS build host required"

env = os.environ.copy()
extra_paths = [
    "/opt/homebrew/bin",
    "/usr/local/bin",
]
env["PATH"] = ":".join(extra_paths + [env.get("PATH", "")])
swift_flags: list[str] = []

subprocess.run(["npm", "ci", "--no-audit", "--no-fund"], env=env, check=True)

shutil.rmtree("build", ignore_errors=True)
Path("build/markdown.app/Contents/MacOS").mkdir(parents=True, exist_ok=True)
Path("build/markdown.app/Contents/Resources/web").mkdir(parents=True, exist_ok=True)

subprocess.run(
    ["node", "scripts/build-web.mjs", "web/editor.js", "build/markdown.app/Contents/Resources/web/editor.js"],
    env=env,
    check=True,
)
shutil.copy2("web/index.html", "build/markdown.app/Contents/Resources/web/index.html")

subprocess.run(
    ["swiftc", *swift_flags, "scripts/icon.swift", "-o", "build/icon-gen"],
    env=env,
    check=True,
)
subprocess.run(["./build/icon-gen", "build/AppIcon.iconset"], env=env, check=True)
subprocess.run(
    ["iconutil", "-c", "icns", "build/AppIcon.iconset", "-o", "build/markdown.app/Contents/Resources/AppIcon.icns"],
    env=env,
    check=True,
)
shutil.copy2("THIRD-PARTY-NOTICES.txt", "build/markdown.app/Contents/Resources/THIRD-PARTY-NOTICES.txt")
shutil.copy2("LICENSE.txt", "build/markdown.app/Contents/Resources/LICENSE.txt")
shutil.copy2("Info.plist", "build/markdown.app/Contents/Info.plist")

for arch in ("arm64", "x86_64"):
    subprocess.run(
        [
            "swiftc",
            *swift_flags,
            "Sources/main.swift",
            "-o",
            f"build/markdown-{arch}",
            "-framework",
            "AppKit",
            "-framework",
            "WebKit",
            "-framework",
            "UniformTypeIdentifiers",
            "-target",
            f"{arch}-apple-macosx13.0",
        ],
        env=env,
        check=True,
    )

subprocess.run(
    [
        "lipo",
        "-create",
        "build/markdown-arm64",
        "build/markdown-x86_64",
        "-output",
        "build/markdown.app/Contents/MacOS/markdown",
    ],
    env=env,
    check=True,
)
subprocess.run(["codesign", "--force", "--sign", "-", "build/markdown.app"], env=env, check=True)

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
commit_sha = os.environ.get("CI_COMMIT_SHA") or subprocess.check_output(["git", "rev-parse", "HEAD"], text=True).strip()
(out / "build.json").write_text(
    json.dumps(
        {
            "source_revision": commit_sha,
            "build_host": platform.node(),
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
print("Built and verified markdown.app for Universal macOS (arm64 + x86_64).")
