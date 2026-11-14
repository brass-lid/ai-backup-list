#!/usr/bin/env bash
# 按 tag/commit 取回引擎与工具仓库的源码（§5 那张表），补上 download.sh 跳过的非 HF 资产
# 用法:
#   ./fetch-repos.sh                      # core 8 个，落到 ./repos
#   ONLY=all ./fetch-repos.sh /Volumes/ARK/repos
#   DRY=1 ./fetch-repos.sh                # 只列计划
# 清单: repos.csv（name,repo,ref,sha,date,core）
set -uo pipefail

DEST="${1:-$PWD/repos}"
HERE="$(cd "$(dirname "$0")" && pwd)"
LIST="${REPOS_CSV:-$HERE/repos.csv}"
ONLY="${ONLY:-tier}"        # tier（按 TIER 取）| all
DRY="${DRY:-0}"
mkdir -p "$DEST"

command -v git >/dev/null || { echo "需要 git" >&2; exit 1; }
[ -f "$LIST" ] || { echo "找不到清单: $LIST" >&2; exit 1; }

echo "== 仓库清单: ${LIST}（TIER=${TIER:-5} ONLY=${ONLY}）"
echo "== 目标: $DEST   时间: $(date -Iseconds)"

n=0; ok=0; skip=0; fail=0
TIER="${TIER:-5}"
tail -n +2 "$LIST" | while IFS=, read -r name repo ref sha date core tier; do
  core="${core%$'\r'}"; tier="${tier%$'\r'}"   # 防止 CRLF
  [ -z "${name:-}" ] && continue
  if [ "$ONLY" != "all" ] && [ "${tier:-5}" -gt "$TIER" ]; then continue; fi
  n=$((n+1))
  out="$DEST/${repo//\//__}"
  echo
  echo "[$n] T${tier} $name  ($repo @ ${ref:-HEAD} → ${sha:0:10})"
  if [ "$DRY" = "1" ]; then
    echo "    DRY: git fetch --depth 1 https://github.com/$repo.git $sha  → $out"
    continue
  fi
  if [ -d "$out/.git" ] && [ "$(git -C "$out" rev-parse HEAD 2>/dev/null)" = "$sha" ]; then
    echo "    已存在且 HEAD 一致，跳过"; skip=$((skip+1)); continue
  fi
  rm -rf "$out"; mkdir -p "$out"
  if ( cd "$out" \
       && git init -q \
       && git remote add origin "https://github.com/$repo.git" \
       && git fetch -q --depth 1 origin "$sha" \
       && git checkout -q FETCH_HEAD ); then
    {
      echo "repo: $repo"
      echo "ref: ${ref:-HEAD}"
      echo "sha: $sha"
      echo "upstream_date: $date"
      echo "fetched: $(date -Iseconds)"
    } > "$out/PROVENANCE.txt"
    ( cd "$out" && find . -type f ! -path './.git/*' ! -name 'SHA256SUMS*' ! -name 'PROVENANCE.txt' -print0 \
        | sort -z | xargs -0 shasum -a 256 > SHA256SUMS.txt )
    echo "    ✓ $(du -sh "$out" | cut -f1)  已写入 PROVENANCE.txt + SHA256SUMS.txt"
    ok=$((ok+1))
  else
    echo "    ✗ 取件失败（tag/sha 可能已不存在）"; fail=$((fail+1))
  fi
done

echo
echo "== 校验: ./verify.sh $DEST"
