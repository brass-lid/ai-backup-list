#!/usr/bin/env python3
"""从 manifest.csv 生成正文 §3.1 的阶梯表与 §3.2 的档位明细，保证清单与正文不漂移。

用法:
    ./ladder.py                 # 打印 §3.1 的阶梯表（贴进正文）
    ./ladder.py --detail        # 打印 §3.2 的逐档明细
    ./ladder.py --check 正文.md  # 对比正文，数字/条数不一致就退出码 1
"""
import csv, re, sys
from collections import OrderedDict

MANIFEST = "manifest.csv"
# 每层介质容量（十进制 GB，按厂商标称；实际可用约 0.93×，见正文余量提醒）
MEDIA = {0: 8, 1: 64, 2: 512, 3: 1000, 4: 4000, 5: 20000}
MEDIA_LABEL = {0: "8GB U 盘 / 手机", 1: "64GB U 盘 / 旧 SSD", 2: "512GB SSD",
               3: "1TB SSD", 4: "4TB HDD/SSD", 5: "20TB"}
WHO = {
    0: "任何人",
    1: "有一台 16–32GB 内存的电脑",
    2: "一台 64GB 内存 / 24GB 显存的机器",
    3: "单机 128GB 内存 / 1–2 张 80GB 卡",
    4: "8×80GB 或 1TB+ 内存的机器",
    5: "小型机房 / 实验室 / 图书馆",
}
WHAT = {
    0: "一台笔记本离线跑 4B 级模型 + 检索 + 转写 + 朗读 + 全部核心论文",
    1: "27B 级模型（Q4）+ 35B-A3B（Q4）+ 9B 视觉语言 + 多语言检索 + 4 个 agent harness",
    2: "两个大 MoE 的 4-bit 版（Flash-Next / GLM-5.3-Flash）+ 9B 视觉 + OCR + 语音 + 重排 + 护栏 + 向量 + 语料",
    3: "加：V4-Flash、Gemma-31B Q8、abliterated 全家桶、护栏模型、学术 OCR、6 个 abliteration 工具",
    4: "**原版 / 预训练母本**：GLM-5.3 Q4、V4.1-Flash、GLM-5.3-Flash、27B/35B 原版、Qwen3.5 两个 base、Gemma-4-31B base、视频生成",
    5: "加：V4-Pro-Base、Kimi-K3、GLM-5.3、V3.2-Exp-Base、R1、Llama-3.3-70B——1.5TB 级与最重的原版",
}


def tiers():
    rows = list(csv.DictReader(open(MANIFEST, encoding="utf-8")))
    agg = OrderedDict((t, [0, 0.0]) for t in range(6))
    for r in rows:
        t = int(r["tier"])
        agg[t][0] += 1
        agg[t][1] += float(r["size_gb"])
    return rows, agg


def table():
    rows, agg = tiers()
    out = ["| 层 | 目标介质 | 条数 | 本层增量 | 累计 | 适合谁 | 能做到什么 |",
           "|---|---|---|---|---|---|---|"]
    cum = 0.0
    for t, (n, gb) in agg.items():
        cum += gb
        out.append(f"| **T{t} {['火种','入门','主力','严肃','前沿','方舟'][t]}** | {MEDIA_LABEL[t]} | "
                   f"{n} | {gb:.1f} GB | **{cum:.1f} GB** | {WHO[t]} | {WHAT[t]} |")
    total = sum(g for _, g in agg.values())
    out.append("")
    out.append(f"合计 **{len(rows)} 条 / {total:.1f} GB（{total/1000:.2f} TB）**。"
               f"各层累计 ÷ 介质标称：" + "、".join(
                   f"T{t} {sum(v[1] for k,v in agg.items() if k<=t)/MEDIA[t]*100:.0f}%"
                   for t in range(6)))
    return "\n".join(out), agg, total


def detail():
    rows, agg = tiers()
    out = []
    for t in sorted(agg):
        n, gb = agg[t]
        items = [r for r in rows if int(r["tier"]) == t]
        items.sort(key=lambda r: -float(r["size_gb"]))
        out.append(f"**T{t} {['火种','入门','主力','严肃','前沿','方舟'][t]}** · {MEDIA_LABEL[t]} · "
                   f"{n} 件 · {gb:.1f} GB")
        out.append("")
        out.append("| 资产 | 类别 | 体积 | 级 |")
        out.append("|---|---|---|---|")
        for r in items:
            v = float(r["size_gb"])
            size = f"{v:.4f}" if v < 0.01 else f"{v:.2f}"
            mark = " †" if r["repo_id"] == "-" else ""
            out.append(f"| {r['artifact']}{mark} | {r['category']} | {size} | {r['priority']} |")
        out.append("")
    return "\n".join(out)


def check(path):
    _, agg, total = table()
    body = open(path, encoding="utf-8").read()
    bad = []
    for t in range(6):
        want = f"{sum(v[1] for k, v in agg.items() if k <= t):.1f}"
        # 正文表格里每行出现一次累计值，加粗形式
        if f"**{want} GB**" not in body:
            bad.append(f"T{t} 累计应为 {want} GB，正文未出现")
    if f"{total:.1f} GB" not in body:
        bad.append(f"合计应为 {total:.1f} GB，正文未出现")
    for t, (n, gb) in agg.items():
        want = f"{n} 件 · {gb:.1f} GB"
        if want not in body:
            bad.append(f"T{t} 明细行应为「{want}」，正文未出现")
    for b in bad:
        print("✗", b)
    print("✓ 正文与 manifest.csv 一致" if not bad else f"共 {len(bad)} 处不一致")
    return 0 if not bad else 1


if __name__ == "__main__":
    if len(sys.argv) > 2 and sys.argv[1] == "--check":
        sys.exit(check(sys.argv[2]))
    if "--detail" in sys.argv:
        print(detail())
    else:
        print(table()[0])
