#!/usr/bin/env bash
# ai-backup-list · 分级下载器
# 用法:
#   TIER=0 DEST=/Volumes/SEED ./download.sh          # 只下火种层
#   TIER=2 DEST=/Volumes/SSD2T DRY=1 ./download.sh   # 先看计划，不下载
# 支持两类条目:
#   HuggingFace 仓库  → hf download（含 --include / --revision）
#   github.com/o/r    → git fetch --depth 1，按 commit sha 钉死（工具类条目）
# 依赖: huggingface_hub >= 1.0（hf 命令）、git、python3；可选 hf_transfer/par2
set -euo pipefail

TIER="${TIER:-0}"
DEST="${DEST:-$PWD/models}"
HERE="$(cd "$(dirname "$0")" && pwd)"
MANIFEST="${MANIFEST:-$HERE/manifest.csv}"
DRY="${DRY:-0}"
PAR2="${PAR2:-0}"          # 1 = 为 >2GB 的 GGUF/safetensors 生成 5% 冗余卷（很慢）
export HF_XET_HIGH_PERFORMANCE="${HF_XET_HIGH_PERFORMANCE:-1}"   # huggingface_hub>=1.0 用 Xet 传输

if [ "$DRY" != "1" ] && ! command -v hf >/dev/null 2>&1; then
  echo "缺少 hf 命令。安装：python3 -m pip install -U 'huggingface_hub[hf_transfer]'" >&2
  exit 1
fi
command -v python3 >/dev/null || { echo "需要 python3" >&2; exit 1; }
command -v git >/dev/null || { echo "需要 git（github.com 条目按 commit 取件）" >&2; exit 1; }

mkdir -p "$DEST"
LOG="$DEST/download-$(date +%Y%m%d-%H%M%S).log"
if [ "$DRY" != "1" ]; then
  # 进程替换（/dev/fd）在部分沙箱/老 shell 里不可用；不可用就只写终端，不装死
  if ( exec > >(cat >/dev/null) 2>&1 ) 2>/dev/null; then
    exec > >(tee -a "$LOG") 2>&1
  else
    echo "!! 本环境不支持进程替换：日志文件 $LOG 不会写入，输出只在终端" >&2
  fi
fi

echo "== 清单: $MANIFEST"
echo "== 层级: T$TIER   目标: $DEST   时间: $(date -Iseconds)"

python3 - "$MANIFEST" "$TIER" > "$DEST/.plan.tsv" <<'PY'
import csv, sys
path, tier = sys.argv[1], int(sys.argv[2])
rows = list(csv.DictReader(open(path, encoding="utf-8")))
sel = [r for r in rows if int(r["tier"]) <= tier]
total = sum(float(r["size_gb"]) for r in sel)
print(f"# 共 {len(sel)} 项，预计 {total:.1f} GB", file=sys.stderr)
for r in sel:
    print("\t".join([r["repo_id"], r["revision"], r["include"] or "-",
                     r["artifact"], r["size_gb"]]))
PY

if grep -q "^[^#]*	main	" "$DEST/.plan.tsv" 2>/dev/null; then
  echo "!! 警告：计划里仍有 revision=main 的条目，这些内容随时可能变；先用 check-manifest.py 钉死" >&2
fi

n=0; ok=0; fail=0; skip=0
while IFS=$'\t' read -r repo rev inc0 name sz; do
  case "$repo" in \#*|"") continue;; esac
  n=$((n+1))
  inc=""
  slug="$(printf '%s' "$repo" | tr '/' '_' | tr -cd '[:alnum:]_.+-')"
  if [ "$inc0" != "-" ] && [ -n "$inc0" ]; then
    inc="$inc0"
    slug="${slug}__$(printf '%s' "$inc" | sed 's/\.gguf$//' | tr -cd '[:alnum:]_.+-')"
  fi
  out="$DEST/$slug"

  echo
  echo "[$n] $name"
  echo "    repo=$repo rev=${rev:-main} size≈${sz}GB"

  case "$repo" in
    docs:*)
      if [ "$DRY" = "1" ]; then echo "    DRY: fetch-docs.sh $DEST/docs"; continue; fi
      if "$HERE/fetch-docs.sh" "$DEST/docs"; then ok=$((ok+1)); else fail=$((fail+1)); fi
      continue ;;
    installers:*)
      if [ "$DRY" = "1" ]; then echo "    DRY: fetch-installers.sh $DEST/installers"; continue; fi
      if "$HERE/fetch-installers.sh" "$DEST/installers"; then ok=$((ok+1)); else fail=$((fail+1)); fi
      continue ;;
    repos:*)
      if [ "$DRY" = "1" ]; then echo "    DRY: fetch-repos.sh $DEST/repos (TIER=$TIER)"; continue; fi
      if TIER="$TIER" "$HERE/fetch-repos.sh" "$DEST/repos"; then ok=$((ok+1)); else fail=$((fail+1)); fi
      continue ;;
    engines:*)
      if [ "$DRY" = "1" ]; then echo "    DRY: fetch-engines.sh $DEST/engines (ONLY=${repo#engines:})"; continue; fi
      if ONLY="${repo#engines:}" "$HERE/fetch-engines.sh" "$DEST/engines"; then ok=$((ok+1)); else fail=$((fail+1)); fi
      continue ;;
  esac

  if [ "$repo" = "-" ]; then
    echo "    非 HF/非 GitHub 资产，跳过：语料见正文 §4.11（维基 dump 需手工取）"
    skip=$((skip+1)); continue
  fi

  fetched=0
  case "$repo" in
    github.com/*)
      [ "$rev" = "-" ] && { echo "    !! 缺少 revision，拒绝下载不可复现的 HEAD"; fail=$((fail+1)); continue; }
      if [ "$DRY" = "1" ]; then
        echo "    DRY: git fetch --depth 1 https://$repo.git $rev  (→ $out)"
        continue
      fi
      if [ -d "$out/.git" ]; then
        if ( cd "$out" && git fetch -q --depth 1 origin "$rev" && git checkout -q FETCH_HEAD ); then
          fetched=1
        fi
      else
        mkdir -p "$out"
        if ( cd "$out" && git init -q \
             && git remote add origin "https://$repo.git" \
             && git fetch -q --depth 1 origin "$rev" \
             && git checkout -q FETCH_HEAD ); then
          fetched=1
        fi
      fi
      ;;
    *)
      args=(--repo-type model --local-dir "$out"
            --exclude "original/*" --exclude "metal/*" --exclude "onnx/*" --exclude "*.ckpt")
      if [ -n "$rev" ] && [ "$rev" != "main" ] && [ "$rev" != "-" ]; then args+=(--revision "$rev"); fi
      if [ -n "$inc" ]; then args+=(--include "$inc"); fi
      if [ "$DRY" = "1" ]; then echo "    DRY: hf download $repo ${args[*]}"; continue; fi
      if hf download "$repo" "${args[@]}"; then fetched=1; fi
      ;;
  esac

  if [ "$fetched" = "1" ]; then
    ok=$((ok+1))
    {
      echo "repo_id: $repo"
      echo "revision: ${rev:-main}"
      case "$repo" in
        github.com/*) echo "resolved_head: $(git -C "$out" rev-parse HEAD 2>/dev/null || echo unknown)";;
      esac
      echo "artifact: $name"
      echo "downloaded: $(date -Iseconds)"
      echo "include: ${inc:--}"
    } > "$out/PROVENANCE.txt"
    ( cd "$out" && find . -type f ! -path './.git/*' ! -path './.cache/*' ! -name 'SHA256SUMS*' ! -name 'PROVENANCE.txt' -print0 \
        | sort -z | xargs -0 shasum -a 256 > SHA256SUMS.txt )
    rm -rf "$out/.cache"   # hf 的续传缓存/锁文件，不属于存档内容
    echo "    已写入 PROVENANCE.txt + SHA256SUMS.txt"
    if [ "$PAR2" = "1" ] && command -v par2 >/dev/null 2>&1; then
      find "$out" -type f -size +2G \( -name '*.gguf' -o -name '*.safetensors' \) -print0 \
        | while IFS= read -r -d '' f; do par2 create -r5 "$f.par2" "$f" >/dev/null; done
    fi
  else
    fail=$((fail+1)); echo "    !! 失败，可重跑（已下载分片会续传）"
  fi
done < "$DEST/.plan.tsv"

echo
echo "== 完成: 成功 $ok / 失败 $fail / 跳过 $skip / 共 $n"
echo "== 校验: $HERE/verify.sh $DEST"
