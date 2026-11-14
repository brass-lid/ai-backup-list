#!/usr/bin/env bash
# 取回推理引擎的源码与离线轮子（不走 HF，避免单点）
# 用法: ./fetch-engines.sh /Volumes/ARK/engines
set -euo pipefail
DEST="${1:-$PWD/engines}"
ONLY="${ONLY:-all}"   # all | llama（源码+预编译）| wheels | heretic
mkdir -p "$DEST"/{src,bin,wheels}

if [ "$ONLY" = "all" ] || [ "$ONLY" = "llama" ]; then
echo "== 1/4 llama.cpp v1.0.0 源码（无外部依赖，冷启动首选）"
curl -fL --retry 3 -o "$DEST/src/llama.cpp-v1.0.0.tar.gz" \
  "https://github.com/ggml-org/llama.cpp/archive/refs/tags/v1.0.0.tar.gz"

echo "== 2/4 llama.cpp 预编译（v1.0.0 这个 tag 只发源码，二进制在 nightly b 号 tag 里）"
# 资产名随版本变化：先问 API 再取，别硬编码
LLAMA_TAG="${LLAMA_TAG:-b12368}"
# 火种优先：Mac(arm64) / Linux(x64 + arm64) / Windows(x64)。CUDA 版 190MB 起，按需自己加。
for asset in "llama-${LLAMA_TAG}-bin-macos-arm64.tar.gz" \
             "llama-${LLAMA_TAG}-bin-ubuntu-x64.tar.gz" \
             "llama-${LLAMA_TAG}-bin-ubuntu-arm64.tar.gz" \
             "llama-${LLAMA_TAG}-bin-win-cpu-x64.zip"; do
  curl -fL --retry 3 -o "$DEST/bin/$asset" \
    "https://github.com/ggml-org/llama.cpp/releases/download/${LLAMA_TAG}/$asset" || \
    echo "  跳过（该 tag 下没有 $asset，先查 releases）: $asset"
done
echo "$LLAMA_TAG" > "$DEST/bin/LLAMA_TAG.txt"

fi
if [ "$ONLY" = "all" ] || [ "$ONLY" = "wheels" ]; then
echo "== 3/4 Python 推理/微调轮子（离线安装用；vLLM 会拉 CUDA 依赖，约 5–12GB）"
python3 -m pip download -d "$DEST/wheels" \
  "transformers==5.23.0" "peft==0.21.3" "accelerate" "safetensors" \
  "huggingface_hub==2.4.0" "sentence-transformers" "bitsandbytes" \
  "vllm==0.33.0" "sglang==0.5.23" "llama-cpp-python==0.3.36" \
  || echo "  部分轮子失败（平台不匹配很常见），可加 --platform/--python-version 重试"

fi
if [ "$ONLY" = "all" ] || [ "$ONLY" = "heretic" ]; then
echo "== 4/4 Heretic（去审查工具，需单独 venv）"
python3 -m pip download -d "$DEST/wheels" "heretic-llm" || true
git clone --depth 1 https://github.com/p-e-w/heretic "$DEST/src/heretic" || true
fi

cat <<'EOF'

== 还要手工做的三件事
1) 复制当前机器的显卡驱动安装包（NVIDIA .run / AMD ROCm / Xcode CLT），版本号写进 engines/DRIVERS.txt
2) docker save 一个能跑 vLLM 或 SGLang 的镜像：docker save vllm/vllm-openai:v0.33.0 | zstd > engines/vllm.tar.zst
3) 在一台断网机器上按 README 从源码编译一次 llama.cpp —— 编译不过的备份，等于没备份
EOF
