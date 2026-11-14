#!/usr/bin/env bash
# 校验所有已下载目录的 SHA256SUMS.txt，并打印体积
# 用法: ./verify.sh /Volumes/ARK
set -uo pipefail
DEST="${1:-$PWD/models}"
[ -d "$DEST" ] || { echo "目录不存在: $DEST" >&2; exit 1; }

n=0; bad=0
while IFS= read -r sums; do
  dir="$(dirname "$sums")"
  n=$((n+1))
  size=$(du -sh "$dir" 2>/dev/null | cut -f1)
  printf '\n== %s (%s)\n' "$dir" "$size"
  if ( cd "$dir" && shasum -a 256 -c SHA256SUMS.txt ); then
    echo "   OK"
  else
    echo "   !! 校验失败：这个目录里至少有一个文件损坏或被替换"
    bad=$((bad+1))
  fi
done < <(find "$DEST" -maxdepth 3 -name SHA256SUMS.txt | sort)

echo
echo "== 目录 $n 个，失败 $bad 个"
[ "$bad" -eq 0 ] || exit 2
