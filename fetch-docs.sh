#!/usr/bin/env bash
# 取回 §7 的技术报告/文档包（arXiv PDF 等），补上 download.sh 跳过的非 HF 资产
# 用法:
#   ./fetch-docs.sh                    # 落到 ./docs
#   ./fetch-docs.sh /Volumes/SEED/docs
#   DRY=1 ./fetch-docs.sh              # 只列计划
# 清单: docs.csv（从正文 §7 解析出来的 id/kind/section/title/url）
set -euo pipefail

DEST="${1:-$PWD/docs}"
HERE="$(cd "$(dirname "$0")" && pwd)"
LIST="${DOCS_CSV:-$HERE/docs.csv}"
DRY="${DRY:-0}"
PAUSE="${PAUSE:-1}"        # 对 arXiv 客气一点，别把人家打挂

[ -f "$LIST" ] || { echo "找不到清单: $LIST" >&2; exit 1; }
mkdir -p "$DEST"

echo "== 文档清单: $LIST"
echo "== 目标: $DEST   时间: $(date -Iseconds)"

DRY="$DRY" PAUSE="$PAUSE" DEST="$DEST" LIST="$LIST" python3 - <<'PY'
import csv, os, sys, time, hashlib, urllib.request, urllib.error

dest = os.environ["DEST"]; dry = os.environ["DRY"] == "1"
pause = float(os.environ["PAUSE"])
rows = list(csv.DictReader(open(os.environ["LIST"], encoding="utf-8")))

ok = fail = skip = 0
manifest = []
for r in rows:
    pid, kind, sec = r["id"], r["kind"], r["section"]
    url = r["url"]
    fetch_url = f"https://arxiv.org/pdf/{pid}" if kind == "arxiv" else url
    outdir = os.path.join(dest, "arxiv" if kind == "arxiv" else "other")
    out = os.path.join(outdir, f"{pid}.pdf")
    rel = os.path.relpath(out, dest)

    if dry:
        print(f"  DRY {rel}  ← {fetch_url}")
        continue
    if os.path.exists(out) and os.path.getsize(out) > 10240:
        skip += 1; manifest.append((rel, os.path.getsize(out))); continue
    os.makedirs(outdir, exist_ok=True)
    for attempt in (1, 2, 3):
        try:
            req = urllib.request.Request(fetch_url, headers={"User-Agent": "doomsday-manifest/1.0"})
            with urllib.request.urlopen(req, timeout=60) as resp, open(out, "wb") as f:
                f.write(resp.read())
            size = os.path.getsize(out)
            if size < 10240:
                raise ValueError(f"文件太小（{size}B），可能被限流")
            ok += 1; manifest.append((rel, size))
            print(f"  ✓ {rel:34s} {size/1e6:6.2f} MB")
            break
        except Exception as e:
            if attempt == 3:
                fail += 1; print(f"  ✗ {rel:34s} {e}"); 
            else:
                time.sleep(2 * attempt)
    time.sleep(pause)

if not dry:
    total = sum(s for _, s in manifest)
    prov = os.path.join(dest, "PROVENANCE.txt")
    with open(prov, "w", encoding="utf-8") as f:
        f.write("source: docs.csv（正文 §7 解析）\n")
        f.write(f"fetched: {time.strftime('%Y-%m-%dT%H:%M:%S%z')}\n")
        f.write(f"items: {len(manifest)}  files_total_bytes: {total}\n")
        f.write("note: arXiv 论文没有 commit sha，抓取日期就是证据链；引用时请以 arXiv 版本号为准\n")
    idx = os.path.join(dest, "index.md")
    with open(idx, "w", encoding="utf-8") as f:
        f.write("# 文档包索引\n\n| 编号 | 类别 | 章节 | 标题 | 文件 | 体积 |\n|---|---|---|---|---|---|\n")
        sizes = dict(manifest)
        for r in rows:
            rel = f"{'arxiv' if r['kind']=='arxiv' else 'other'}/{r['id']}.pdf"
            if rel in sizes:
                f.write(f"| {r['id']} | {r['kind']} | {r['section']} | {r['title']} | {rel} | "
                        f"{sizes[rel]/1e6:.1f} MB |\n")
    with open(os.path.join(dest, "SHA256SUMS.txt"), "w", encoding="utf-8") as f:
        for rel in sorted(sizes):
            h = hashlib.sha256(open(os.path.join(dest, rel), "rb").read()).hexdigest()
            f.write(f"{h}  ./{rel}\n")
    print(f"\n== 完成: 下载 {ok} / 已存在 {skip} / 失败 {fail} / 共 {len(rows)}")
    print(f"== 合计 {total/1e9:.2f} GB   索引 {idx}")
    if fail: sys.exit(1)
PY
