# ai-backup-list/ — an ark for AI, a list for download

English | [中文](README_zh.md)

This repo exists so that after a major event — natural, man-made, or otherwise — you still hold a seed for local AI, and can recover it or keep using it.

Depending on your disk size, I hand-picked open weights models worth keeping, along with inference engines, tools, technical reports and papers; I decided what goes in each tier and wrote the download helper scripts. Hopefully it gives you a high-quality list.

Plan ahead and pick what fits your situation.

Every tier contains everything from the smaller tiers.
| Tier | Target media | Items | This tier | Cumulative | Who it's for | What you can do with it |
|---|---|---|---|---|---|---|
| **T0 Seed** | 8GB USB stick / phone | 8 | 6.8 GB | **6.8 GB** | anyone | Run a 4B-class model offline on one laptop + retrieval + transcription + TTS + all core papers |
| **T1 Starter** | 64GB stick / old SSD | 9 | 50.2 GB | **57.1 GB** | a machine with 16–32GB RAM | 27B-class model (Q4) + 35B-A3B (Q4) + 9B vision-language + multilingual retrieval + 4 agent harnesses |
| **T2 Main** | 512GB SSD | 15 | 398.4 GB | **455.5 GB** | 64GB RAM / 24GB VRAM | 4-bit versions of two large MoEs (Flash-Next / GLM-5.3-Flash) + 9B VL + OCR + speech + rerank + guard + embeddings + corpus |
| **T3 Serious** | 1TB SSD | 13 | 370.5 GB | **826.0 GB** | 128GB RAM / 1–2×80GB GPUs | Adds: V4-Flash, the abliterated family, a guard model, academic OCR, 6 abliteration tools, Gemma-31B Q8 |
| **T4 Frontier** | 4TB HDD/SSD | 13 | 2408.6 GB | **3234.6 GB** | 8×80GB or 1TB+ RAM | **Originals / pretraining mothers**: GLM-5.3 Q4, V4.1-Flash, GLM-5.3-Flash, 27B/35B originals, both Qwen3.5 bases, Gemma-4-31B base, video generation |
| **T5 Ark** | 20TB | 9 | 5953.3 GB | **9188.0 GB** | small machine room / lab / library | Adds: V4-Pro-Base, Kimi-K3, GLM-5.3, V3.2-Exp-Base, R1, Llama-3.3-70B — the 1.5TB-class and the heaviest originals |
| **T6 Archive** | 100TB+ | not enumerated | — | — | institutions | Full corpora (FineWeb/Dolma/The Stack), multiple copies, tape cold storage, mirrors |


Full detail: [ai-backup-list_v1.md](ai-backup-list_v1.md) (v1.0, reviewed 2026-11-13 · T0 runs end-to-end) · Chinese original: [ai-backup-list_v1_zh.md](ai-backup-list_v1_zh.md)
Companion files: [manifest.csv](manifest.csv) (67 entries), [fetch-docs.sh](fetch-docs.sh), [fetch-repos.sh](fetch-repos.sh), [download.sh](download.sh), [verify.sh](verify.sh), [fetch-engines.sh](fetch-engines.sh), [ladder.py](ladder.py) (generates the §3.1 ladder and §3.2 per-tier detail), [check-manifest.py](check-manifest.py) (online check of sha / size / include)

## Quick start

```bash
# See the plan first (no download)
TIER=0 DEST=/Volumes/SEED DRY=1 ./download.sh

# Seed tier (~6.8GB, including 42 papers and llama.cpp)
TIER=0 DEST=/Volumes/SEED ./download.sh

# Papers and engine sources (download.sh calls these, or run them yourself)
./fetch-docs.sh  /Volumes/SEED/docs
./fetch-repos.sh /Volumes/SEED/repos

# Verify
./verify.sh /Volumes/SEED

# After editing the manifest: confirm the text hasn't drifted, and upstream hasn't moved
./ladder.py --check ai-backup-list_v1_zh.md
./check-manifest.py --tier 2
```

## How to contribute

The list keeps changing. Issues and PRs are welcome — even just "this should be replaced".

**How it was picked.** The **LLM weights** and the **inference engines** were picked by hand, based on some real-machine, measured experience — and that is the most valuable part of this list. Everything else (image models, papers, tools, agent harnesses, installers, corpora, docs) was compiled with AI assistance. So if the first two blocks are wrong, that's on the human; if the rest is wrong, that's on the model. **Suggestions are most valuable on the models and engines side.**

**When you propose something, include:**

- the entry (an `artifact` or `repo_id` from `manifest.csv`) and what you want to add / remove / swap;
- why: how it suits offline recovery, which tier it belongs in, how the size changes;
- verifiable evidence: commit sha, measured size (decimal GB, under `download.sh`'s exclusion rules), license, and a real download or drill result (`PROVENANCE.txt`);
- for engines: the hardware you ran it on, quantization format, and measured throughput;
- **what's missing?** Ideally a seed downloaded from this repo boots offline, so that cutting the network doesn't leave you stuck on a missing dependency.

**Workflow for changing the list:**

1. Edit `manifest.csv` only; `revision` must be a commit sha — not `main`, not a tag.
2. `./ladder.py --check <doc>.md` — if the text has drifted, re-run `./ladder.py` and commit.
3. `./check-manifest.py --tier N` — confirm upstream is still there, sha unchanged, size unchanged.
4. In the PR, say what changed, why, and where the evidence is.

**Two easy traps:** the 7 gated repos (the 3 Llama ones + Llama-Guard, FLUX, fineweb-edu, dolma3_mix-6T, embeddinggemma) require accepting terms on HF and setting `HF_TOKEN`; after a real download keep `PROVENANCE.txt` and `SHA256SUMS.txt` — during recovery they are the only evidence. If you can, it is well worth actually running a drill; that's how you make sure nothing is in fact missing.

Contributions that are actually useful: tested sizes and throughput on real hardware, missing dependencies (the goal is that an offline machine boots from what you downloaded), license changes, and any real recovery-drill reports.

## License

The list, the scripts and the documents in this repo are MIT-licensed — see [LICENSE](LICENSE). **That does not cover the models themselves**: every entry keeps its upstream license (the `license` column in `manifest.csv`, and §11.1 of [ai-backup-list_v1.md](ai-backup-list_v1.md)); several are gated, non-commercial, or custom-licensed.
