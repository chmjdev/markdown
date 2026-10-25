"""Build only on the estate's Sonoma VM runner; target Universal (arm64 + x86_64) macOS."""
import hashlib
import json
import os
import platform
import plistlib
import re
import shutil
import subprocess
from pathlib import Path

assert os.environ.get("GITLAB_CI") == "true" and os.environ.get("CI_DEBUG_TRACE") != "true"
assert platform.system() == "Darwin", "macOS VM required"
assert os.environ.get("CI_RUNNER_ID") == "5", "Use the registered Sonoma cloud VM, never Air13"


def prepare_swift_toolchain():
    clt = Path("/Library/Developer/CommandLineTools")
    ver_out = subprocess.check_output([str(clt / "usr/bin/swiftc"), "--version"], text=True, stderr=subprocess.STDOUT)
    m = re.search(r"swiftlang-[0-9.]+", ver_out)
    compiler_tag = m.group(0) if m else "swiftlang-6.0.3.1.10"
    print("Compiler tag:", compiler_tag)

    clean = Path("/tmp/clt-clean-v2")
    sdk_dst = clean / "SDKs/MacOSX.sdk"
    res_dst = clean / "usr/lib/swift"
    marker = clean / ".ready"
    if not marker.exists():
        shutil.rmtree(clean, ignore_errors=True)
        (clean / "usr/include/swift").mkdir(parents=True, exist_ok=True)
        (clean / "usr/lib").mkdir(parents=True, exist_ok=True)
        for item in (clt / "usr/include").iterdir():
            if item.name == "swift":
                continue
            os.symlink(item, clean / "usr/include" / item.name)
        for item in (clt / "usr/include/swift").iterdir():
            if item.name == "module.modulemap":
                continue
            os.symlink(item, clean / "usr/include/swift" / item.name)
        for item in (clt / "usr/lib").iterdir():
            os.symlink(item, clean / "usr/lib" / item.name)
        for sub in ("bin", "libexec", "share"):
            if (clt / "usr" / sub).exists():
                os.symlink(clt / "usr" / sub, clean / "usr" / sub)

        sdk_src = (clt / "SDKs/MacOSX.sdk").resolve()
        for root, dirs, files in os.walk(sdk_src, followlinks=False):
            rel = Path(root).relative_to(sdk_src)
            target_dir = sdk_dst / rel
            target_dir.mkdir(parents=True, exist_ok=True)
            keep_dirs = []
            for d in dirs:
                s = Path(root) / d
                t = target_dir / d
                if s.is_symlink():
                    os.symlink(os.readlink(s), t)
                else:
                    keep_dirs.append(d)
            dirs[:] = keep_dirs
            for f in files:
                s = Path(root) / f
                t = target_dir / f
                if s.is_symlink():
                    os.symlink(os.readlink(s), t)
                elif f.endswith(".swiftinterface"):
                    txt = s.read_text(errors="replace")
                    txt = re.sub(r"swiftlang-[0-9.]+", compiler_tag, txt)
                    t.write_text(txt)
                else:
                    os.symlink(s, t)
        marker.write_text(compiler_tag)
    return ["-resource-dir", str(res_dst), "-sdk", str(sdk_dst)]


env = os.environ.copy()
extra_paths = [
    "/Users/desktop/Documents/OSINTDeskCI/toolchain/node-v22.23.4-darwin-x64/bin",
    "/opt/homebrew/bin",
    "/usr/local/bin",
]
env["PATH"] = ":".join(extra_paths + [env.get("PATH", "")])
swift_flags = prepare_swift_toolchain()

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
