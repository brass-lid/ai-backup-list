# ai-backup-list v1.0 — an ark for AI

**A checklist of open weights, inference engines and technical literature, tiered by disk size**
Compiled 2026-11-13 (v1.0, reviewed the same day) · Companion files: [manifest.csv](manifest.csv) (67 entries), [fetch-docs.sh](fetch-docs.sh), [fetch-repos.sh](fetch-repos.sh), [download.sh](download.sh), [verify.sh](verify.sh), [fetch-engines.sh](fetch-engines.sh), [ladder.py](ladder.py) (generates the §3.1 ladder and §3.2 per-tier detail), [check-manifest.py](check-manifest.py) (online check of sha / size / include) · Chinese original: [ai-backup-list_v1_zh.md](ai-backup-list_v1_zh.md)

## 1. Why this list exists

> This list was written for a not-very-dramatic kind of accident: **the platform changed its terms, a model page turned 404, a license was reinterpreted, a driver stopped supporting your card, a paper survived but the tokenizer needed to reproduce it did not.** It doesn't take an order — just a few companies each tightening a little, rationally.
>
> There is only one sorting rule: **without a network, without an API, without Hugging Face, can an ordinary person still get AI running, change it, and teach it to someone else?**

---

## 2. Six principles and the grading scheme

### 2.1 Six principles

1. **3-2-1**: three copies, two media, one off-site. If you can't do three, do "two + one offline". This is what I ask of you.
2. **Every tier must light up on its own**: engine + weights + tokenizer + chat template + license + eval scripts. Missing one and a "backup" can become a pile of bytes that won't start.
3. **Pin the revision**: only commit shas, never `main`. `main` is a pointer someone else can move at any time.
4. **Weights are not capability**: the inference engine, the related knowledge, configs, templates and eval sets matter just as much.
5. **Format ladder**: BF16 → FP8 → GGUF Q4. Q4 runs, but the originals hold knowledge more finely — every tier must degrade gracefully, down to a laptop with no GPU.
6. **A backup that was never drilled is not a backup**: drill after downloading, from scratch on an offline machine, every six months.

### 2.2 Priority (`priority`)

**S → A → B**, my definitions

| Grade | Definition | Test question |
|---|---|---|
| **S** | Civilizational optionality: without it, latecomers cannot rebuild comparable capability offline | "One file condenses thousands of years of human development" |
| **A** | Significantly changes what one person or a small institution can do | "It's on the Pareto frontier for its tier; losing it would hurt" |
| **B** | Domain-specific or frontier-scale; missing it doesn't stop you from "doing AI" | "Would you regret deleting it? Probably not — but it stands for a distinct way of thinking, a particular knowledge base, or a starting point for deeper work" |

### 2.3 Category (`category`)

Categories are for retrieval only and imply no priority: `engine` (inference engines / build artifacts), `tool` (abliteration and similar), `text-small` / `text-mid` / `text-frontier` (text models by parameter band), `vision`, `audio`, `ocr`, `embed`, `rerank`, `guard`, `abliterated`, `agent` (agent harnesses), `installer` (prebuilt installers), `image`, `video`, `corpus`, `docs`.

> The size ladder (§3.1) tiers assets by **capacity**; priority grades them by **what breaks if it's missing**. They are two orthogonal axes: an S-grade asset can be 0.3GB (llama.cpp sources), a B-grade asset can be 57GB (FLUX).

---

## 3. Size ladder and what each tier contains

### 3.1 Size ladder (measured, decimal GB — disk vendors label in decimal too)

| Tier | Target media | Items | This tier | Cumulative | Who it's for | What it can do |
|---|---|---|---|---|---|---|
| **T0 Seed** | 8GB USB stick / phone | 8 | 6.8 GB | **6.8 GB** | anyone | Run a 4B-class model offline on one laptop + retrieval + transcription + TTS + all core papers |
| **T1 Starter** | 64GB stick / old SSD | 9 | 50.2 GB | **57.1 GB** | a machine with 16–32GB RAM | 27B-class model (Q4) + 35B-A3B (Q4) + 9B vision-language + multilingual retrieval + 4 agent harnesses |
| **T2 Main** | 512GB SSD | 15 | 398.4 GB | **455.5 GB** | 64GB RAM / 24GB VRAM | 4-bit versions of two large MoEs (Flash-Next / GLM-5.3-Flash) + 9B VL + OCR + speech + rerank + guard + embeddings + corpus |
| **T3 Serious** | 1TB SSD | 13 | 370.5 GB | **826.0 GB** | 128GB RAM / 1–2×80GB GPUs | Adds: V4-Flash, Gemma-31B Q8, the abliterated family, guard model, academic OCR, 6 abliteration tools |
| **T4 Frontier** | 4TB HDD/SSD | 13 | 2408.6 GB | **3234.6 GB** | 8×80GB or 1TB+ RAM | **Originals / pretraining mothers**: GLM-5.3 Q4, V4.1-Flash, GLM-5.3-Flash, 27B/35B originals, both Qwen3.5 bases, Gemma-4-31B base, video generation |
| **T5 Ark** | 20TB | 9 | 5953.3 GB | **9188.0 GB** | small machine room / lab / library | Adds: V4-Pro-Base, Kimi-K3, GLM-5.3, V3.2-Exp-Base, R1, Llama-3.3-70B — the 1.5TB-class and the heaviest originals |
| **T6 Archive** | 100TB+ | not enumerated | — | — | institutions | Full corpora (FineWeb/Dolma/The Stack), multiple copies, tape cold storage, mirrors |

> The numbers in this table are computed by [ladder.py](ladder.py) straight from `manifest.csv`: after editing the list, re-run `./ladder.py` and then `./ladder.py --check ai-backup-list_v1_zh.md` to confirm the text hasn't drifted (it drifted here once, in the first version).
>
> **Why these disk sizes**: early on the text gained 11 entries missing from the CSV (+126.2GB), which forced T2 to 512GB (256GB doesn't fit); after dropping 4 gpt-oss entries (−134.7GB), T3 and T4 fit back into 1TB / 4TB; making T2 a pure 4-bit tier (382.9GB) kept 512GB sufficient. **Pick by need if you want to save space**: every `note` says what it trades against (DeepSeek-OCR vs Unlimited-OCR, Qwen3-Embedding safetensors vs GGUF).
>
> **Headroom**: T0 86%, T1 89%, T2 89%, T3 83%, T4 80% — T1's 57.1GB on a 64GB stick is 53.2GiB / 59.6GiB, only ~6GiB left; T2's 455.5GB on a 512GB disk is 424GiB / 477GiB, ~53GiB left; T3's 826.0GB on a 1TB disk is 769GiB / 931GiB, ~162GiB left; T4's 3234.6GB on a 4TB disk is 3012GiB / 3725GiB, ~713GiB left.
>
> **Quantization convention per tier**: **T2 is 4-bit only** (EXL3 / GGUF Q4 — it runs, it fits); **T3 holds mid-size and special-purpose items** (V4-Flash, abliterated, guards, OCR); **T4 holds originals** (FP8/BF16/compressed weights, for fine-tuning, re-quantizing and as mothers). For knowledge-heavy work, move up the bit scale: GLM-5.3-Flash's Q6 is 292GB (`UD-Q6_K_XL`), 116GB more than 4-bit, and buys factual recall and long-document consistency.
>
> **Every revision is pinned**: all HF / GitHub assets point at a concrete commit sha (only llama.cpp is pinned by tag `v1.0.0`, and the Wikipedia dump comes straight from `dumps.wikimedia.org`); one sha had originally been copied from the wrong repo. `./check-manifest.py` can re-check any of them online.

### 3.2 What each tier contains

Each tier listed on its own (largest first within a tier). If you're receiving this list, read this section first to decide how big a disk to buy, then use section 4 to pick weights by capability. To take a whole tier: `TIER=<n> DEST=<disk> ./download.sh` — it pulls all lower tiers too (`TIER=2` means T0+T1+T2).

> `†` = not a HuggingFace / GitHub asset; `download.sh` skips it: corpora are in §4.11, engines via `fetch-engines.sh`, papers in §7.

**T0 Seed** · 8GB USB stick / phone · 8 items · 6.8 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| Qwen3.5-4B GGUF Q4_K_M | text-small | 2.74 | S |
| Qwen3.5-2B GGUF Q5_K_M | text-small | 1.44 | S |
| Qwen3.5-0.8B GGUF Q8_0 | text-small | 0.81 | S |
| Qwen3-Embedding-0.6B GGUF Q8_0 | embed | 0.64 | A |
| whisper-tiny (PyTorch/CT2) | audio | 0.61 | B |
| Kokoro-82M TTS | audio | 0.36 | B |
| llama.cpp sources + prebuilt (linux/mac/win/arm) | engine | 0.12 | S |
| Core papers and docs bundle (PDF/HTML/MD) | docs | 0.12 | S |

**T1 Starter** · 64GB stick / old SSD · 9 items · 50.2 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| Qwen3.6-35B-A3B GGUF Q4_K_M | text-mid | 22.13 | A |
| Qwen3.8-27B GGUF Q4_K_M | text-mid | 16.56 | S |
| Qwen3.5-9B GGUF Q5_K_M | text-mid | 6.58 | A |
| BAAI/bge-m3 | embed | 2.30 | A |
| Standalone installers (release assets) | installer | 1.60 | S |
| Hermes Agent | agent | 0.42 | S |
| ohmypi (omp) | agent | 0.33 | S |
| DeepSeek Harness (dsh) | agent | 0.25 | S |
| pi (earendil-works) | agent | 0.08 | S |

**T2 Main** · 512GB SSD · 15 items · 398.4 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| GLM-5.3-Flash EXL3 4bpw | text-frontier | 175.70 | A |
| Qwen3.8-Flash-Next GGUF Q4_K_XL | text-frontier | 111.32 | A |
| Wikipedia EN dump (2026-10) † | corpus | 21.00 | S |
| Qwen3.5-9B | text-mid | 19.33 | A |
| Qwen3-VL-8B-Instruct | vision | 17.50 | A |
| Shieldstral-1.0-3B | guard | 15.43 | B |
| Qwen3-Embedding-8B | embed | 15.10 | A |
| DeepSeek-OCR | ocr | 6.68 | A |
| parakeet-tdt-0.6b-v3 | audio | 5.73 | A |
| GLM-OCR | ocr | 2.66 | B |
| bge-reranker-v2-m3 | rerank | 2.30 | A |
| whisper-large-v3-turbo | audio | 1.60 | A |
| Inference engines and tool repos (§5) | engine | 1.55 | S |
| embeddinggemma-300m | embed | 1.27 | B |
| Qwen3-Embedding-0.6B | embed | 1.21 | A |

**T3 Serious** · 1TB SSD · 13 items · 370.5 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| DeepSeek-V4-Flash | text-frontier | 159.63 | S |
| Nemotron-3-Nano-30B-A3B | text-mid | 63.20 | A |
| Qwen-Image | image | 57.70 | B |
| Gemma-4-31B-it GGUF Q8_0 | text-mid | 32.64 | B |
| Llama-Guard-4-12B | guard | 24.00 | A |
| olmOCR-2-7B | ocr | 16.60 | B |
| Huihui-Qwen3.8-27B-abliterated GGUF Q4_K_M | abliterated | 16.55 | A |
| refusal_direction (paper reproduction) | tool | 0.09 | B |
| OBLITERATUS | tool | 0.08 | A |
| remove-refusals-with-transformers | tool | 0.0027 | A |
| Heretic | tool | 0.0022 | S |
| repeng (steering vectors) | tool | 0.0010 | B |
| abliterator | tool | 0.0002 | B |

**T4 Frontier** · 4TB HDD/SSD · 13 items · 2408.6 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| DeepSeek-V4.1-Flash | text-frontier | 510.30 | A |
| GLM-5.3 GGUF UD-Q4_K_XL | text-frontier | 467.30 | S |
| Qwen3.8-Flash-Next | image | 360.00 | B |
| GLM-5.3-Flash | text-frontier | 328.40 | A |
| Nemotron-3-Super-120B-A12B | text-frontier | 247.20 | B |
| Wan2.2-T2V-A14B | video | 126.20 | B |
| Qwen3.5-35B-A3B-Base | text-mid | 71.93 | S |
| Qwen3.6-35B-A3B | text-mid | 71.90 | S |
| Gemma-4-31B | text-mid | 62.58 | B |
| FLUX.1-dev | image | 57.90 | B |
| Qwen3.8-27B | text-mid | 55.60 | S |
| FineWeb-Edu sample-10BT + Chinese corpus sample | corpus | 30.00 | B |
| Qwen3.5-9B-Base | text-small | 19.33 | A |

**T5 Ark** · 20TB · 9 items · 5953.3 GB

| Asset | Category | Size | Grade |
|---|---|---|---|
| DeepSeek-V4-Pro-Base | text-frontier | 1606.07 | B |
| Kimi-K3 | text-frontier | 1560.90 | S |
| GLM-5.3 | text-frontier | 755.70 | S |
| DeepSeek-V3.2-Exp-Base | text-frontier | 689.50 | B |
| DeepSeek-R1 | text-frontier | 688.60 | B |
| Dolma3 / The Stack v2 samples | corpus | 500.00 | B |
| Llama-3.3-70B-Instruct | text-mid | 141.10 | B |
| SDXL base 1.0 | image | 6.94 | B |
| Qwen3-TTS-12Hz-1.7B-Base | audio | 4.54 | B |

### 3.3 Capability density ranking (capability per GB)

If you have one USB stick, or just want to remember "what to grab first", follow this order:

| Rank | Asset | Size | Why it ranks here |
|---|---|---|---|
| 1 | **llama.cpp sources + one GGUF** | 0.3 + 2.7 GB | Without it, weights are just files; with it, any CPU can infer |
| 2 | **Qwen3.5-4B Q4** | 2.7 GB | 4B is the minimum for "can actually work": writing, translation, basic code, tool calls |
| 3 | **Qwen3.8-27B Q4** | 16.6 GB | The inflection point for single-machine capability: a nearly usable agent, native vision, 262k context |
| 4 | **bge-m3 + bge-reranker** | 4.6 GB | Lets the model read your own material; RAG is half the value of local AI |
| 5 | **whisper-large-v3-turbo** | 1.6 GB | Speech is the largest class of "not yet digitized" knowledge |
| 6 | **Qwen3.6-35B-A3B Q4** | 22.1 GB | 3B active, 35B of knowledge: a high-quality MoE that runs on a laptop |
| 7 | **abliterated 27B** | 16.6 GB | A version upstream can't change its mind about; a live specimen for studying how refusal works |
| 8 | **Qwen3.8-27B original** | 55.6 GB | A mother you can fine-tune, quantize and distill from (T4) |
| 9 | **GLM-5.3-Flash EXL3 4bpw** | 175.7 GB | A 321B at 4 bits: the steepest capability jump in T2; Chinese and tool use both beat same-size models |

---

## 4. Model catalog, by category

> The fully machine-readable version is [manifest.csv](manifest.csv), including each entry's commit sha and `--include` file name. Sizes below are measured (2026-11-13); licenses follow repo tags — read the originals before commercial use.
>
> **Naming rule**: original weights are written by model name only (no precision tag) — many "open weights" originals are actually FP8 or FP4, not BF16, and the precision is stated in the row's note; only **quantized files** carry a format tag (`GGUF Q4_K_M`, `EXL3 4bpw`, `Q8_0` …). 4-bit is the default for functional assets (get it running, build agents); for knowledge-heavy assets prefer Q6/Q8 or keep the original.

### 4.1 Flagship open weights (T4–T5)

| Model | Repo (revision) | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Base | `deepseek-ai/DeepSeek-V4-Pro-Base @ 98730c0` | 1606.1 GB | T5 | MIT | B | V4-Pro's pretraining mother (BF16, twice the size of the FP4 release); only for people who really want to retrain |
| Kimi-K3 | `moonshotai/Kimi-K3` @ f831ab6 | 1560.9 GB | T5 | Kimi K3 License | S | 2.8T, 896 experts top-16, natively multimodal |
| GLM-5.3 | `zai-org/GLM-5.3` @ ba32f8c | 755.7 GB | T5 | GLM License | S | 753B; Chinese and tool use |
| GLM-5.3 GGUF UD-Q4_K_XL | `unsloth/GLM-5.3-GGUF` @ 346b359 | 467.3 GB | T4 | GLM License | S | Optional quantized release: 11 shards; Q3_K_XL 343GB / IQ4_XS 365GB are smaller; one-of-two with the T5 FP8 original |
| DeepSeek-V3.2-Exp-Base | `deepseek-ai/DeepSeek-V3.2-Exp-Base @ b21ef15` | 689.5 GB | T5 | MIT | B | V3.2's pretraining mother (its `base_model` field points here); post-training restarts from it |
| DeepSeek-R1 | `deepseek-ai/DeepSeek-R1` @ 56d4cbb | 688.6 GB | T5 | MIT | B | The head of the reasoning-chain lineage; a philosopher |
| DeepSeek-V4.1-Flash | `deepseek-ai/DeepSeek-V4.1-Flash` @ 314113f | 510.3 GB | T4 | MIT | A | 763B, the V4 iteration |
| GLM-5.3-Flash | `zai-org/GLM-5.3-Flash` @ 46a050b | 328.4 GB | T4 | MIT | A | 321B; the best value among Chinese frontier weights |
| Qwen3.8-Flash-Next | `Qwen/Qwen3.8-Flash-Next` @ 812d96e | 360.0 GB | T4 | Qwen License | B | 180B; the main base for community abliterated models |
| Nemotron-3-Super-120B-A12B | `nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-BF16` @ 2dc98e2 | 247.2 GB | T4 | NVIDIA Open | B | 120B/12B active, hybrid Mamba |

### 4.2 Single-machine workhorses (T1–T4)

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Qwen3.8-27B | `Qwen/Qwen3.8-27B` @ 3756181 | 55.6 GB | T4 | Apache-2.0 | S | 27B dense, native vision+video, 262k context extendable to 1M |
| Qwen3.8-27B GGUF Q4_K_M | `unsloth/Qwen3.8-27B-GGUF` @ 4af51b3 | 16.6 GB | T1 | Apache-2.0 | S | The single-machine sweet spot; the same repo has IQ2 through Q8 |
| Qwen3.6-35B-A3B | `Qwen/Qwen3.6-35B-A3B` @ 345d467 | 71.9 GB | T4 | Apache-2.0 | S | 35B total / 3B active; agentic coding |
| Qwen3.6-35B-A3B GGUF Q4_K_M | `unsloth/Qwen3.6-35B-A3B-GGUF` @ a483e9e | 22.1 GB | T1 | Apache-2.0 | A | Runs in 16GB of RAM |
| GLM-5.3-Flash EXL3 4bpw | `Mia-AiLab/GLM-5.3-Flash-EXL3-4bpw-TensorFold` @ 76c0b51 | 175.7 GB | T2 | GLM License | A | The 4-bit version of 321B (EXL3, 83 shards); the FP8 original, 328GB, is in T4 |
| Qwen3.8-Flash-Next GGUF Q4_K_XL | `unsloth/Qwen3.8-Flash-Next-GGUF` @ f5d175d | 111.3 GB | T2 | Qwen License | A | The 4-bit version of 180B; the BF16 original, 360GB, is in T4 |
| Qwen3.5-9B | `Qwen/Qwen3.5-9B` @ c202236 | 19.3 GB | T2 | Apache-2.0 | A | 9B vision-language; the GGUF Q5 is 6.6GB |
| Gemma-4-31B | `google/gemma-4-31B @ 5bbc2fb` | 62.6 GB | T4 | Apache-2.0 | B | The pretrained version of Gemma-4-31B-it |
| Gemma-4-31B-it GGUF Q8_0 | `unsloth/gemma-4-31B-it-GGUF` @ c1ac76e | 32.6 GB | T3 | Apache-2.0 | B | Q8 single file; Q4_K_M is 18.3GB and smaller; the mother is in T4 |
| Qwen3.5-35B-A3B-Base | `Qwen/Qwen3.5-35B-A3B-Base` @ 0f08130 | 71.9 GB | T4 | Apache-2.0 | S | The only usable 30B-class base Qwen shipped (no base for the 27B line in three generations) |
| Qwen3.5-9B-Base | `Qwen/Qwen3.5-9B-Base` @ 68c46c4 | 19.3 GB | T4 | Apache-2.0 | A | The 9B base: a practice mother for redoing alignment experiments on one GPU |
| Nemotron-3-Nano-30B-A3B | `nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-BF16` @ bf77c31 | 63.2 GB | T3 | NVIDIA Open | A | Long-context efficiency |
| DeepSeek-V4-Flash | `deepseek-ai/DeepSeek-V4-Flash` @ 60d8d70 | 159.6 GB | T3 | MIT | S | 284B/13B active, 1M context, FP4+FP8 mix; 46 shards |
| Llama-3.3-70B-Instruct | `meta-llama/Llama-3.3-70B-Instruct` @ 6f6073b | 141.1 GB | T5 | Llama-3.3 | B | A compatibility layer for the old ecosystem; license acceptance required |

### 4.3 Small-model seed (T0)

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Qwen3.5-0.8B Q8_0 | `unsloth/Qwen3.5-0.8B-GGUF` | 0.81 GB | T0 | Apache-2.0 | S | Phone / Raspberry Pi; Q4 is only 0.53GB |
| Qwen3.5-2B Q5_K_M | `unsloth/Qwen3.5-2B-GGUF` | 1.44 GB | T0 | Apache-2.0 | S | The workhorse for an 8GB-RAM laptop |
| Qwen3.5-4B Q4_K_M | `unsloth/Qwen3.5-4B-GGUF` | 2.74 GB | T0 | Apache-2.0 | S | The value inflection point; Q8 is 4.48GB |

### 4.4 Code and agents

You can live without a dedicated "code model": the agentic coding of Qwen3.8-27B and Qwen3.6-35B-A3B already covers most cases; for something bigger, Kimi-K3 (T5, 1.56TB) carries code ability itself — which is also why entries like the 1T-class K2.7-Code were dropped. With a tight budget, prefer Qwen3.6-35B-A3B (22GB Q4); on repo-level reasoning it is steadier than dense models of the same size.

### 4.5 Multimodal and OCR

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Qwen3-VL-8B-Instruct | `Qwen/Qwen3-VL-8B-Instruct` @ 0c351dd | 17.5 GB | T2 | Apache-2.0 | A | Documents / charts / video understanding |
| DeepSeek-OCR | `deepseek-ai/DeepSeek-OCR` @ 9f30c71 | 6.7 GB | T2 | MIT | A | 3.3B; the best value in OCR |
| olmOCR-2-7B | `allenai/olmOCR-2-7B-1025` @ e52d6f0 | 16.6 GB | T3 | Apache-2.0 | B | Academic PDF structure recovery |
| GLM-OCR | `zai-org/GLM-OCR` @ 2e85a62 | 2.7 GB | T2 | MIT | B | Lightweight Chinese OCR |

### 4.6 Speech

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| whisper-large-v3-turbo | `openai/whisper-large-v3-turbo` @ 41f01f3 | 1.6 GB | T2 | MIT | A | The de facto standard for multilingual ASR |
| whisper-tiny | `openai/whisper-tiny` @ 169d4a4 | 0.15 GB | T0 | MIT | B | The smallest offline option; the repo ships h5/bin/safetensors/msgpack as four equivalent copies, 0.61GB for all |
| parakeet-tdt-0.6b-v3 | `nvidia/parakeet-tdt-0.6b-v3` @ 541d1f9 | 2.5 GB | T2 | CC-BY-4.0 | A | Faster and more accurate on English; the GGUF alone is 0.7GB, the whole repo (.nemo+safetensors+GGUF) is 5.73GB |
| Kokoro-82M | `hexgrad/Kokoro-82M` @ f3ff357 | 0.36 GB | T0 | Apache-2.0 | B | Real-time TTS on CPU; weights are `.pth` (pickle containers) — take them only from the official repo and load with `weights_only=True` |
| Qwen3-TTS-1.7B | `Qwen/Qwen3-TTS-12Hz-1.7B-Base` @ fd4b254 | 4.54 GB | T5 | Apache-2.0 | B | Multilingual TTS; voice cloning needs authorization |

### 4.7 Image / video / music

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Qwen-Image | `Qwen/Qwen-Image` @ 75e0b4b | 57.7 GB | T3 | Apache-2.0 | B | 20B generation/editing, strong Chinese typography |
| FLUX.1-dev | `black-forest-labs/FLUX.1-dev` @ 3de623f | 57.9 GB | T4 | **non-commercial** | B | The largest ecosystem; the strictest license |
| Wan2.2-T2V-A14B | `Wan-AI/Wan2.2-T2V-A14B` @ c8c270b | 126.2 GB | T4 | Apache-2.0 | B | A leader in open video generation; high/low-noise twin towers + umt5 encoder |
| SDXL base 1.0 | `stabilityai/stable-diffusion-xl-base-1.0` @ 4621659 | 6.9 GB | T5 | OpenRAIL++ | B | Single-file checkpoint only (`--include`); the full repo is 76.9GB of equivalent formats |

### 4.8 Embeddings and reranking (the skeleton of RAG)

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Qwen3-Embedding-0.6B | `Qwen/Qwen3-Embedding-0.6B` @ 97b0c61 | 1.2 GB | T2 | Apache-2.0 | A | 102 languages; the GGUF Q8 is only 0.64GB |
| Qwen3-Embedding-8B | `Qwen/Qwen3-Embedding-8B` @ 1d8ad4c | 15.1 GB | T2 | Apache-2.0 | A | Top of MTEB; runs on one GPU |
| bge-m3 | `BAAI/bge-m3` @ 5617a9f | 2.3 GB | T1 | MIT | A | Dense + sparse + multi-vector; the evergreen |
| bge-reranker-v2-m3 | `BAAI/bge-reranker-v2-m3` @ 953dc6f | 2.3 GB | T2 | Apache-2.0 | A | Small enough that you should always carry it |
| embeddinggemma-300m | `google/embeddinggemma-300m` @ 57c266a | 1.2 GB | T2 | Gemma | B | On-device retrieval |

### 4.9 Safety and moderation (guards)

Keeping a guard is not "taking sides" — it is **what lets the seed be handed on with trust**. The first incident in a local AI community without any moderation capability becomes the reason to ban it.

| Model | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Llama-Guard-4-12B | `meta-llama/Llama-Guard-4-12B` @ 87acb4b | 24.0 GB | T3 | Llama-4 | A | Multimodal input moderation |
| Shieldstral-1.0-3B | `mistralai/Shieldstral-1.0-3B` @ 003ec7e | 15.4 GB | T2 | Apache-2.0 | B | A 3.8B guard (fp32 storage is oversized; can be converted to bf16) |

### 4.10 abliterated / de-censored: weights and tools

**What it is**: abliteration finds and removes the model's internal "refusal direction", eliminating refusal behaviour without retraining. The 2024 mechanism paper is [Refusal in Language Models Is Mediated by a Single Direction](https://arxiv.org/abs/2406.11717) (Arditi et al.). The two mainstream tools in 2026 are [Heretic](https://github.com/p-e-w/heretic) (v2.1.0, 40.5k stars, training-free, supports bitsandbytes 4bit, finishes in an afternoon on a gaming PC) and [OBLITERATUS](https://github.com/elder-plinius/OBLITERATUS) (v0.1.4, 9.5k stars, Gradio UI + multiple methods + built-in refusal-rate/capability comparison reports). They turned "de-censoring" from manual tuning into a reproducible process; the methodology of the earlier [FailSpy/abliterator](https://github.com/FailSpy/abliterator) is still worth reading, but in daily use the first two have largely replaced it.

| Asset | Repo | Size | Tier | License | Grade | Note |
|---|---|---|---|---|---|---|
| Huihui-Qwen3.8-27B-abliterated GGUF Q4_K_M | `huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF` @ 06b4baa | 16.6 GB | T3 | Apache-2.0 | A | One file and it runs; the only 27B abliterated in T3 (the original table had copied the BF16 mother's sha — fixed) |

### 4.10.1 Six tools, six jobs

Tools are far cheaper than models (all six total 180MB), but without them the weights above are just someone else's binaries. All six are pinned by commit and retrievable offline (`download.sh` understands `github.com/` entries).

| Tool | Repo (version) | Size | Tier | License | Grade | When to use |
|---|---|---|---|---|---|---|
| **Heretic** | `github.com/p-e-w/heretic` @ v2.1.0 | 2.2 MB | T3 | AGPL-3.0 | S | The default: one command, training-free, usable weights in an afternoon; pip name `heretic-llm` |
| **OBLITERATUS** | `github.com/elder-plinius/OBLITERATUS` @ v0.1.4 | 84 MB | T3 | AGPL-3.0 | A | When you want a UI, comparison reports, and zero-install on HF Spaces; six usage modes (Docker/CLI/Colab), telemetry off by default |
| **remove-refusals-with-transformers** | `github.com/Sumandora/remove-refusals-with-transformers` @ 7786b0a | 2.7 MB | T3 | Apache-2.0 | A | Only HF Transformers, no TransformerLens; the shortest code, easiest to adapt |
| **abliterator** | `github.com/FailSpy/abliterator` @ 56ee3f7 | 0.2 MB | T3 | MIT | B | For writing your own orthogonalization/ablation experiments; unmaintained since 2024-06 — a methodology reference |
| **refusal_direction** | `github.com/andyrdt/refusal_direction` @ 9d852fa | 90 MB | T3 | Apache-2.0 | B | To understand why removing one direction suffices, and to reproduce the paper's numbers; ships results and data |
| **repeng** | `github.com/vgel/repeng` @ 0ba7196 | 1 MB | T3 | MIT | B | Steering vectors: not abliteration, but its control group and a finer knob |

**How to choose**: only one → Heretic; showing others / writing eval reports → add OBLITERATUS; modifying code → add remove-refusals; teaching or writing → add refusal_direction; controlled experiments → add repeng.

> Note: the source is just the shell — what really needs backing up is the dependency stack: `torch`, `transformers`, `transformer-lens`, `bitsandbytes`; a venv that can run Heretic is about 3–6GB. Store wheels as section 6 describes, or `pip install` will fail three years from now.

**Three boundaries that belong in the list**:

1. **License inheritance**: abliterated weights inherit the upstream license (all in the table above are Apache-2.0, redistributable); but Llama/Gemma upstream licenses carry usage restrictions, and de-censoring does not lift them.
2. **Capability will drop**: removing the refusal direction usually costs 1–5% general capability, and more on strongly aligned models. Compare against the mother with your own eval set before shipping.
3. **De-censoring ≠ irresponsibility**: this list exists so "upstream can't change its mind at any time", not to mass-produce harmful content. Keep the guards from 4.9; the outputs are the deployer's responsibility, not the weights'.

### 4.11 Corpora (T2–T5, optional)

Weights are "how it thinks"; corpora are "what it knows". Priority for personal backups: **Wikipedia (21GB, CC-BY-SA, from `dumps.wikimedia.org`, not HF) → FineWeb-Edu 10BT sample (~30GB) → private text in your own domain**. The latter two are **gated** on HF (`fineweb-edu`, `dolma3_mix-6T` return 401), so accept the terms and set a token; full FineWeb (~45TB), Dolma3 (6T tokens) and The Stack v2 (code, gated) are T6 institutional scale and not part of a personal list.

---

## 5. Inference engines and runtimes (versioned 2026-11-13)

Engines die more easily than models: the model file is still there, but the binary that could run it is gone. **Every engine needs at least: source tarball + a working binary/container + version number + build script.**

| Engine | Tier | Version | Platform | Use | What must be kept with it |
|---|---|---|---|---|---|
| **llama.cpp** | **T0** | v1.0.0 (2026-11-13) | CPU / Metal / CUDA / Vulkan | The de facto standard for GGUF inference; no external dependencies; **the highest importance** | Source tarball + per-platform prebuilts (v1.0.0 ships sources only; binaries from nightly `b12368`) + one GGUF |
| **Strata** | **T2** | HEAD @ `13eedf5` | Windows / Linux / macOS | "One-click run" for large MoEs like Qwen3.8-Flash-Next / GLM / DeepSeek: weight management + SSD streaming (slow but never OOM), desktop GUI | Sources + prebuilt installer (`fetch-repos.sh` gets sources; installers must be fetched by hand) |
| **DwarfStar4 (ds4)** | **T2** | HEAD @ `b3f5018` | Metal / CUDA / ROCm | An engine for the DeepSeek V4 family: runs Qwen Flash Next in 64GB on Metal, DeepSeek/GLM in 96GB+, Strix Halo iGPU supported; can pool memory across machines over RDMA | Sources + prebuilt for your platform |
| ExLlamaV2 | T2 | 0.3.2 (rarely updated since 2025-07) | NVIDIA | Low VRAM / old cards; the native runtime for EXL3 quantization | Sources + wheel; mind the maintenance risk |
| llama-cpp-python | T2 | 0.3.36 | cross-platform | Python bindings | wheel (must match the llama.cpp version) |
| MLX / mlx-lm | T2 | 0.32.4 | Apple Silicon | The fastest path on a Mac | pip wheel + 4-bit quantization scripts |
| **oMLX** | **T2** | HEAD @ `624cff0` | Apple Silicon | The "service" tier on a Mac: continuous batching + tiered KV cache + SSD cache, with VLM support | Sources (needs full Xcode + Metal toolchain) or the official DMG |
| vLLM | T2 | 0.33.0 | NVIDIA / AMD | High-throughput serving, PagedAttention | Container image (`docker save`) + CUDA driver |
| SGLang | T2 | 0.5.23 | NVIDIA | Long context / high concurrency, RadixAttention | Same as above |
| Transformers | T2 | 5.23.0 | cross-platform | Reference implementation, fine-tuning, evaluation | wheel + matching tokenizers |
| PEFT | T2 | 0.21.3 | cross-platform | LoRA/QLoRA | wheel |
| Ollama | T3 | 0.40.16 | cross-platform | One-command run, model library | Binary + the Modelfiles you pulled |
| koboldcpp | T3 | latest | cross-platform | Single file, zero install | One executable |
| MLC-LLM | T3 | latest | mobile / WebGPU | Phones, browsers | wheel + compiled model libraries |
| ONNX Runtime / Optimum | T3 | latest | cross-platform | Cross-platform and on-device deployment | wheel + export scripts |
| candle / mistral.rs | T3 | latest | Rust | Deployment without Python | a `cargo vendor` directory |
| Open WebUI / text-generation-webui | T3 | latest | cross-platform | Front ends | sources + node dependencies |
| LM Studio | T3 | latest | cross-platform | GUI + `lms` CLI (installed by hand) | installer + model directory |
| TensorRT-LLM | T4 | 1.2.1 | NVIDIA | Extreme performance (optional) | Container image; tightly bound to the driver |

> **The engine tier rule**: T0's engine is llama.cpp only (one USB stick is enough to light up); T2 fills in the set that "runs the big models you already downloaded" — Strata and DwarfStar4 are built specifically for Qwen3.8-Flash-Next / GLM-5.3-Flash / DeepSeek V4, and pair best with a used high-RAM box, a Mac Studio, or a single 24–48GB card; T3 adds front ends, evaluation and edge runtimes; T4 keeps only driver-bound things like TensorRT-LLM.

### 5.1 Agent harnesses: the layer between a model and "getting work done"

Engines answer "can it run"; harnesses answer "can it work for you" — they handle tool calls, context, the filesystem, multi-turn loops. This layer breaks more easily than engines: it depends on the npm ecosystem, ships fast, and often exists only as source.

| Harness | Tier | Version | Platform | Use | Standalone installer |
|---|---|---|---|---|---|
| **pi** (earendil-works) | T1 | v1.5.2 @ `97d539c` | macOS / Linux / Windows | Unified LLM API + agent loop + TUI + coding agent; the cleanest abstraction, good as a base | ✅ official prebuilts for 8 platforms (48–62MB); also npm `@earendil-works/pi-coding-agent`, needs Node ≥ 22.19 |
| **omp** (oh-my-pi) | T1 | v18.20.0 @ `e941476` | same | A coding tool that plugs the IDE straight into the agent | ✅ single-file binaries for 8 platforms (223–287MB) + `brew install can1357/tap/omp` |
| **DeepSeek Harness (dsh)** | T1 | @ `39163dd` | all (Node) | "Everything is a plugin": tools, models and UI are all plugins; the largest ecosystem | ❌ no standalone package: `pnpm install` (or copy `node_modules` wholesale) |
| **Hermes Agent** | T1 | v0.23.1 @ `b70a53e` | cross-platform | NousResearch's long-lived, growing agent | ❌ no release assets: only `install.sh` (fetches online) or sources + pnpm |

### 5.2 Standalone installers: sources alone are half a backup

Backing up only source is half a backup: `pnpm install` needs a registry, `pip install` needs PyPI, and three years from now both may or may not exist. So everything with an official prebuilt/installer gets stored separately — `installers.csv` + [`fetch-installers.sh`](fetch-installers.sh) handle this.

| Package | Platform | Size | Note |
|---|---|---|---|
| pi | darwin-arm64 / linux-x64 / win-x64 | ~169MB | Official tar/zip, runtime included |
| omp | darwin-arm64 / linux-x64 / win-x64 | ~762MB | Single file, self-contained |
| Strata | macOS dmg / Windows setup / Linux AppImage + Metal backend | ~592MB | CUDA/ROCm backends are 200–950MB, fetched per your card |
| oMLX | macOS universal2 wheel (py312/py313) | ~82MB | Or the 940MB DMG (with GUI) |
| llama.cpp | prebuilts for four platforms | ~117MB | Handled by `fetch-engines.sh`, see §5 |
| **dsh / hermes-agent** | — | — | **No standalone package**: copy the whole `node_modules` from an installed machine, and store `pnpm-lock.yaml` with it |

**Three "cold-start combos"**:

- **No-Python combo** (recommended for everyone): llama.cpp sources + CMake + one GGUF. Even a Raspberry Pi can compile it.
- **Serving combo**: a vLLM or SGLang container image + driver + model. For people with GPUs.
- **Apple combo**: MLX + mlx-lm + a 4-bit model. A MacBook can run 27B Q4.

Helper scripts: [fetch-engines.sh](fetch-engines.sh) fetches llama.cpp sources and the three-platform prebuilts; [fetch-repos.sh](fetch-repos.sh) shallow-clones the cloneable repos from the 20 above according to the `tier` column in `repos.csv` (`TIER=2` pulls 11, about 1.5GB; `TIER=3` pulls 19; `ONLY=all` pulls everything).

---

## 6. Dependencies and toolchains: so that you can still compile in three years

| Category | Tier | What to keep | Command / note |
|---|---|---|---|
| Build chain | **T0** | gcc/clang, cmake, ninja, make | At least one set that can build llama.cpp — T0's "ignition from source" relies on it |
| Integrity | **T0** | aria2, par2cmdline, zstd, 7z, sha256 | On macOS use `shasum -a 256` |
| Python wheels | **T1** | A full offline wheel set (transitive deps included) | `pip download -r requirements.txt -d wheels --only-binary=:all:` |
| GPU drivers | **T1** | The driver installer you use now **plus the previous version** | NVIDIA `.run`, AMD ROCm, Apple Xcode CLT |
| Platform-specific wheels | T2 | Fetch for the target machine (linux x86_64 / macOS arm64) | `--platform manylinux2014_x86_64 --python-version 3.12` |
| Environment snapshot | T2 | `uv` lockfile / whole env via `conda-pack` | `conda pack -n llm -o llm-env.tar.gz` |
| CUDA/ROCm | T2 | The toolkit matching your driver | Write the version into `DRIVERS.txt` |
| Containers | T2 | `docker save`d vLLM/SGLang images | `docker save img > img.tar && zstd img.tar` (10–20GB each) |
| Backup software | T2 | restic or borg (incremental + encrypted) | Good for monthly incrementals, not for cold storage |
| Rust/Node | T3 | Offline rustup toolchain, node + pnpm | For candle / Open WebUI |
| Sync | T4 | rclone (any object storage / off-site disk) | For off-site copies |

### 6.1 Training/fine-tuning stack ("extend", not just "use")

Back up only the inference stack and you get "AI you can use"; back up the training stack as well and you get "AI you can change". Only the latter is capacity-building.

| Tool | Tier | Use | Note |
|---|---|---|---|
| unsloth 0.1.917 | T2 | Single-GPU LoRA/QLoRA, memory-efficient and fast | Fits the llama.cpp/GGUF ecosystem well |
| PEFT 0.21.3 | T2 | The official parameter-efficient fine-tuning | LoRA/IA3/Prompt Tuning |
| Axolotl / LLaMA-Factory | T3 | Config-driven fine-tuning pipelines | For batch experiments |
| TRL | T3 | DPO / GRPO / PPO | Alignment and reasoning reinforcement |
| DeepSpeed / FSDP | T4 | Sharding, offload, mixed precision | Starts at single-node multi-GPU |
| FlashAttention / Triton | T4 | Kernel layer | Tightly bound to CUDA/ROCm versions |
| torchtitan / Megatron-LM / OLMo-core | T4 | Pretraining reference implementations | OLMo's recipe is the most complete and reproducible |
| verl / OpenRLHF | T5 | Distributed RL | For multi-node multi-GPU |
| NCCL / Ray | T5 | Communication and scheduling | Only needed across machines |

> Version strategy: **pin the engine** (it decides whether the weights load), **pin the training stack via lockfiles** (it decides whether you can reproduce a fine-tune). Never `latest` for either.

**Air-gap drill (quarterly, 2 hours)**:
1. Unplug the network, leave one machine and one disk;
2. Build llama.cpp from source (or unpack the prebuilt binaries);
3. Load a GGUF, ask 10 questions, record tok/s;
4. Run `verify.sh` over all SHA256s;
5. Build a venv from scratch and install vLLM or transformers offline;
6. Run one LoRA fine-tune (even 100 steps);
7. Write the date, duration and failure points into `DRILL_LOG.md`.

---

## 7. Technical reports and knowledge: weights without papers are a black box

> The 42 documents in this section are fetched by [fetch-docs.sh](fetch-docs.sh) (the list is `docs.csv`), landing in `docs/arxiv/` and `docs/other/`, with an `index.md` generated. arXiv papers have no commit sha — **the fetch date is the evidence chain**, and `PROVENANCE.txt` records it.

Priority: **recipes you can reproduce > architecture papers > evaluation methods > surveys**. All PDFs total about 1–2GB, the best value for money of any tier.

### 7.1 Architecture and training foundations

| Topic | Paper | Link |
|---|---|---|
| Transformer | Attention Is All You Need (2017) | [1706.03762](https://arxiv.org/abs/1706.03762) |
| Scaled language models | Language Models are Few-Shot Learners (GPT-3) | [2005.14165](https://arxiv.org/abs/2005.14165) |
| Scaling laws | Scaling Laws for Neural Language Models | [2001.08361](https://arxiv.org/abs/2001.08361) |
| Compute-optimal training | Training Compute-Optimal LLMs (Chinchilla) | [2203.15556](https://arxiv.org/abs/2203.15556) |
| MoE routing | Switch Transformers | [2101.03961](https://arxiv.org/abs/2101.03961) |
| Fine-grained MoE | DeepSeekMoE | [2401.06066](https://arxiv.org/abs/2401.06066) |
| State-space models | Mamba | [2312.00752](https://arxiv.org/abs/2312.00752) |
| Positional encoding | RoPE | [2104.09864](https://arxiv.org/abs/2104.09864) |
| Attention variants | GQA | [2305.13245](https://arxiv.org/abs/2305.13245) |
| Long-context extrapolation | YaRN | [2309.00071](https://arxiv.org/abs/2309.00071) |
| Normalization/activations | RMSNorm [1910.07467](https://arxiv.org/abs/1910.07467) · GLU Variants [2002.05202](https://arxiv.org/abs/2002.05202) | — |

### 7.2 Technical reports of each open-model generation (the map of reproduction)

| Model | Report | Link |
|---|---|---|
| Llama 3 | The Llama 3 Herd of Models | [2407.21783](https://arxiv.org/abs/2407.21783) |
| Mistral 7B / Mixtral | — | [2310.06825](https://arxiv.org/abs/2310.06825) / [2401.04088](https://arxiv.org/abs/2401.04088) |
| DeepSeek-V2 | MLA + DeepSeekMoE | [2405.04434](https://arxiv.org/abs/2405.04434) |
| DeepSeek-V3 | 671B/37B, FP8 training | [2412.19437](https://arxiv.org/abs/2412.19437) |
| DeepSeek-R1 | Reasoning from pure RL | [2501.12948](https://arxiv.org/abs/2501.12948) |
| DeepSeek-V4 | Million-token context, CSA/HCA, mHC | [2606.19348](https://arxiv.org/abs/2606.19348) |
| Qwen3 | Unified dense+MoE family | [2505.09388](https://arxiv.org/abs/2505.09388) |
| Qwen3-Embedding | Multilingual vectors | [2506.05176](https://arxiv.org/abs/2506.05176) |
| Gemma 4 | Any modality | [2607.02770](https://arxiv.org/abs/2607.02770) |
| GLM-5 | DSA sparse attention | [2602.15763](https://arxiv.org/abs/2602.15763) |
| gpt-oss | OpenAI open weights | [2508.10925](https://arxiv.org/abs/2508.10925) |
| OLMo 3 | A fully open recipe | [2512.13961](https://arxiv.org/abs/2512.13961) |
| Nemotron 3 | Hybrid Mamba | [2512.20848](https://arxiv.org/abs/2512.20848) |
| Kimi K3 | 2.8T, KDA, AttnRes | [GitHub PDF](https://github.com/MoonshotAI/Kimi-K3/blob/main/k3_tech_report.pdf) |
| DeepSeek-OCR | Visually compressed text | [2510.18234](https://arxiv.org/abs/2510.18234) |

### 7.3 Alignment and interpretability

| Topic | Paper | Link |
|---|---|---|
| RLHF | InstructGPT | [2203.02155](https://arxiv.org/abs/2203.02155) |
| Preference optimization | DPO | [2305.18290](https://arxiv.org/abs/2305.18290) |
| Verifiable rewards | DeepSeekMath / GRPO | [2402.03300](https://arxiv.org/abs/2402.03300) |
| Constitutional AI | Constitutional AI | [2212.08073](https://arxiv.org/abs/2212.08073) |
| The mechanism of refusal | Refusal Is a Single Direction | [2406.11717](https://arxiv.org/abs/2406.11717) |

### 7.4 Inference, quantization and engineering

| Topic | Paper | Link |
|---|---|---|
| PagedAttention / vLLM | The foundation of serving | [2309.06180](https://arxiv.org/abs/2309.06180) |
| FlashAttention / v2 | IO-aware attention | [2205.14135](https://arxiv.org/abs/2205.14135) / [2307.08691](https://arxiv.org/abs/2307.08691) |
| LoRA / QLoRA | Low-cost fine-tuning | [2106.09685](https://arxiv.org/abs/2106.09685) / [2305.14314](https://arxiv.org/abs/2305.14314) |
| GPTQ / AWQ | Post-training quantization | [2210.17323](https://arxiv.org/abs/2210.17323) / [2306.00978](https://arxiv.org/abs/2306.00978) |
| Speculative decoding | Speculative Decoding | [2211.17192](https://arxiv.org/abs/2211.17192) |

### 7.5 Still to collect by hand

- **Karpathy's `nanoGPT` and `llm.c`**: the shortest path to training a small model from zero — better than any paper at teaching "where AI comes from".
- **Dive into Deep Learning (d2l.ai)**: offline HTML/PDF, covering everything up to Transformers.
- **Docs snapshots for each engine**: mirror `docs/` from llama.cpp and vLLM, and the SGLang docs site, with `wget --mirror`.
- **Model cards and license texts**: put a copy of `LICENSE` and `README` in each model directory; they are the only later evidence of "which terms I obtained this under".
- **Eval scripts**: `lm-evaluation-harness`, `lighteval`, and your own 20-question eval (the most important, because it runs offline).

---

## 8. For people with compute

### 8.1 Pick a tier by hardware

| Your hardware | Suggested tier | What it runs (measured sizes) | Key action |
|---|---|---|---|
| No dGPU, 32GB RAM | T0 | 4B Q4 (2.7GB) at ~5–8 tok/s; 0.8B real-time | Get llama.cpp working; make T0 a "boots without a network" USB stick |
| 1×24GB (4090/5090) | T1–T2 | 27B Q4 (16.6GB), 35B-A3B Q4 (22.1GB), 9B bf16 (19.3GB) | Keep 27B Q4 or 35B-A3B Q4 resident; the other on disk |
| 1×48–80GB (A6000/H100) | T2–T3 | 27B bf16 (55.6GB) + LoRA; 35B-A3B needs 64GB+ RAM | Keep a BF16 mother for fine-tuning; move the quantization pipeline in-house |
| 2×80GB | T3 | 27B original (55.6GB) + 35B-A3B original (71.9GB) at TP=2 | Get vLLM/SGLang tensor parallelism working; record the largest usable context |
| 8×80GB (640GB) | T3–T4 | GLM-5.3-Flash EXL3 4bpw (176), Qwen3.8-Flash-Next original (360) | Serving + eval + at least one reproducible fine-tuning recipe |
| 8×141GB (H200, 1.1TB) | T4–T5 | GLM-5.3-Flash original (328), V4.1-Flash (510), V3.2 bf16 (690) | Multi-tenant isolation; turn "model as a service" into an internal API |
| 8×180GB (B200, 1.4TB) | T4–T5 | V3.2 bf16 (690), V4.1-Flash bf16 (510) | Record FP8/FP4 precision loss; build your own eval baseline |
| 16–64×GB200 | T5 | V4-Pro (865), Kimi-K3 (1561) | Not a scale one person maintains; the point is **not letting these weights exist in only one machine room** |

### 8.2 The five things people with compute should do

1. **Build services that can restart offline**: model, engine, driver, container and start script on one disk; pull the cable and it still boots.
2. **Keep BF16 mothers**: quantized versions evolve with engines; BF16 is the negative you can re-quantize from ten years later.
3. **Build your own small eval**: 50–200 questions covering your language, domain and refusal boundaries; run it on every model/quantization change.
4. **Make off-site copies**: at least two physical locations for every set of weights; tape (LTO-9, 18TB/cartridge) for cold, SSD for hot.
5. **Write down "how to run it"**: commands, pitfalls, VRAM usage, tok/s. In three years you will be the ancient with no documentation.

### 8.3 Cost magnitudes (2026-11 estimates; very volatile, for budgeting only)

| Item | Magnitude | Note |
|---|---|---|
| 8×H100 node | $250k–$400k | Whole box with networking; used/rented differs |
| 8×H200 node | $350k–$500k | 141GB HBM suits long contexts |
| 20TB enterprise HDD | $300–$500 each | Cold-storage workhorse; buy two and mirror |
| 4TB NVMe | $250–$400 | Hot data + model workspace |
| LTO-9 tape drive | $4k–$6k | Only makes sense for institutions |
| LTO-9 tape (18TB) | $80–$120 each | The cheapest per-TB offline archive |
| Power | 6–10 kW for an 8-GPU node | A year of power can exceed a 20TB disk |

---

## 9. For people without compute

No GPU doesn't mean no place. **The barrier to local AI is no longer compute — it's whether anyone has organized the material, verified it, and taught it to someone else.**

### 9.1 Pick a tier by medium

| Medium | What goes on it | What it does |
|---|---|---|
| **8GB USB stick** | T0 (6.8GB) + a `llama.cpp` binary + the paper PDFs | Any computer, offline: writing, translation, summarization, transcription, TTS, retrieval |
| **32GB USB stick** | T0 + Wikipedia EN mini (ZIM) + your domain documents | Everything above + an offline knowledge base |
| **128GB stick / old phone card** | T1 (57.1GB) + Wikipedia nopic | 27B Q4 on a 32GB-RAM machine; 2B on your phone during the commute |
| **512GB SSD** | T2 (455.5GB) | A machine with 64GB RAM becomes a small AI workstation |
| **1TB SSD** | T3 (826.0GB) | One person can serve a community: models, corpora, eval, teaching |

### 9.2 What runs on a phone

- **0.6B–2B**: Qwen3.5-0.8B / 2B GGUF — llama.cpp, PocketPal, MLX all work; 2B does ~5–15 tok/s on a phone.
- **4B**: current flagship phones (12GB+ RAM) run Q4 at ~3–8 tok/s; fine for offline writing/translation.
- **Don't expect 27B on a phone**: it's not that it can't, it's that thermals and memory bandwidth make it "runs, but you won't want to use it".

### 9.3 Knowledge backups (cheaper and more durable than weights)

| Asset | Size | Why |
|---|---|---|
| Wikipedia ZIM (mini / nopic) | 1–2GB / 50–60GB | Humanity's largest public knowledge base; readable offline with Kiwix |
| Core paper PDFs (section 7) | 1–2GB | The map of reproduction |
| d2l.ai + Karpathy's course | <1GB | Learning "where AI comes from" from zero |
| Textbooks/standards/manuals in your field | 10–100GB | The tacit knowledge a model doesn't have |
| Open-source mirrors (llama.cpp, vLLM, transformers) | 5–20GB | Without code, weights are specimens |
| Model cards and license texts | <100MB | Later proof of "which terms I obtained this under" |

### 9.4 Six contributions that need no compute

1. **Seed/mirror**: turn T0/T1 into BitTorrents and keep seeding; bandwidth is compute.
2. **Verify**: run `verify.sh` for others and report bad blocks. Verification is the scarcest labour in any community.
3. **Translate**: model cards, papers, tutorials into your language; that's the real bottleneck for capability diffusion.
4. **Teach**: one "run AI offline" workshop at a library or school beats one more GPU.
5. **Organize**: record "which model on which hardware at how many tok/s" as a table; that's the infrastructure the community lacks most.
6. **Coordinate**: an 8TB NAS + three volunteers + a monthly verification is a seed library.

### 9.5 A minimal "seed library" operation

- **Hardware**: one 8TB NAS (or an old PC + 2×8TB mirrored disks) + one 128GB USB stick as the "lending stick".
- **Content**: all of T1 + the 27B/35B of T2 + papers + Wikipedia ZIM + local community corpora.
- **Rules**: only redistributable licenses; do not copy or lend gated models; every directory carries `PROVENANCE.txt` and `SHA256SUMS.txt`.
- **Cadence**: verify on the first weekend of each month; update the list quarterly; do one "offline drill" a year.
- **Growth**: sync between three libraries with hard drives, sneaker-net style, without depending on the cloud.

---

## 10. 30-day plan

### 10.1 Four-week plan

| Week | What to do | Output |
|---|---|---|
| **Week 1** | Get llama.cpp running; download T0; boot it with the network off | A working 8GB USB stick + the first `DRILL_LOG.md` entry |
| **Week 2** | Download T1; build `SHA256SUMS`; write a one-page "how to run it" | A 64GB medium + one page of SOP |
| **Week 3** | Download T2 or T3 by your hardware; collect section 7 papers; mirror engine docs | Workhorse models + an offline document library |
| **Week 4** | Make a second copy (off-site / different medium); rehearse recovery; send the list to 3 people | 3-2-1 achieved + a community starting point |

> Bandwidth estimate: on a 100Mbps home link, T1 (57GB) is ~1.3 hours, T2 (456GB) ~10 hours, T3 (826GB) ~18 hours, T5 (9.2TB) ~8.5 days. **Download T0/T1 first, then the big ones** — if you get the order wrong, an incident will arrive when you hold only half-finished files.

---

## 11. Law, licensing and boundaries

### 11.1 License differences (they decide whether you can "pass it to the next person")

| License | Representative | Redistributable | Note |
|---|---|---|---|
| MIT | all DeepSeek, bge-m3 | ✅ nearly unrestricted | Keep the copyright notice |
| Apache-2.0 | all Qwen, Gemma 4, OLMo, most tools | ✅ keep NOTICE/changes | The patent grant favours users |
| Llama 3.x community license | Llama-3.3 | ⚠️ conditional | 700M MAU clause, naming requirements, revocability |
| Gemma terms of use | Gemma 4 and earlier | ⚠️ version-dependent | Gemma 4 is tagged `apache-2.0` on HF, but its card also links the [Gemma 4 terms](https://ai.google.dev/gemma/docs/gemma_4_license); read both before commercial use |
| Kimi K3 / GLM License | the corresponding flagships | ⚠️ custom | Read clause by clause before commercial use; attribution/restriction terms are common |
| FLUX Non-Commercial | FLUX.1-dev | ❌ commercial use | Non-commercial only; redistribution restricted |
| AGPL-3.0 | Heretic | ✅ (copyleft) | Modify it and your changes must be open |

**Gated models (e.g. the Llama family)**: being able to download one does not mean you may download it for others, let alone redistribute it publicly. For such models this list only describes "a copy for yourself", never "pass it on".

### 11.2 Export control and borders

Whether model weights fall under export controls, and whether cross-border transfer needs a license, is still a grey area in 2026 and the rules keep changing. **Nothing here is legal advice.** The conservative approach:
- don't download gated models on someone else's behalf;
- check the current rules before carrying weights across a border;
- institutional users should go through legal counsel rather than substituting "technically transferable" for "legally transferable".

### 11.3 Safety: model files are executable code

- **Use `safetensors` and `GGUF` only**. `.bin`/`.pt`/`.pth` may contain pickles that execute on load.
- **Leave `trust_remote_code` off by default**; read the code before enabling it.
- **Run unfamiliar models in a sandbox/container**, and load them offline.
- **Don't keep weights and keys on the same disk**.
- **Verify hashes**: `verify.sh` is not a formality; it is the only way to notice a swapped file.

### 11.4 Ethics: a seed is not arson

- Keep the guard models (4.9) and enable them by default in your service.
- abliterated weights are for research, creation, and bypassing over-refusal — not for harm, fraud, or anything involving minors.
- If you hand a model to someone, hand over what it will say, what it won't, and how much capability was lost.
- The legitimacy of local AI comes from accountability: whoever deploys it, owns it. That is exactly why it is worth keeping over a black-box API.

---

## 12. Appendix

### A. Quick commands

```bash
# 1) Seed tier only (see the plan first)
TIER=0 DEST=/Volumes/SEED DRY=1 ./download.sh
TIER=0 DEST=/Volumes/SEED ./download.sh

# 2) Download a single model at a pinned revision (never use main)
hf download Qwen/Qwen3.8-27B \
  --revision 37561816e66b5b9153b1b64c10968c18c1e6f4a0 \
  --local-dir ./models/qwen3.8-27b \
  --exclude "original/*" --exclude "metal/*"

# 3) Fetch a single quantized file (GGUF repos often have dozens of quants)
hf download unsloth/Qwen3.8-27B-GGUF \
  --include "Qwen3.8-27B-UD-Q4_K_M.gguf" \
  --local-dir ./models/qwen3.8-27b-q4

# 4) Fill in non-HF assets (papers / engine sources)
./fetch-docs.sh   /Volumes/SEED/docs
./fetch-repos.sh  /Volumes/SEED/repos

# 5) Verify
./verify.sh /Volumes/SEED

# 6) Split + compress (for moving across filesystems)
zstd -T0 -19 model.gguf -o model.gguf.zst
split -b 20G model.gguf.zst model.gguf.zst.part-
# restore: cat model.gguf.zst.part-* | zstd -d > model.gguf

# 7) 5% redundancy volumes (only for critical files; very slow)
par2 create -r5 model.gguf.par2 model.gguf

# 8) Off-site incremental
rclone copy /Volumes/SEED remote:ark --progress --checksum
```

### B. What each model directory should contain

```
models/qwen3.8-27b/
├── PROVENANCE.txt      # repo_id / revision / download time / include
├── SHA256SUMS.txt      # hashes of every file
├── LICENSE             # the license text (copied from the repo)
├── README.md           # model card
├── config.json
├── tokenizer.json / tokenizer_config.json
├── chat_template.jinja
├── generation_config.json
└── *.safetensors
```

A "backup" missing `tokenizer` or `chat_template` is, at recovery time, a pile of matrices that can't hold a conversation.

### C. Recovery drill checklist

- [ ] Network off, only the backup medium attached
- [ ] Build llama.cpp from source (or unpack the prebuilt)
- [ ] Load a 4B model, ask 10 questions, record tok/s
- [ ] Load 27B Q4, ask 10 questions, record VRAM/RAM
- [ ] `verify.sh` passes entirely
- [ ] Build a venv offline and install transformers/vLLM
- [ ] Run one LoRA fine-tune (100 steps is enough)
- [ ] Build a 100-document RAG with the local model + bge-m3
- [ ] Write the failure points into `DRILL_LOG.md`; fix them first next time

### D. manifest.csv fields

| Field | Meaning |
|---|---|
| `tier` | The first tier it appears in (0–5); higher tiers include lower ones |
| `tier_name` | Tier name and target medium |
| `priority` | S/A/B |
| `category` | engine / tool / text-small / text-mid / text-frontier / vision / audio / ocr / embed / rerank / guard / abliterated / image / video / corpus / docs |
| `artifact` | Human-readable name and format |
| `repo_id` | HF repo; `-` means a non-HF asset |
| `revision` | commit sha or tag; `main` means unpinned (not recommended) |
| `size_gb` | Measured size (decimal GB) |
| `license` | Repo tag; read the original before commercial use |
| `note` | Why it's here and what it trades against |
| `include` | Fetch only this file (required for GGUF repos) |

### E. What this list cannot do

1. **It cannot replace compute.** 1.6T of weights with no GPU is a pile of matrices; the machine that runs 27B Q4 is the vehicle of the seed.
2. **It cannot replace data.** Pretraining corpora live in T6 and are not available in full to individuals; this list preserves "inference and fine-tuning" capability, not "pretraining a frontier model from scratch".
3. **It cannot replace people.** The real transmission is "someone who can run it, change it, and teach it"; weights are only the textbook.
4. **It will expire.** A model generation every six months, an engine swap every year, licenses change at any time. **Next review: 2027-02-13.**

### F. Changelog

| Date | Change |
|---|---|
| 2026-11-13 | v1 |
