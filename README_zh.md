# ai-backup-list/ — AI 备份清单

[English](README.md) | 中文
此repo存在的目的在于在发生重大事件（自然或是人为，抑或是超人为）后，您依然保有本地AI的火种，并能够从中恢复或继续保持使用。
根据您不同的硬盘尺寸，我手工选取了值得保存的开源模型权重，推理引擎，工具，技术报告和论文等，并定出了每一档的内容，提供了下载辅助脚本。希望给您提供一份高质量的清单。
建议您未雨绸缪，根据自己的情况选择下载。

每一个层级都会包含更小层级的所有内容。
| 层 | 目标介质 | 条数 | 本层增量 | 累计 | 适合谁 | 能做到什么 |
|---|---|---|---|---|---|---|
| **T0 火种** | 8GB U 盘 / 手机 | 8 | 6.8 GB | **6.8 GB** | 任何人 | 一台笔记本离线跑 4B 级模型 + 检索 + 转写 + 朗读 + 全部核心论文 |
| **T1 入门** | 64GB U 盘 / 旧 SSD | 9 | 50.2 GB | **57.1 GB** | 有一台 16–32GB 内存的电脑 | 27B 级模型（Q4）+ 35B-A3B（Q4）+ 9B 视觉语言 + 多语言检索 + 4 个 agent harness |
| **T2 主力** | 512GB SSD | 15 | 398.4 GB | **455.5 GB** | 一台 64GB 内存 / 24GB 显存的机器 | 两个大 MoE 的 4-bit 版（Flash-Next / GLM-5.3-Flash）+ 9B 视觉 + OCR + 语音 + 重排 + 护栏 + 向量 + 语料 |
| **T3 严肃** | 1TB SSD | 13 | 370.5 GB | **826.0 GB** | 单机 128GB 内存 / 1–2 张 80GB 卡 | 加：V4-Flash、Gemma-31B Q8、abliterated 全家桶、护栏模型、学术 OCR、6 个 abliteration 工具 |
| **T4 前沿** | 4TB HDD/SSD | 13 | 2408.6 GB | **3234.6 GB** | 8×80GB 或 1TB+ 内存的机器 | **原版 / 预训练母本**：GLM-5.3 Q4、V4.1-Flash、GLM-5.3-Flash、27B/35B 原版、Qwen3.5 两个 base、Gemma-4-31B base、视频生成 |
| **T5 方舟** | 20TB | 9 | 5953.3 GB | **9188.0 GB** | 小型机房 / 实验室 / 图书馆 | 加：V4-Pro-Base、Kimi-K3、GLM-5.3、V3.2-Exp-Base、R1、Llama-3.3-70B——1.5TB 级与最重的原版 |
| **T6 档案** | 100TB+ | 不枚举 | — | — | 机构 | 全量语料（FineWeb/Dolma/The Stack）、多副本、磁带冷备、镜像站 |


详细信息：[ai-backup-list_v1_zh.md](ai-backup-list_v1_zh.md)（v1.0，2026-11-13 复核 · T0 已全自动跑通）
配套文件：[manifest.csv](manifest.csv)（67 条)、[fetch-docs.sh](fetch-docs.sh)、[fetch-repos.sh](fetch-repos.sh)、[download.sh](download.sh)、[verify.sh](verify.sh)、[fetch-engines.sh](fetch-engines.sh)、[ladder.py](ladder.py)（生成 3.1 阶梯表与 3.2 档位明细）、[check-manifest.py](check-manifest.py)（联网核对 sha / 体积 / include）

## 快速开始

```bash
# 先看计划（不下载）
TIER=0 DEST=/Volumes/SEED DRY=1 ./download.sh

# 火种层（约 6.8GB，含 42 篇论文与 llama.cpp）
TIER=0 DEST=/Volumes/SEED ./download.sh

# 论文与引擎源码（download.sh 会自动调，也可单独跑）
./fetch-docs.sh  /Volumes/SEED/docs
./fetch-repos.sh /Volumes/SEED/repos

# 校验
./verify.sh /Volumes/SEED

# 改完清单后：确认正文与 CSV 没漂移 / 确认上游还是那些字节
./ladder.py --check ai-backup-list_v1_zh.md
./check-manifest.py --tier 2
```

## 如何贡献

清单会继续修，欢迎 issue 与 PR，哪怕只是一句"这个该换掉"。

**挑选方式。** 清单里的 **LLM 权重**与**推理引擎**是人工挑的：有一定的真机和实测经验判断，这也是我这份榜单最有价值的部分。其余部分（生图模型，论文、工具、agent harness、安装包、语料、文档）由 AI 辅助整理。所以前两块选错了，责任在人；后一块选错了，责任在模型。**最需要的建议，就在模型与引擎这两块。**

**提建议请带上：**

- 条目（`manifest.csv` 的 artifact 或 `repo_id`）与你要的增 / 删 / 换；
- 理由：为什么它更适合离线恢复，进哪一档，体积怎么变；
- 可核对的证据：commit sha、实测体积（十进制 GB，按 `download.sh` 的排除规则）、许可，以及一次真实下载或演练留下的 `PROVENANCE.txt`；
- **缺少哪些依赖？ 理想情况下希望这个repo下载的火种能够离线启动，所以断网后不会因为缺依赖没法用。**

**改清单的流程：**

1. 只改 `manifest.csv`；`revision` 必须是 commit sha，不认 `main`，也不认 tag。
2. `./ladder.py --check ai-backup-list_v1_zh.md` —— 正文与 CSV 漂了就重跑 `./ladder.py` 再提交。
3. `./check-manifest.py --tier N` —— 确认上游还在、sha 未变、体积未变。
4. PR 里说清改了什么、为什么、证据在哪。

**两个容易踩的坑：** 7 条 gated 仓库（Llama 系 3 条 + Llama-Guard、FLUX、fineweb-edu、dolma3_mix-6T、embeddinggemma）需先在 HF 接受条款并配 `HF_TOKEN`；真实下载后请保留 `PROVENANCE.txt` 与 `SHA256SUMS.txt`——恢复时它们是唯一的证据。有条件的话，强烈建议运行，这样可以确保没有确实依赖。
