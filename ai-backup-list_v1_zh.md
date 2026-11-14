# AI 备份清单 v1.0

**一份按硬盘大小分级的开放权重、推理引擎与技术文献清单**
整理日期：2026-11-13（v1.0 复核同日) · 配套文件：[manifest.csv](manifest.csv)（67 条)、[fetch-docs.sh](fetch-docs.sh)、[fetch-repos.sh](fetch-repos.sh)、[download.sh](download.sh)、[verify.sh](verify.sh)、[fetch-engines.sh](fetch-engines.sh)、[ladder.py](ladder.py)（生成 3.1 阶梯表与 3.2 档位明细）、[check-manifest.py](check-manifest.py)（联网核对 sha / 体积 / include）· English: [ai-backup-list_v1.md](ai-backup-list_v1.md)

## 1. 为什么需要这份清单

> 这份清单为一种并不戏剧化的事故而写：**平台的条款改了、模型页变成 404、许可证被重新解释、驱动不再支持你的卡、论文还在但复现所需的那个 tokenizer 没了。** 它不需要任何人下令，只需要几家公司各自理性地收紧一点。
>
> 排序标准只有一条：**在没有网络、没有 API、没有 Hugging Face 的情况下，一个普通人还能不能把 AI 跑起来、改下去、教给别人。**

---

## 2. 六条原则与分级标准

### 2.1 六条原则

1. **3-2-1**：三份副本、两种介质、一份异地。做不到三份，就做"两份 + 一份离线"。这是对您的期待。
2. **每层都要能独立点火**：引擎 + 权重 + 分词器 + chat template + 许可 + 评测脚本。缺一个都可能让"备份"变成一堆无法启动的字节。
3. **钉死 revision**：只认 commit sha，不认 `main`。`main` 是别人可以随时改的指针。
4. **权重不是能力**：推理引擎，相关知识，配置、模板、评测集同样重要。
5. **格式阶梯**：BF16 → FP8 → GGUF Q4。Q4能跑起来，但是原版知识更细腻，但每一层都要能降级运行，直到一台没有 GPU 的笔记本。
6. **没有演练的备份等于没有备份**：下载后进行演练，每半年在一台断网机器上从零启动一次。

### 2.2 重要度（`priority`）

**S → A → B**，我的定义

| 级 | 定义 | 判断问题 |
|---|---|---|
| **S** | 文明级可选性：没有它，后来者无法在断网环境下重建同等能力 | "一个文件浓缩了千百年的人类发展" |
| **A** | 显著改变个人/小机构的能力边界 | "它的在这个档位下处于帕累托前沿，没了它我会非常伤心" |
| **B** | 特定领域或前沿规模，缺了不影响"继续做 AI" | "删了会后悔吗？大概不会， 但是留着可以代表某些独特的思考风格或者知识库，或者更深入开发的起点" |

### 2.3 类别（`category`）

类别只用于检索，不构成优先级：`engine`（推理引擎/构建物）、`tool`（abliteration 等工具）、`text-small` / `text-mid` / `text-frontier`（按参数量分档的文本模型）、`vision`、`audio`、`ocr`、`embed`、`rerank`、`guard`（护栏）、`abliterated`（去审查权重）、`agent`（agent harness）、`installer`（预编译安装包）、`image`、`video`、`corpus`（语料）、`docs`（论文与文档）。

> 体积阶梯（§3.1）按**容量**分档，重要度按**缺了会怎样**分级——两者是两条正交的轴：一个 S 级资产可能只有 0.3GB（llama.cpp 源码），一个 B 级资产可能有 57GB（FLUX）。

---

## 3. 体积阶梯与档位清单

### 3.1 体积阶梯（实测，十进制 GB；硬盘厂商标称也是十进制）

| 层 | 目标介质 | 条数 | 本层增量 | 累计 | 适合谁 | 能做到什么 |
|---|---|---|---|---|---|---|
| **T0 火种** | 8GB U 盘 / 手机 | 8 | 6.8 GB | **6.8 GB** | 任何人 | 一台笔记本离线跑 4B 级模型 + 检索 + 转写 + 朗读 + 全部核心论文 |
| **T1 入门** | 64GB U 盘 / 旧 SSD | 9 | 50.2 GB | **57.1 GB** | 有一台 16–32GB 内存的电脑 | 27B 级模型（Q4）+ 35B-A3B（Q4）+ 9B 视觉语言 + 多语言检索 + 4 个 agent harness |
| **T2 主力** | 512GB SSD | 15 | 398.4 GB | **455.5 GB** | 一台 64GB 内存 / 24GB 显存的机器 | 两个大 MoE 的 4-bit 版（Flash-Next / GLM-5.3-Flash）+ 9B 视觉 + OCR + 语音 + 重排 + 护栏 + 向量 + 语料 |
| **T3 严肃** | 1TB SSD | 13 | 370.5 GB | **826.0 GB** | 单机 128GB 内存 / 1–2 张 80GB 卡 | 加：V4-Flash、Gemma-31B Q8、abliterated 全家桶、护栏模型、学术 OCR、6 个 abliteration 工具 |
| **T4 前沿** | 4TB HDD/SSD | 13 | 2408.6 GB | **3234.6 GB** | 8×80GB 或 1TB+ 内存的机器 | **原版 / 预训练母本**：GLM-5.3 Q4、V4.1-Flash、GLM-5.3-Flash、27B/35B 原版、Qwen3.5 两个 base、Gemma-4-31B base、视频生成 |
| **T5 方舟** | 20TB | 9 | 5953.3 GB | **9188.0 GB** | 小型机房 / 实验室 / 图书馆 | 加：V4-Pro-Base、Kimi-K3、GLM-5.3、V3.2-Exp-Base、R1、Llama-3.3-70B——1.5TB 级与最重的原版 |
| **T6 档案** | 100TB+ | 不枚举 | — | — | 机构 | 全量语料（FineWeb/Dolma/The Stack）、多副本、磁带冷备、镜像站 |

> 表里的数字由 [ladder.py](ladder.py) 从 `manifest.csv` 直接算出：改了清单就重跑 `./ladder.py`，再用 `./ladder.py --check ai-backup-list_v1_zh.md` 确认正文没漂移（初版就是在这里漂的）。
>
> **盘为什么是这几个尺寸**：早期补上了正文里漏在 CSV 外的 11 条（+126.2GB），T2 因此必须 512GB（256GB 装不下）；删掉 4 条 gpt-oss（−134.7GB）后，T3 和 T4 又装得回 1TB / 4TB；把 T2 改成纯 4-bit 档（382.9GB）后，512GB 仍然够用。**想省盘就按需挑**：每条 note 都写明它和谁二选一（如 DeepSeek-OCR 对 Unlimited-OCR、Qwen3-Embedding 的 safetensors 对 GGUF）。
>
> **余量**：T0 86%、T1 89%、T2 89%、T3 83%、T4 80%——T1 那 57.1GB 在 64GB 盘上是 53.2GiB / 59.6GiB，只剩约 6GiB；T2 的 455.5GB 在 512GB 盘上是 424GiB / 477GiB，还有约 53GiB；T3 的 826.0GB 在 1TB 盘上是 769GiB / 931GiB，还有约 162GiB；T4 的 3234.6GB 在 4TB 盘上是 3012GiB / 3725GiB，还有约 713GiB。
>
> **各档的量化约定**：**T2 只放 4-bit**（EXL3 / GGUF Q4，跑得动、占得少）；**T3 放中量与特殊件**（V4-Flash、abliterated、护栏、OCR）；**T4 放原版**（FP8/BF16/压缩权重，用来微调、再量化、做母本）。知识密集型用途请把对应模型换成更高的比特：GLM-5.3-Flash 的 Q6 是 292GB（`UD-Q6_K_XL`），比 4-bit 多 116GB，换来的是事实回忆和长文档一致性。
>
> **revision 已全部钉死**：所有 HF / GitHub 资产都指向具体 commit sha（只有 llama.cpp 按 tag `v1.0.0`，维基 dump 直接走 `dumps.wikimedia.org`），其中一条的 sha 原本抄错了仓库。`./check-manifest.py` 可随时联网复核。

### 3.2 每个档位装了什么

按档位分开列出的完整清单（同一档内按体积降序）。别人拿到这份清单时，先看这一节决定要买多大的盘，再看第 4 节按能力挑具体权重。想整档拿走：`TIER=<档号> DEST=<目标盘> ./download.sh`，会连带下载更低层级（`TIER=2` 即 T0+T1+T2）。

> `†` = 不是 HuggingFace / GitHub 资产，`download.sh` 会跳过：语料见 §4.11、引擎用 `fetch-engines.sh`、论文见 §7。

**T0 火种** · 8GB U 盘 / 手机 · 8 件 · 6.8 GB

| 资产 | 类别 | 体积 | 级 |
|---|---|---|---|
| Qwen3.5-4B GGUF Q4_K_M | text-small | 2.74 | S |
| Qwen3.5-2B GGUF Q5_K_M | text-small | 1.44 | S |
| Qwen3.5-0.8B GGUF Q8_0 | text-small | 0.81 | S |
| Qwen3-Embedding-0.6B GGUF Q8_0 | embed | 0.64 | A |
| whisper-tiny (PyTorch/CT2) | audio | 0.61 | B |
| Kokoro-82M TTS | audio | 0.36 | B |
| llama.cpp 源码 + 预编译 (linux/mac/win/arm) | engine | 0.12 | S |
| 核心论文与文档包 (PDF/HTML/MD) | docs | 0.12 | S |

**T1 入门** · 64GB U 盘 / 旧 SSD · 9 件 · 50.2 GB

| 资产 | 类别 | 体积 | 级 |
|---|---|---|---|
| Qwen3.6-35B-A3B GGUF Q4_K_M | text-mid | 22.13 | A |
| Qwen3.8-27B GGUF Q4_K_M | text-mid | 16.56 | S |
| Qwen3.5-9B GGUF Q5_K_M | text-mid | 6.58 | A |
| BAAI/bge-m3 | embed | 2.30 | A |
| 独立安装包（release 资产） | installer | 1.60 | S |
| Hermes Agent | agent | 0.42 | S |
| ohmypi (omp) | agent | 0.33 | S |
| DeepSeek Harness (dsh) | agent | 0.25 | S |
| pi (earendil-works) | agent | 0.08 | S |

**T2 主力** · 512GB SSD · 15 件 · 398.4 GB

| 资产 | 类别 | 体积 | 级 |
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
| 推理引擎与工具仓库 (§5) | engine | 1.55 | S |
| embeddinggemma-300m | embed | 1.27 | B |
| Qwen3-Embedding-0.6B | embed | 1.21 | A |

**T3 严肃** · 1TB SSD · 13 件 · 370.5 GB

| 资产 | 类别 | 体积 | 级 |
|---|---|---|---|
| DeepSeek-V4-Flash | text-frontier | 159.63 | S |
| Nemotron-3-Nano-30B-A3B | text-mid | 63.20 | A |
| Qwen-Image | image | 57.70 | B |
| Gemma-4-31B-it GGUF Q8_0 | text-mid | 32.64 | B |
| Llama-Guard-4-12B | guard | 24.00 | A |
| olmOCR-2-7B | ocr | 16.60 | B |
| Huihui-Qwen3.8-27B-abliterated GGUF Q4_K_M | abliterated | 16.55 | A |
| refusal_direction（论文复现） | tool | 0.09 | B |
| OBLITERATUS | tool | 0.08 | A |
| remove-refusals-with-transformers | tool | 0.0027 | A |
| Heretic | tool | 0.0022 | S |
| repeng（控制向量） | tool | 0.0010 | B |
| abliterator | tool | 0.0002 | B |

**T4 前沿** · 4TB HDD/SSD · 13 件 · 2408.6 GB

| 资产 | 类别 | 体积 | 级 |
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
| FineWeb-Edu sample-10BT + 中文语料样本 | corpus | 30.00 | B |
| Qwen3.5-9B-Base | text-small | 19.33 | A |

**T5 方舟** · 20TB · 9 件 · 5953.3 GB

| 资产 | 类别 | 体积 | 级 |
|---|---|---|---|
| DeepSeek-V4-Pro-Base | text-frontier | 1606.07 | B |
| Kimi-K3 | text-frontier | 1560.90 | S |
| GLM-5.3 | text-frontier | 755.70 | S |
| DeepSeek-V3.2-Exp-Base | text-frontier | 689.50 | B |
| DeepSeek-R1 | text-frontier | 688.60 | B |
| Dolma3 / The Stack v2 样本 | corpus | 500.00 | B |
| Llama-3.3-70B-Instruct | text-mid | 141.10 | B |
| SDXL base 1.0 | image | 6.94 | B |
| Qwen3-TTS-12Hz-1.7B-Base | audio | 4.54 | B |

### 3.3 能力密度排行（每 GB 换来的能力）

如果你只有一个 U 盘、或者只想记住"先拿哪几个"，按这个顺序：

| 排名 | 资产 | 体积 | 为什么排这里 |
|---|---|---|---|
| 1 | **llama.cpp 源码 + 一个 GGUF** | 0.3 + 2.7 GB | 没有它，权重只是文件；有它，任何 CPU 都能推理 |
| 2 | **Qwen3.5-4B Q4** | 2.7 GB | 4B 是"能干活"的最低门槛：写作、翻译、基础代码、工具调用 |
| 3 | **Qwen3.8-27B Q4** | 16.6 GB | 单机能力的拐点：接近可用的 agent、原生视觉、26 万上下文 |
| 4 | **bge-m3 + bge-reranker** | 4.6 GB | 让模型能读你自己的资料；RAG 是本地 AI 的一半价值 |
| 5 | **whisper-large-v3-turbo** | 1.6 GB | 语音是最大的一类"尚未被数字化"的知识 |
| 6 | **Qwen3.6-35B-A3B Q4** | 22.1 GB | 3B 激活、35B 知识：笔记本也能跑的高质量 MoE |
| 7 | **abliterated 27B** | 16.6 GB | 不被上游改主意的版本；研究"审查如何工作"的活标本 |
| 8 | **Qwen3.8-27B 原版** | 55.6 GB | 能微调、能量化、能再蒸馏的母本（T4） |
| 9 | **GLM-5.3-Flash EXL3 4bpw** | 175.7 GB | 321B 的 4-bit：T2 里能力最陡的一档，中文与工具调用都比同尺寸强 |

---

## 4. 权重清单（按类别）

> 完整机器可读版本见 [manifest.csv](manifest.csv)，含每条记录的 commit sha 与 `--include` 文件名。下表体积为实测（2026-11-13），许可按仓库标签，商用前请读原文。
>
> **命名规则**：原版权重只写模型名（不标精度）——很多"开放权重"的原版其实是 FP8 或 FP4，不是 BF16，具体精度写在该行备注里；只有**量化过的文件**才标格式（`GGUF Q4_K_M`、`EXL3 4bpw`、`Q8_0` …）。4-bit 是功能型资产（跑起来、做 agent）的默认档；知识型资产建议用 Q6/Q8 或直接留原版。

### 4.1 旗舰开放权重（T4–T5）

| 模型 | 仓库（revision） | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| DeepSeek-V4-Pro-Base | `deepseek-ai/DeepSeek-V4-Pro-Base @ 98730c0` | 1606.1 GB | T5 | MIT | B | V4-Pro 的预训练母本（BF16，比 FP4 版大一倍）；只给真要重训的人 |
| Kimi-K3 | `moonshotai/Kimi-K3` @ f831ab6 | 1560.9 GB | T5 | Kimi K3 License | S | 2.8T，896 专家取 16，原生多模态 |
| GLM-5.3 | `zai-org/GLM-5.3` @ ba32f8c | 755.7 GB | T5 | GLM License | S | 753B；中文与工具调用 |
| GLM-5.3 GGUF UD-Q4_K_XL | `unsloth/GLM-5.3-GGUF` @ 346b359 | 467.3 GB | T4 | GLM License | S | 可选量化版：11 分片；Q3_K_XL 343GB / IQ4_XS 365GB 更省；与 T5 的 FP8 原版二选一 |
| DeepSeek-V3.2-Exp-Base | `deepseek-ai/DeepSeek-V3.2-Exp-Base @ b21ef15` | 689.5 GB | T5 | MIT | B | V3.2 的预训练母本（base_model 字段指向它）；后训练从这里重来 |
| DeepSeek-R1 | `deepseek-ai/DeepSeek-R1` @ 56d4cbb | 688.6 GB | T5 | MIT | B | 推理链谱系源头；哲学家 |
| DeepSeek-V4.1-Flash | `deepseek-ai/DeepSeek-V4.1-Flash` @ 314113f | 510.3 GB | T4 | MIT | A | 763B，V4 迭代 |
| GLM-5.3-Flash | `zai-org/GLM-5.3-Flash` @ 46a050b | 328.4 GB | T4 | MIT | A | 321B，性价比最高的中文前沿权重 |
| Qwen3.8-Flash-Next | `Qwen/Qwen3.8-Flash-Next` @ 812d96e | 360.0 GB | T4 | Qwen License | B | 180B；社区 abliterated 的主要基座 |
| Nemotron-3-Super-120B-A12B | `nvidia/NVIDIA-Nemotron-3-Super-120B-A12B-BF16` @ 2dc98e2 | 247.2 GB | T4 | NVIDIA Open | B | 120B/12B 激活，混合 Mamba |

### 4.2 单机主力（T1–T4）

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Qwen3.8-27B | `Qwen/Qwen3.8-27B` @ 3756181 | 55.6 GB | T4 | Apache-2.0 | S | 27B 稠密，原生视觉+视频，26 万上下文可扩到 100 万 |
| Qwen3.8-27B GGUF Q4_K_M | `unsloth/Qwen3.8-27B-GGUF` @ 4af51b3 | 16.6 GB | T1 | Apache-2.0 | S | 单机甜点；同仓还有 IQ2 到 Q8 全档 |
| Qwen3.6-35B-A3B | `Qwen/Qwen3.6-35B-A3B` @ 345d467 | 71.9 GB | T4 | Apache-2.0 | S | 35B 总参/3B 激活；agentic coding |
| Qwen3.6-35B-A3B GGUF Q4_K_M | `unsloth/Qwen3.6-35B-A3B-GGUF` @ a483e9e | 22.1 GB | T1 | Apache-2.0 | A | 16GB 内存可跑 |
| GLM-5.3-Flash EXL3 4bpw | `Mia-AiLab/GLM-5.3-Flash-EXL3-4bpw-TensorFold` @ 76c0b51 | 175.7 GB | T2 | GLM License | A | 321B 的 4-bit 版（EXL3，83 分片）；原版 FP8 328GB 在 T4 |
| Qwen3.8-Flash-Next GGUF Q4_K_XL | `unsloth/Qwen3.8-Flash-Next-GGUF` @ f5d175d | 111.3 GB | T2 | Qwen License | A | 180B 的 4-bit 版；原版 BF16 360GB 在 T4 |
| Qwen3.5-9B | `Qwen/Qwen3.5-9B` @ c202236 | 19.3 GB | T2 | Apache-2.0 | A | 9B 视觉语言；GGUF Q5 为 6.6GB |
| Gemma-4-31B | `google/gemma-4-31B @ 5bbc2fb` | 62.6 GB | T4 | Apache-2.0 | B | Gemma-4-31B-it 的预训练版本 |
| Gemma-4-31B-it GGUF Q8_0 | `unsloth/gemma-4-31B-it-GGUF` @ c1ac76e | 32.6 GB | T3 | Apache-2.0 | B | Q8 单文件；Q4_K_M 18.3GB 更省；母本在 T4 |
| Qwen3.5-35B-A3B-Base | `Qwen/Qwen3.5-35B-A3B-Base` @ 0f08130 | 71.9 GB | T4 | Apache-2.0 | S | Qwen 官方唯一可用的 30B 级 base（27B 三代都没发 base） |
| Qwen3.5-9B-Base | `Qwen/Qwen3.5-9B-Base` @ 68c46c4 | 19.3 GB | T4 | Apache-2.0 | A | 9B 的 base：单卡就能重做对齐实验的练手母本 |
| Nemotron-3-Nano-30B-A3B | `nvidia/NVIDIA-Nemotron-3-Nano-30B-A3B-BF16` @ bf77c31 | 63.2 GB | T3 | NVIDIA Open | A | 长上下文高效 |
| DeepSeek-V4-Flash | `deepseek-ai/DeepSeek-V4-Flash` @ 60d8d70 | 159.6 GB | T3 | MIT | S | 284B/13B 激活、1M 上下文、FP4+FP8 混合；46 分片 |
| Llama-3.3-70B-Instruct | `meta-llama/Llama-3.3-70B-Instruct` @ 6f6073b | 141.1 GB | T5 | Llama-3.3 | B | 旧生态兼容层；需接受许可 |

### 4.3 小模型火种（T0）

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Qwen3.5-0.8B Q8_0 | `unsloth/Qwen3.5-0.8B-GGUF` | 0.81 GB | T0 | Apache-2.0 | S | 手机 / 树莓派；Q4 仅 0.53GB |
| Qwen3.5-2B Q5_K_M | `unsloth/Qwen3.5-2B-GGUF` | 1.44 GB | T0 | Apache-2.0 | S | 8GB 内存笔记本主力 |
| Qwen3.5-4B Q4_K_M | `unsloth/Qwen3.5-4B-GGUF` | 2.74 GB | T0 | Apache-2.0 | S | 性价比拐点；Q8 为 4.48GB |

### 4.4 代码与 agent

没有独立的"代码模型"也能活：Qwen3.8-27B 与 Qwen3.6-35B-A3B 的 agentic coding 已覆盖大多数场景；要更大的，Kimi-K3（T5，1.56TB）本身就带代码能力，这也是删掉 K2.7-Code 那类 1T 旧代的原因。预算有限时优先 Qwen3.6-35B-A3B（22GB Q4），它在仓库级推理上比同尺寸稠密模型更稳。

### 4.5 多模态与 OCR

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Qwen3-VL-8B-Instruct | `Qwen/Qwen3-VL-8B-Instruct` @ 0c351dd | 17.5 GB | T2 | Apache-2.0 | A | 文档/图表/视频理解 |
| DeepSeek-OCR | `deepseek-ai/DeepSeek-OCR` @ 9f30c71 | 6.7 GB | T2 | MIT | A | 3.3B，性价比最高的 OCR |
| olmOCR-2-7B | `allenai/olmOCR-2-7B-1025` @ e52d6f0 | 16.6 GB | T3 | Apache-2.0 | B | 学术 PDF 结构化 |
| GLM-OCR | `zai-org/GLM-OCR` @ 2e85a62 | 2.7 GB | T2 | MIT | B | 轻量中文 OCR |

### 4.6 语音

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| whisper-large-v3-turbo | `openai/whisper-large-v3-turbo` @ 41f01f3 | 1.6 GB | T2 | MIT | A | 多语言 ASR 事实标准 |
| whisper-tiny | `openai/whisper-tiny` @ 169d4a4 | 0.15 GB | T0 | MIT | B | 离线最小件；仓库含 h5/bin/safetensors/msgpack 四份等价权重，全下载 0.61GB |
| parakeet-tdt-0.6b-v3 | `nvidia/parakeet-tdt-0.6b-v3` @ 541d1f9 | 2.5 GB | T2 | CC-BY-4.0 | A | 英文更快更准；GGUF 仅 0.7GB，全仓（.nemo+safetensors+GGUF）5.73GB |
| Kokoro-82M | `hexgrad/Kokoro-82M` @ f3ff357 | 0.36 GB | T0 | Apache-2.0 | B | CPU 实时 TTS；权重是 `.pth`（pickle 容器），只从官方仓库取，加载时用 `weights_only=True` |
| Qwen3-TTS-1.7B | `Qwen/Qwen3-TTS-12Hz-1.7B-Base` @ fd4b254 | 4.54 GB | T5 | Apache-2.0 | B | 多语言 TTS，克隆需授权 |

### 4.7 图像 / 视频 / 音乐

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Qwen-Image | `Qwen/Qwen-Image` @ 75e0b4b | 57.7 GB | T3 | Apache-2.0 | B | 20B 生成/编辑，中文排版强 |
| FLUX.1-dev | `black-forest-labs/FLUX.1-dev` @ 3de623f | 57.9 GB | T4 | **非商用** | B | 生态最大；许可限制最严 |
| Wan2.2-T2V-A14B | `Wan-AI/Wan2.2-T2V-A14B` @ c8c270b | 126.2 GB | T4 | Apache-2.0 | B | 开源视频生成头部；高/低噪双塔 + umt5 编码器 |
| SDXL base 1.0 | `stabilityai/stable-diffusion-xl-base-1.0` @ 4621659 | 6.9 GB | T5 | OpenRAIL++ | B | 只取单文件 checkpoint（`--include`）；全仓 76.9GB 是多套等价格式 |

### 4.8 向量与重排（RAG 的骨架）

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Qwen3-Embedding-0.6B | `Qwen/Qwen3-Embedding-0.6B` @ 97b0c61 | 1.2 GB | T2 | Apache-2.0 | A | 102 种语言；GGUF Q8 仅 0.64GB |
| Qwen3-Embedding-8B | `Qwen/Qwen3-Embedding-8B` @ 1d8ad4c | 15.1 GB | T2 | Apache-2.0 | A | MTEB 头部；单卡可跑 |
| bge-m3 | `BAAI/bge-m3` @ 5617a9f | 2.3 GB | T1 | MIT | A | 稠密+稀疏+多向量，常青树 |
| bge-reranker-v2-m3 | `BAAI/bge-reranker-v2-m3` @ 953dc6f | 2.3 GB | T2 | Apache-2.0 | A | 小到该无条件带上 |
| embeddinggemma-300m | `google/embeddinggemma-300m` @ 57c266a | 1.2 GB | T2 | Gemma | B | 端侧检索 |

### 4.9 安全与审核（护栏）

保留护栏不是"站队"，是**让火种可被信任地传递**。一个没有审核能力的本地 AI 社区，第一次事故就会被当成禁止它的理由。

| 模型 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Llama-Guard-4-12B | `meta-llama/Llama-Guard-4-12B` @ 87acb4b | 24.0 GB | T3 | Llama-4 | A | 多模态输入审核 |
| Shieldstral-1.0-3B | `mistralai/Shieldstral-1.0-3B` @ 003ec7e | 15.4 GB | T2 | Apache-2.0 | B | 3.8B 小护栏（fp32 存储偏大，可转 bf16） |

### 4.10 abliterated / 去审查：权重与工具

**它是什么**：abliteration 通过找到并消去模型内部"拒绝方向"，在不重新训练的情况下移除拒答行为。2024 年的机制论文是 [Refusal in Language Models Is Mediated by a Single Direction](https://arxiv.org/abs/2406.11717)（Arditi 等）。2026 年的两个主流工具是 [Heretic](https://github.com/p-e-w/heretic)（v2.1.0，40.5k stars，训练无关，支持 bitsandbytes 4bit，一下午能在游戏 PC 上跑完）和 [OBLITERATUS](https://github.com/elder-plinius/OBLITERATUS)（v0.1.4，9.5k stars，Gradio 界面 + 多方法 + 自带拒绝率/能力对比报告）。它们把"去审查"从手工调参变成了可复现的流程；早期 [FailSpy/abliterator](https://github.com/FailSpy/abliterator) 的方法论仍值得读，但日常已基本被前两者取代。

| 资产 | 仓库 | 体积 | 档 | 许可 | 级 | 备注 |
|---|---|---|---|---|---|---|
| Huihui-Qwen3.8-27B-abliterated GGUF Q4_K_M | `huihui-ai/Huihui-Qwen3.8-27B-abliterated-GGUF` @ 06b4baa | 16.6 GB | T3 | Apache-2.0 | A | 单文件即可跑；T3 里唯一的 27B abliterated（原表误抄了 BF16 母本的 sha，已修正） |
### 4.10.1 工具：六个，各管一段

工具比模型便宜得多（六个加起来 180MB），但没有它们，上表那些权重就只是别人的二进制。六个都按 commit 钉死、能离线取回（`download.sh` 认 `github.com/` 条目）。

| 工具 | 仓库（版本） | 体积 | 档 | 许可 | 级 | 什么时候用 |
|---|---|---|---|---|---|---|
| **Heretic** | `github.com/p-e-w/heretic` @ v2.1.0 | 2.2 MB | T3 | AGPL-3.0 | S | 默认选手：一条命令、训练无关，一个下午出可用权重；pip 包名 `heretic-llm` |
| **OBLITERATUS** | `github.com/elder-plinius/OBLITERATUS` @ v0.1.4 | 84 MB | T3 | AGPL-3.0 | A | 要界面、要对比报告、要在 HF Space 上零安装跑；Docker/CLI/Colab 六种用法，遥测本地默认关闭 |
| **remove-refusals-with-transformers** | `github.com/Sumandora/remove-refusals-with-transformers` @ 7786b0a | 2.7 MB | T3 | Apache-2.0 | A | 只有 HF Transformers、不想装 TransformerLens；代码最短，最好改成自己的 |
| **abliterator** | `github.com/FailSpy/abliterator` @ 56ee3f7 | 0.2 MB | T3 | MIT | B | 要自己写正交化/消融实验；2024-06 后未更新，当方法论参考 |
| **refusal_direction** | `github.com/andyrdt/refusal_direction` @ 9d852fa | 90 MB | T3 | Apache-2.0 | B | 想搞清"为什么删一个方向就够"、要复现论文数字；带结果与数据 |
| **repeng** | `github.com/vgel/repeng` @ 0ba7196 | 1 MB | T3 | MIT | B | 控制向量（steering）：不是 abliteration，是它的对照组和更细的调节旋钮 |

**怎么选**：只留一个 → Heretic；要给别人看/做评测报告 → 加 OBLITERATUS；要改代码 → 加 remove-refusals；教学或写文章 → 加 refusal_direction；做对照实验 → 加 repeng。

> 注意：源码只是壳子，真正要备的是依赖——`torch`、`transformers`、`transformer-lens`、`bitsandbytes`，一个能跑 Heretic 的 venv 约 3–6GB。按第 6 节的做法把 wheel 一起存下来，否则三年后 pip 装不上。

**三条边界，必须写进清单**：

1. **许可继承**：abliterated 权重继承上游许可（上表都是 Apache-2.0，可再分发）；但 Llama/Gemma 系的上游许可含使用限制，去审查不解除这些限制。
2. **能力会下降**：消去拒绝方向通常伴随 1–5% 的通用能力损失，安全对齐越强的模型损失越明显。上线前用你自己的评测集对比母本。
3. **去审查 ≠ 去责任**：这份清单的目的是"不被上游随时改主意"，不是"批量生产有害内容"。保留 4.9 的护栏；对输出负责的是人，不是权重。

### 4.11 语料（T2–T5，可选）

权重是"怎么想"，语料是"知道什么"。个人备份优先序：**Wikipedia（21GB，CC-BY-SA，走 `dumps.wikimedia.org`，不是 HF）→ FineWeb-Edu 10BT 样本（约 30GB）→ 你所在领域的私有文本**。后两者在 HF 上都是 **gated**（`fineweb-edu`、`dolma3_mix-6T` 直接返回 401），要先接受条款并配 token；全量 FineWeb（约 45TB）、Dolma3（6T tokens）、The Stack v2（代码，gated）属于 T6 机构级，不在个人清单里。

---

## 5. 推理引擎与运行时（版本：2026-11-13）

引擎比模型更容易"死"：模型文件还在，能跑它的二进制没了。**每个引擎至少留：源码 tarball + 一个能用的二进制/容器 + 版本号 + 构建脚本。**

| 引擎 | 档 | 版本 | 平台 | 用途 | 必须一起备什么 |
|---|---|---|---|---|---|
| **llama.cpp** | **T0** | v1.0.0（2026-11-13） | CPU / Metal / CUDA / Vulkan | GGUF 推理的事实标准；无外部依赖；**重要性最高** | 源码 tarball + 各平台预编译（v1.0.0 只发源码，二进制取 nightly `b12368`）+ 一个 GGUF |
| **Strata** | **T2** | HEAD @ `13eedf5` | Windows / Linux / macOS | 给 Qwen3.8-Flash-Next / GLM / DeepSeek 这类大 MoE 做"一键跑"：权重管理 + SSD 流式回读（内存不够时慢而不崩），桌面端有 GUI | 源码 + 预编译安装包（`fetch-repos.sh` 取源码；安装包需手工下） |
| **DwarfStar4 (ds4)** | **T2** | HEAD @ `b3f5018` | Metal / CUDA / ROCm | DeepSeek V4 系专用引擎：Metal 上 64GB 跑 Qwen Flash Next、96GB+ 跑 DeepSeek/GLM，核显 Strix Halo 也支持；可多机 RDMA 拼内存 | 源码 + 你所在平台的预编译 |
| ExLlamaV2 | T2 | 0.3.2（2025-07 后少更新） | NVIDIA | 低显存/旧卡；EXL3 量化的原生运行时 | 源码 + wheel；注意维护风险 |
| llama-cpp-python | T2 | 0.3.36 | 全平台 | Python 绑定 | wheel（需匹配 llama.cpp 版本） |
| MLX / mlx-lm | T2 | 0.32.4 | Apple Silicon | Mac 上最快的一档 | pip wheel + 4bit 量化脚本 |
| **oMLX** | **T2** | HEAD @ `624cff0` | Apple Silicon | Mac 上的"服务化"档：continuous batching + 分层 KV cache + SSD 缓存，带 VLM 支持 | 源码（需完整 Xcode + Metal toolchain）或官方 DMG |
| vLLM | T2 | 0.33.0 | NVIDIA / AMD | 高吞吐服务化、PagedAttention | 容器镜像（`docker save`）+ CUDA 驱动 |
| SGLang | T2 | 0.5.23 | NVIDIA | 长上下文/高并发、RadixAttention | 同上 |
| Transformers | T2 | 5.23.0 | 全平台 | 参考实现、微调、评测 | wheel + 对应 tokenizers |
| PEFT | T2 | 0.21.3 | 全平台 | LoRA/QLoRA | wheel |
| Ollama | T3 | 0.40.16 | 全平台 | 一键跑、模型库 | 二进制 + 你拉过的 Modelfile |
| koboldcpp | T3 | 最新 | 全平台 | 单文件、零安装 | 单个可执行文件 |
| MLC-LLM | T3 | 最新 | 移动端/WebGPU | 手机、浏览器 | wheel + 编译好的模型库 |
| ONNX Runtime / Optimum | T3 | 最新 | 全平台 | 跨平台部署、端侧 | wheel + 导出脚本 |
| candle / mistral.rs | T3 | 最新 | Rust | 无 Python 依赖的部署 | cargo vendor 目录 |
| Open WebUI / text-generation-webui | T3 | 最新 | 全平台 | 前端 | 源码 + node 依赖 |
| LM Studio | T3 | 最新 | 全平台 | GUI + `lms` CLI（手工装） | 安装包 + 模型目录 |
| TensorRT-LLM | T4 | 1.2.1 | NVIDIA | 极致性能（可选） | 容器镜像；与驱动强绑定 |

> **引擎的档位规则**：T0 的引擎只留 llama.cpp（一块 U 盘就能点火）；T2 补齐"能把你已经下载的那几个大模型跑起来"的一套——Strata 与 DwarfStar4 专门吃 Qwen3.8-Flash-Next / GLM-5.3-Flash / DeepSeek V4 这几个，配合二手大内存机器、Mac Studio、单张 24–48GB 卡最划算；T3 加前端、评测与边缘运行时；T4 只剩 TensorRT-LLM 这种与驱动强绑定的东西。

### 5.1 Agent harness：模型与"会干活"之间的那一层

引擎解决"能不能跑"，harness 解决"能不能替你干活"——它管工具调用、上下文、文件系统、多轮循环。这一层比引擎更容易碎：依赖 npm 生态、发版极快、常常只有源码。

| harness | 档 | 版本 | 平台 | 用途 | 独立安装包 |
|---|---|---|---|---|---|
| **pi** （earendil-works） | T1 | v1.5.2 @ `97d539c` | macOS / Linux / Windows | 统一 LLM API + agent loop + TUI + 编码 agent；抽象最干净，适合当"底座" | ✅ 官方 prebuilt 8 平台（48–62MB）；另有 npm 包 `@earendil-works/pi-coding-agent`，需 Node ≥ 22.19 |
| **omp**（oh-my-pi） | T1 | v18.20.0 @ `e941476` | 同上 | 把 IDE 直接接进 agent 的编码工具 | ✅ 单文件二进制 8 平台（223–287MB）+ `brew install can1357/tap/omp` |
| **DeepSeek Harness（dsh）** | T1 | @ `39163dd` | 全平台（Node） | "万物皆插件"：工具、模型、界面都是插件，生态最大 | ❌ 无独立包：`pnpm install`（或整目录复制 `node_modules`） |
| **Hermes Agent** | T1 | v0.23.1 @ `b70a53e` | 全平台 | NousResearch 的长期/可成长 agent | ❌ 无 release 资产：只有 `install.sh`（联网拉）或源码 + pnpm |

### 5.2 独立安装包：别只留源码

只备源码是半个备份：`pnpm install` 要 registry，`pip install` 要 PyPI，三年后这两个都可能在、也可能不在。所以凡是有官方预编译/安装包的，都单独存一份——`installers.csv` + [`fetch-installers.sh`](fetch-installers.sh) 负责这件事。

| 包 | 平台 | 体积 | 备注 |
|---|---|---|---|
| pi | darwin-arm64 / linux-x64 / win-x64 | ~169MB | 官方 tar/zip，内含运行时 |
| omp | darwin-arm64 / linux-x64 / win-x64 | ~762MB | 单文件，自包含 |
| Strata | macOS dmg / Windows setup / Linux AppImage + Metal 后端 | ~592MB | CUDA/ROCm 后端 200–950MB，按你的卡另取 |
| oMLX | macOS universal2 wheel（py312/py313） | ~82MB | 也可用 940MB 的 DMG（含 GUI） |
| llama.cpp | 四平台二进制 | ~117MB | 归 `fetch-engines.sh` 管，见 §5 |
| **dsh / hermes-agent** | — | — | **没有独立包**：只能从一台装好的机器上整目录复制 `node_modules`，并一起存 `pnpm-lock.yaml` |

**三套"冷启动组合"**：

- **无 Python 组合**（推荐给所有人）：llama.cpp 源码 + CMake + 一个 GGUF。树莓派都能编译。
- **服务化组合**：vLLM 或 SGLang 的容器镜像 + 驱动 + 模型。适合有卡的人。
- **Apple 组合**：MLX + mlx-lm + 4bit 模型。MacBook 就能跑 27B Q4。

工具脚本：[fetch-engines.sh](fetch-engines.sh) 取 llama.cpp 的源码与三平台预编译；[fetch-repos.sh](fetch-repos.sh) 按 `repos.csv` 的 `tier` 列浅克隆上表 20 个仓库里的可克隆项（`TIER=2` 取 11 个约 1.5GB，`TIER=3` 取 19 个，`ONLY=all` 全取）。

---

## 6. 依赖与工具链：让三年后的你能重新编译

| 类别 | 档 | 备什么 | 命令/备注 |
|---|---|---|---|
| 编译链 | **T0** | gcc/clang、cmake、ninja、make | 至少留一套能编译 llama.cpp 的——T0 的"从源码点火"靠它 |
| 完整性 | **T0** | aria2、par2cmdline、zstd、7z、sha256 | macOS 用 `shasum -a 256` |
| Python 轮子 | **T1** | 全量离线 wheels（含传递依赖） | `pip download -r requirements.txt -d wheels --only-binary=:all:` |
| GPU 驱动 | **T1** | 当前在用的驱动安装包 **+ 上一版** | NVIDIA `.run`、AMD ROCm、Apple Xcode CLT |
| 平台限定轮子 | T2 | 给目标机器下（linux x86_64 / macOS arm64） | `--platform manylinux2014_x86_64 --python-version 3.12` |
| 环境快照 | T2 | `uv` 锁文件 / `conda-pack` 打包整环境 | `conda pack -n llm -o llm-env.tar.gz` |
| CUDA/ROCm | T2 | 与驱动匹配的 toolkit | 版本写进 `DRIVERS.txt` |
| 容器 | T2 | `docker save` 的 vLLM/SGLang 镜像 | `docker save img > img.tar && zstd img.tar`（10–20GB/个） |
| 备份软件 | T2 | restic 或 borg（增量+加密） | 适合每月增量，不适合冷备 |
| Rust/Node | T3 | rustup 离线 toolchain、node + pnpm | 给 candle / Open WebUI 用 |
| 同步 | T4 | rclone（对接任意对象存储/异地盘） | 异地副本用 |

### 6.1 训练/微调栈（"扩展"，不只是"使用"）

只备份推理栈，你得到的是"能用的 AI"；再备份训练栈，你得到的是"能改的 AI"。后者才是"扩展能力"。

| 工具 | 档 | 用途 | 备注 |
|---|---|---|---|
| unsloth 0.1.917 | T2 | 单卡 LoRA/QLoRA，显存省、速度快 | 与 llama.cpp/GGUF 生态衔接好 |
| PEFT 0.21.3 | T2 | 官方参数高效微调 | LoRA/IA3/Prompt Tuning |
| Axolotl / LLaMA-Factory | T3 | 配置式微调流水线 | 适合批量实验 |
| TRL | T3 | DPO / GRPO / PPO | 对齐与推理能力强化 |
| DeepSpeed / FSDP | T4 | 分片、卸载、混合精度 | 单机多卡起步 |
| FlashAttention / Triton | T4 | kernel 层 | 与 CUDA/ROCm 版本强绑定 |
| torchtitan / Megatron-LM / OLMo-core | T4 | 预训练参考实现 | OLMo 的配方最完整、最可复现 |
| verl / OpenRLHF | T5 | 分布式 RL | 多机多卡时用 |
| NCCL / Ray | T5 | 通信与调度 | 多机才需要 |

> 版本策略：**引擎钉死版本**（它决定权重能不能加载），**训练栈钉死锁文件**（它决定你能不能复现一次微调）。两者都不要用 `latest`。

**空气隙演练（每季度一次，2 小时）**：
1. 拔网线，只留一台机器和一个硬盘；
2. 从源码编译 llama.cpp（或解压预编译二进制）；
3. 加载一个 GGUF，问 10 个问题，记录 tok/s；
4. 用 `verify.sh` 校验全部 SHA256；
5. 从零建一个 venv，离线安装 vLLM 或 transformers；
6. 跑一次 LoRA 微调（哪怕 100 步）；
7. 把这次演练的日期、耗时、失败点写进 `DRILL_LOG.md`。

---

## 7. 技术报告与知识：没有论文的权重是黑箱

> 本节 42 篇文献由 [fetch-docs.sh](fetch-docs.sh) 抓取（清单在 `docs.csv`），落到 `docs/arxiv/` 与 `docs/other/`，并生成 `index.md`。arXiv 论文没有 commit sha，**抓取日期就是证据链**——`PROVENANCE.txt` 里记着。

优先级：**能复现的配方 > 架构论文 > 评测方法 > 综述**。全部 PDF 约 1–2GB，是所有层级里性价比最高的部分。

### 7.1 架构与训练基础

| 主题 | 文献 | 链接 |
|---|---|---|
| Transformer | Attention Is All You Need (2017) | [1706.03762](https://arxiv.org/abs/1706.03762) |
| 规模化语言模型 | Language Models are Few-Shot Learners (GPT-3) | [2005.14165](https://arxiv.org/abs/2005.14165) |
| 缩放定律 | Scaling Laws for Neural Language Models | [2001.08361](https://arxiv.org/abs/2001.08361) |
| 计算最优训练 | Training Compute-Optimal LLMs (Chinchilla) | [2203.15556](https://arxiv.org/abs/2203.15556) |
| MoE 路由 | Switch Transformers | [2101.03961](https://arxiv.org/abs/2101.03961) |
| 细粒度 MoE | DeepSeekMoE | [2401.06066](https://arxiv.org/abs/2401.06066) |
| 状态空间模型 | Mamba | [2312.00752](https://arxiv.org/abs/2312.00752) |
| 位置编码 | RoPE | [2104.09864](https://arxiv.org/abs/2104.09864) |
| 注意力变体 | GQA | [2305.13245](https://arxiv.org/abs/2305.13245) |
| 长上下文外推 | YaRN | [2309.00071](https://arxiv.org/abs/2309.00071) |
| 归一化/激活 | RMSNorm [1910.07467](https://arxiv.org/abs/1910.07467) · GLU Variants [2002.05202](https://arxiv.org/abs/2002.05202) | — |

### 7.2 各代开放模型的技术报告（复现的地图）

| 模型 | 报告 | 链接 |
|---|---|---|
| Llama 3 | The Llama 3 Herd of Models | [2407.21783](https://arxiv.org/abs/2407.21783) |
| Mistral 7B / Mixtral | — | [2310.06825](https://arxiv.org/abs/2310.06825) / [2401.04088](https://arxiv.org/abs/2401.04088) |
| DeepSeek-V2 | MLA + DeepSeekMoE | [2405.04434](https://arxiv.org/abs/2405.04434) |
| DeepSeek-V3 | 671B/37B，FP8 训练 | [2412.19437](https://arxiv.org/abs/2412.19437) |
| DeepSeek-R1 | 纯 RL 推理 | [2501.12948](https://arxiv.org/abs/2501.12948) |
| DeepSeek-V4 | 百万上下文、CSA/HCA、mHC | [2606.19348](https://arxiv.org/abs/2606.19348) |
| Qwen3 | 稠密+MoE 统一家族 | [2505.09388](https://arxiv.org/abs/2505.09388) |
| Qwen3-Embedding | 多语言向量 | [2506.05176](https://arxiv.org/abs/2506.05176) |
| Gemma 4 | 任意模态 | [2607.02770](https://arxiv.org/abs/2607.02770) |
| GLM-5 | DSA 稀疏注意力 | [2602.15763](https://arxiv.org/abs/2602.15763) |
| gpt-oss | OpenAI 开放权重 | [2508.10925](https://arxiv.org/abs/2508.10925) |
| OLMo 3 | 完全开放的配方 | [2512.13961](https://arxiv.org/abs/2512.13961) |
| Nemotron 3 | 混合 Mamba | [2512.20848](https://arxiv.org/abs/2512.20848) |
| Kimi K3 | 2.8T、KDA、AttnRes | [GitHub PDF](https://github.com/MoonshotAI/Kimi-K3/blob/main/k3_tech_report.pdf) |
| DeepSeek-OCR | 视觉压缩文本 | [2510.18234](https://arxiv.org/abs/2510.18234) |

### 7.3 对齐与可解释性

| 主题 | 文献 | 链接 |
|---|---|---|
| RLHF | InstructGPT | [2203.02155](https://arxiv.org/abs/2203.02155) |
| 偏好优化 | DPO | [2305.18290](https://arxiv.org/abs/2305.18290) |
| 可验证奖励 | DeepSeekMath / GRPO | [2402.03300](https://arxiv.org/abs/2402.03300) |
| 宪法式 AI | Constitutional AI | [2212.08073](https://arxiv.org/abs/2212.08073) |
| 拒绝的机制 | Refusal Is a Single Direction | [2406.11717](https://arxiv.org/abs/2406.11717) |

### 7.4 推理、量化与工程

| 主题 | 文献 | 链接 |
|---|---|---|
| PagedAttention / vLLM | 服务化基石 | [2309.06180](https://arxiv.org/abs/2309.06180) |
| FlashAttention / v2 | IO 感知注意力 | [2205.14135](https://arxiv.org/abs/2205.14135) / [2307.08691](https://arxiv.org/abs/2307.08691) |
| LoRA / QLoRA | 低成本微调 | [2106.09685](https://arxiv.org/abs/2106.09685) / [2305.14314](https://arxiv.org/abs/2305.14314) |
| GPTQ / AWQ | 训练后量化 | [2210.17323](https://arxiv.org/abs/2210.17323) / [2306.00978](https://arxiv.org/abs/2306.00978) |
| 投机解码 | Speculative Decoding | [2211.17192](https://arxiv.org/abs/2211.17192) |

### 7.5 还要手工收的

- **Karpathy 的 `nanoGPT` 与 `llm.c`**：从零训练小模型的最短路径，比任何论文都更能教会"AI 是怎么来的"。
- **《动手学深度学习》(d2l.ai)**：离线 HTML/PDF，覆盖到 Transformer。
- **各引擎的文档快照**：llama.cpp 的 `docs/`、vLLM 的 `docs/`、SGLang 的文档站，用 `wget --mirror` 各存一份。
- **模型卡与许可原文**：每个模型目录里都放一份 `LICENSE` 和 `README`，它们日后是"我当年是按什么条款拿到的"的唯一证据。
- **评测脚本**：`lm-evaluation-harness`、`lighteval`、你自己的 20 题小评测（最重要，因为它能在断网时跑）。

---

## 8. 给有算力的人

### 8.1 按硬件选层

| 你的硬件 | 建议层 | 能跑的（实测尺寸） | 关键动作 |
|---|---|---|---|
| 无独显，32GB 内存 | T0 | 4B Q4（2.7GB）约 5–8 tok/s；0.8B 可实时 | 先跑通 llama.cpp；把 T0 做成"断网也能启动"的 U 盘 |
| 1×24GB（4090/5090） | T1–T2 | 27B Q4（16.6GB）、35B-A3B Q4（22.1GB）、9B bf16（19.3GB） | 27B Q4 + 35B-A3B Q4 二选一常驻；另一份放硬盘 |
| 1×48–80GB（A6000/H100） | T2–T3 | 27B bf16（55.6GB）+ LoRA；35B-A3B 需 64GB 以上内存 | 留一份 BF16 母本用于微调；量化流水线本地化 |
| 2×80GB | T3 | 27B 原版（55.6GB）+ 35B-A3B 原版（71.9GB）TP=2 | 跑通 vLLM/SGLang 的 TP；记录可用的最大上下文 |
| 8×80GB（640GB） | T3–T4 | GLM-5.3-Flash EXL3 4bpw（176）、Qwen3.8-Flash-Next 原版（360） | 服务化 + 评测 + 至少一个可复现的微调配方 |
| 8×141GB（H200，1.1TB） | T4–T5 | GLM-5.3-Flash 原版（328）、V4.1-Flash（510）、V3.2 bf16（690） | 多租户隔离；把"模型即服务"做成内网 API |
| 8×180GB（B200，1.4TB） | T4–T5 | V3.2 bf16（690）、V4.1-Flash bf16（510） | 记录 FP8/FP4 的精度损失；建立自己的 eval 基线 |
| 16–64×GB200 | T5 | V4-Pro（865）、Kimi-K3（1561） | 这不是个人能维护的规模；重点是**别让这批权重只存在一个机房** |

### 8.2 有算力的人最该做的五件事

1. **做"可离线重启"的服务**：模型、引擎、驱动、容器、启动脚本放在同一块盘上，拔网线能起。
2. **留 BF16 母本**：量化版会随引擎演化，BF16 是十年后还能重新量化的底片。
3. **建自己的小评测**：50–200 道题，覆盖你的语言、领域、拒答边界；每次换模型/量化都跑。
4. **做异地副本**：同一组权重至少两个物理位置；磁带（LTO-9，18TB/卷）适合冷备，SSD 适合热备。
5. **把"怎么跑"写下来**：命令、坑、显存占用、tok/s。三年后你自己就是那个"没有文档的古人"。

### 8.3 成本量级（2026-11 估算，波动很大，仅用于做预算）

| 项目 | 量级 | 说明 |
|---|---|---|
| 8×H100 节点 | $250k–$400k | 整机含网络；二手/租赁另算 |
| 8×H200 节点 | $350k–$500k | 141GB HBM 适合长上下文 |
| 20TB 企业级 HDD | $300–$500 / 块 | 冷备主力；买两块做镜像 |
| 4TB NVMe | $250–$400 | 热数据 + 模型工作区 |
| LTO-9 磁带机 | $4k–$6k | 只对机构有意义 |
| LTO-9 磁带（18TB） | $80–$120 / 卷 | 离线归档最便宜的单位成本 |
| 电费 | 8 卡节点 6–10 kW | 一年电费可能超过一块 20TB 盘 |

---

## 9. 给没有算力的人

没有 GPU 不等于没有位置。**本地 AI 的门槛已经不是算力，是"有没有人把东西整理好、校验好、教给别人"。**

### 9.1 按介质选层

| 介质 | 装什么 | 能做什么 |
|---|---|---|
| **8GB U 盘** | T0（6.8GB）+ 一份 `llama.cpp` 二进制 + 论文 PDF | 任何一台电脑离线：写作、翻译、总结、转写、朗读、检索 |
| **32GB U 盘** | T0 + 英文维基 mini（ZIM）+ 你的领域文档 | 上面的全部 + 一个离线知识库 |
| **128GB U 盘 / 旧手机卡** | T1（57.1GB）+ 维基 nopic | 27B Q4 跑在 32GB 内存的机器上；通勤路上用手机跑 2B |
| **512GB SSD** | T2（455.5GB） | 一台 64GB 内存的机器就是一个小型 AI 工作站 |
| **1TB SSD** | T3（826.0GB） | 一个人可以服务一个社区：模型、语料、评测、教学全套 |

### 9.2 手机上能跑什么

- **0.6B–2B**：Qwen3.5-0.8B / 2B GGUF，llama.cpp、PocketPal、MLX 均可；2B 在手机上约 5–15 tok/s。
- **4B**：新款旗舰手机（12GB+ 内存）可跑 Q4，约 3–8 tok/s；适合离线写作/翻译。
- **不要期待手机跑 27B**：不是不能，是散热和内存带宽会让它变成"能跑但不想用"。

### 9.3 知识型备份（比权重更便宜、更耐久）

| 资产 | 体积 | 为什么 |
|---|---|---|
| Wikipedia ZIM（mini / nopic） | 1–2GB / 50–60GB | 人类最大的公共知识库；Kiwix 离线可读 |
| 核心论文 PDF（第 7 节） | 1–2GB | 复现的地图 |
| d2l.ai + Karpathy 课程 | <1GB | 从零学"AI 怎么来的" |
| 你所在领域的教科书/标准/手册 | 10–100GB | 模型不知道的默会知识 |
| 开源代码镜像（llama.cpp、vLLM、transformers） | 5–20GB | 没有代码，权重是标本 |
| 模型卡与许可原文 | <100MB | 日后证明"我是按什么条款拿到的" |

### 9.4 不需要算力的六种贡献

1. **做种/镜像**：把 T0/T1 做成 BitTorrent，长期保种；带宽就是算力。
2. **校验**：帮别人跑 `verify.sh`，报告坏块。校验是社区最稀缺的劳动。
3. **翻译**：把模型卡、论文、教程翻译成你的语言；这是"能力扩散"的实际瓶颈。
4. **教学**：在图书馆/学校开一次"断网跑 AI"的工作坊，比多一张显卡有用。
5. **整理**：把"哪个模型在什么硬件上多少 tok/s"记成表；这是社区最缺的基础设施。
6. **组织**：一个 8TB NAS + 3 个志愿者 + 每月一次校验，就是一个"种子图书馆"。

### 9.5 "种子图书馆"最小运作方案

- **硬件**：1 台 8TB NAS（或旧主机 + 2×8TB 镜像盘）+ 1 个 128GB U 盘做"借阅盘"。
- **内容**：T1 全量 + T2 的 27B/35B + 论文 + 维基 ZIM + 本社区语料。
- **规则**：只存可再分发许可的权重；gated 模型不复制、不外借；每个目录带 `PROVENANCE.txt` 与 `SHA256SUMS.txt`。
- **节奏**：每月第一个周末校验；每季度更新一次清单；每年做一次"断网演练"。
- **扩张**：三个图书馆之间用移动硬盘「sneaker-net」同步，不依赖云。

---

## 10. 30 天执行计划

### 10.1 四周计划

| 周 | 做什么 | 产出 |
|---|---|---|
| **第 1 周** | 跑通 llama.cpp；下 T0；在断网状态启动一次 | 一个能用的 8GB U 盘 + `DRILL_LOG.md` 第一条 |
| **第 2 周** | 下 T1；建 `SHA256SUMS`；写下"怎么跑"的一页纸 | 64GB 介质 + 一页 SOP |
| **第 3 周** | 按你的硬件下 T2 或 T3；收第 7 节论文；镜像引擎文档 | 主力模型 + 离线文档库 |
| **第 4 周** | 做第二份副本（异地/不同介质）；演练恢复；把清单发给 3 个人 | 3-2-1 达成 + 社区起点 |

> 带宽估算：100Mbps 家庭宽带下，T1（57GB）约 1.3 小时，T2（456GB）约 10 小时，T3（826GB）约 18 小时，T5（9.2TB）约 8.5 天。**先下 T0/T1，再下大的**——顺序错了，事故先来时你手里只有半成品。

---

## 11. 法律、许可与边界

### 11.1 许可差异（决定你能不能"传给下一个人"）

| 许可 | 代表 | 能否再分发 | 注意 |
|---|---|---|---|
| MIT | DeepSeek 全系、bge-m3 | ✅ 几乎无限制 | 保留版权声明 |
| Apache-2.0 | Qwen 全系、Gemma 4、OLMo、多数工具 | ✅ 需保留 NOTICE/变更说明 | 专利授权条款对用户有利 |
| Llama 3.x 社区许可 | Llama-3.3 | ⚠️ 有条件 | 7 亿 MAU 条款、命名要求、可撤销性 |
| Gemma 使用条款 | Gemma 4 及更早版本 | ⚠️ 看版本 | Gemma 4 在 HF 上标 `apache-2.0`，但模型卡同时链接 [Gemma 4 使用条款](https://ai.google.dev/gemma/docs/gemma_4_license)；商用前两份都读 |
| Kimi K3 / GLM License | 对应旗舰 | ⚠️ 自定义 | 商用前逐条读；常有署名/限制条款 |
| FLUX Non-Commercial | FLUX.1-dev | ❌ 商用 | 只能非商用；再分发受限 |
| AGPL-3.0 | Heretic | ✅（传染性） | 改了就开源 |

**gated 模型（如 Llama 系列）**：你能下载，不等于能替别人下载、更不等于能公开分发。清单里对这类模型只写"自用副本"，不写"传给别人"。

### 11.2 出口管制与跨境

模型权重是否受出口管制、跨境传输是否需许可，在 2026 年仍是灰色地带，且各国规则在变。**这份清单不构成法律意见。** 保守做法：
- 不替他人下载 gated 模型；
- 跨境携带前查最新规则；
- 机构用户走法务，不要用"技术上能传"代替"法律上能传"。

### 11.3 安全：模型文件是可执行代码

- **只用 `safetensors` 和 `GGUF`**。`.bin`/`.pt`/`.pth` 可能含 pickle，加载即执行。
- **默认关闭 `trust_remote_code`**；要开就先读代码。
- **在沙箱/容器里跑陌生模型**；断网加载。
- **别把模型权重和密钥放同一个盘**。
- **校验哈希**：`verify.sh` 不是形式主义，它是唯一能发现"文件被替换"的手段。

### 11.4 伦理：火种不等于纵火

- 保留护栏模型（4.9），并在服务里默认启用。
- abliterated 权重用于研究、创作、绕过过度拒答；不用于伤害、欺诈、未成年人相关的内容。
- 如果你要把它交给别人，连同"它会说什么、不会说什么、能力损失多少"一起交。
- 本地 AI 的正当性来自"可问责"：谁部署、谁负责。这恰恰是它比黑箱 API 更值得保留的地方。

---

## 12. 附录

### A. 快速命令

```bash
# 1) 只下火种层（先看计划）
TIER=0 DEST=/Volumes/SEED DRY=1 ./download.sh
TIER=0 DEST=/Volumes/SEED ./download.sh

# 2) 钉死 revision 下单个模型（不要用 main）
hf download Qwen/Qwen3.8-27B \
  --revision 37561816e66b5b9153b1b64c10968c18c1e6f4a0 \
  --local-dir ./models/qwen3.8-27b \
  --exclude "original/*" --exclude "metal/*"

# 3) 只取一个量化文件（GGUF 仓库常有几十个量化）
hf download unsloth/Qwen3.8-27B-GGUF \
  --include "Qwen3.8-27B-UD-Q4_K_M.gguf" \
  --local-dir ./models/qwen3.8-27b-q4

# 4) 补齐非 HF 资产（论文 / 引擎源码）
./fetch-docs.sh   /Volumes/SEED/docs
./fetch-repos.sh  /Volumes/SEED/repos

# 5) 校验
./verify.sh /Volumes/SEED

# 6) 分卷 + 压缩（跨文件系统搬运）
zstd -T0 -19 model.gguf -o model.gguf.zst
split -b 20G model.gguf.zst model.gguf.zst.part-
# 还原：cat model.gguf.zst.part-* | zstd -d > model.gguf

# 7) 5% 冗余校验卷（只对关键文件开，很慢）
par2 create -r5 model.gguf.par2 model.gguf

# 8) 异地增量
rclone copy /Volumes/SEED remote:ark --progress --checksum
```

### B. 每个模型目录应该有什么

```
models/qwen3.8-27b/
├── PROVENANCE.txt      # repo_id / revision / 下载时间 / include
├── SHA256SUMS.txt      # 全部文件的哈希
├── LICENSE             # 许可原文（从仓库复制）
├── README.md           # 模型卡
├── config.json
├── tokenizer.json / tokenizer_config.json
├── chat_template.jinja
├── generation_config.json
└── *.safetensors
```

缺 `tokenizer` 或 `chat_template` 的"备份"，在恢复时等于一堆无法对话的矩阵。

### C. 恢复演练 checklist

- [ ] 断网，只用备份介质
- [ ] 从源码编译 llama.cpp（或解压预编译）
- [ ] 加载 4B 模型，问 10 个问题，记录 tok/s
- [ ] 加载 27B Q4，问 10 个问题，记录显存/内存占用
- [ ] `verify.sh` 全部通过
- [ ] 离线建 venv，装 transformers/vLLM
- [ ] 跑一次 LoRA 微调（100 步即可）
- [ ] 用本地模型 + bge-m3 建一个 100 文档的 RAG
- [ ] 把失败点写进 `DRILL_LOG.md`，下次先修它

### D. manifest.csv 字段

| 字段 | 含义 |
|---|---|
| `tier` | 首次出现的层级（0–5）；高层级包含低层级 |
| `tier_name` | 层级名与目标介质 |
| `priority` | S/A/B/C |
| `category` | engine / tool / text-small / text-mid / text-frontier / vision / audio / ocr / embed / rerank / guard / abliterated / image / video / corpus / docs |
| `artifact` | 人读的名称与格式 |
| `repo_id` | HF 仓库；`-` 表示非 HF 资产 |
| `revision` | commit sha 或 tag；`main` 表示未钉死（不推荐） |
| `size_gb` | 实测体积（十进制 GB） |
| `license` | 仓库标签，商用前读原文 |
| `note` | 取舍理由 |
| `include` | 只下这个文件（GGUF 仓库必填） |

### E. 这份清单不能做什么

1. **不能替代算力**。1.6T 权重在手，没有卡也只是一堆矩阵；能跑 27B Q4 的机器才是"火种"的载体。
2. **不能替代数据**。预训练语料在 T6，个人拿不到全量；这份清单保的是"推理与微调"的能力，不是"从零预训练前沿模型"的能力。
3. **不能替代人**。真正的传承是"有人会跑、会改、会教"；权重只是教材。
4. **会过期**。模型半年一代、引擎一年一换、许可随时可改。**下一次复核：2027-02-13。**

### F. 变更日志

| 日期 | 变更 |
|---|---|
| 2026-11-13 | v1 |
