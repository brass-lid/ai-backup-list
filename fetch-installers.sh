#!/usr/bin/env bash
# 取回"能独立跑"的安装包：GitHub release 里的预编译二进制 / DMG / wheel / 安装脚本。
# 源码能编译 ≠ 三年后能装；这些是别人替你打包好的那份。
# 用法:
#   ./fetch-installers.sh              # 落到 ./installers
#   ./fetch-installers.sh /Volumes/SEED/installers
#   DRY=1 ./fetch-installers.sh        # 只列计划
# 清单: installers.csv（name,repo,pattern,note）
set -euo pipefail

DEST="${1:-$PWD/installers}"
HERE="$(cd "$(dirname "$0")" && pwd)"
LIST="${INSTALLERS_CSV:-$HERE/installers.csv}"
DRY="${DRY:-0}"
mkdir -p "$DEST"
[ -f "$LIST" ] || { echo "找不到清单: ${LIST}" >&2; exit 1; }

echo "== 安装包清单: ${LIST}"
echo "== 目标: $DEST   时间: $(date -Iseconds)"

DRY="$DRY" DEST="$DEST" LIST="$LIST" python3 - <<'PY'
import csv, fnmatch, hashlib, json, os, sys, urllib.request

dest, dry, path = os.environ["DEST"], os.environ["DRY"] == "1", os.environ["LIST"]
rows = list(csv.DictReader(open(path, encoding="utf-8")))
releases = {}

UA = {"User-Agent": "doomsday-manifest/1.0"}

def _scrape(repo):
    """API 限流时的回退：从 release 页面 HTML 里解析资产名（不消耗 API 配额）"""
    import re
    req = urllib.request.Request(f"https://github.com/{repo}/releases/latest", headers=UA)
    with urllib.request.urlopen(req, timeout=30) as r:
        final = r.geturl()
    tag = final.rstrip("/").split("/")[-1]
    req2 = urllib.request.Request(
        f"https://github.com/{repo}/releases/expanded_assets/{tag}", headers=UA)
    with urllib.request.urlopen(req2, timeout=30) as r:
        html = r.read().decode("utf-8", "replace")
    names = re.findall(r'href="/' + re.escape(repo) + r'/releases/download/[^/]+/([^"?]+)"', html)
    assets = [{"name": n,
               "size": int(m.replace(",", "")) if (m := re.search(
                   re.escape(n) + r'.*?([\d,]+)\s*(?:Bytes|KB|MB|GB)', html)) else 0,
               "browser_download_url": f"https://github.com/{repo}/releases/download/{tag}/{n}"}
              for n in dict.fromkeys(names)]
    return {"tag_name": tag, "published_at": "", "assets": assets}

def api(repo):
    if repo not in releases:
        try:
            req = urllib.request.Request(f"https://api.github.com/repos/{repo}/releases/latest", headers=UA)
            with urllib.request.urlopen(req, timeout=30) as r:
                releases[repo] = json.load(r)
        except Exception as e:
            print(f"  (API 不可用，改用页面解析: {repo})", file=sys.stderr)
            releases[repo] = _scrape(repo)
    return releases[repo]

ok = miss = fail = 0
total = 0
for row in rows:
    repo, pat = row["repo"], row["pattern"]
    try:
        rel = api(repo)
    except Exception as e:
        print(f"✗ {repo:40s} {e}"); fail += 1; continue
    assets = [a for a in rel.get("assets") or [] if fnmatch.fnmatch(a["name"], pat)]
    if not assets:
        print(f"— {repo:40s} 该 release 下没有匹配 {pat}"); miss += 1; continue
    for a in assets:
        outdir = os.path.join(dest, repo.replace("/", "__"))
        out = os.path.join(outdir, a["name"])
        rel_path = os.path.join(os.path.basename(outdir), a["name"])
        if dry:
            print(f"  DRY {rel_path:62s} {a['size']/1e6:7.1f} MB"); continue
        if os.path.exists(out) and os.path.getsize(out) == a["size"]:
            print(f"  = {rel_path:62s} 已存在"); ok += 1; total += os.path.getsize(out); continue
        os.makedirs(outdir, exist_ok=True)
        try:
            req = urllib.request.Request(a["browser_download_url"], headers={"User-Agent": "doomsday-manifest/1.0"})
            with urllib.request.urlopen(req, timeout=120) as resp, open(out, "wb") as f:
                while chunk := resp.read(1 << 20):
                    f.write(chunk)
            got = os.path.getsize(out)
            print(f"  ✓ {rel_path:62s} {got/1e6:7.1f} MB")
            ok += 1; total += got
        except Exception as e:
            print(f"  ✗ {rel_path} {e}"); fail += 1

if not dry:
    for d in {os.path.join(dest, r["repo"].replace("/", "__")) for r in rows}:
        if not os.path.isdir(d):
            continue
        repo = os.path.basename(d).replace("__", "/", 1)
        try:
            rel = api(repo)
            tag, date = rel.get("tag_name", "?"), (rel.get("published_at") or "")[:10]
        except Exception:
            tag, date = "?", "?"
        files = sorted(f for f in os.listdir(d) if not f.startswith(("SHA256SUMS", "PROVENANCE")))
        with open(os.path.join(d, "PROVENANCE.txt"), "w", encoding="utf-8") as f:
            f.write(f"repo: {repo}\nrelease: {tag}\nrelease_date: {date}\nfetched: {__import__('time').strftime('%Y-%m-%dT%H:%M:%S%z')}\nfiles: {len(files)}\n")
        with open(os.path.join(d, "SHA256SUMS.txt"), "w", encoding="utf-8") as f:
            for name in files:
                h = hashlib.sha256(open(os.path.join(d, name), "rb").read()).hexdigest()
                f.write(f"{h}  ./{name}\n")
    print(f"\n== 完成: 下载/已存在 {ok} / 该 release 缺项 {miss} / 失败 {fail}")
    print(f"== 合计 {total/1e9:.2f} GB")
PY
