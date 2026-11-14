#!/usr/bin/env python3
"""联网核对 manifest.csv：仓库是否存在、revision 是否还是那个 commit、
include 的文件是否还在、体积有没有变。

用法:
    ./check-manifest.py            # 全量核对
    ./check-manifest.py --tier 0   # 只核对某一层
退出码 1 = 有需要修改清单的问题。
"""
import csv, json, sys, time, urllib.request, urllib.error, fnmatch, subprocess

EXCLUDES = ["original/*", "metal/*", "onnx/*", "*.ckpt"]
TOLERANCE = 0.05  # 体积偏差容忍 5%


def api(repo):
    url = f"https://huggingface.co/api/models/{repo}?blobs=true"
    with urllib.request.urlopen(url, timeout=30) as r:
        return json.load(r)


def main(argv):
    tier = None
    if "--tier" in argv:
        tier = int(argv[argv.index("--tier") + 1])
    rows = [r for r in csv.DictReader(open("manifest.csv", encoding="utf-8"))
            if tier is None or int(r["tier"]) == tier]
    bad = ok = skipped = 0
    for r in rows:
        repo, rev, inc = r["repo_id"], r["revision"], r["include"]
        if repo == "-" or "/" not in repo:
            skipped += 1
            print(f"—  {r['artifact'][:44]:46s} 非 HF 资产，跳过")
            continue
        if repo.startswith("github.com/"):
            # GitHub 条目：确认 pinned commit 还在
            try:
                with urllib.request.urlopen(
                        f"https://api.github.com/repos/{repo[11:]}/commits/{rev}", timeout=20) as resp:
                    sha_ok = json.load(resp).get("sha") == rev
                err = ""
            except urllib.error.HTTPError as e:
                if e.code == 403:   # API 限流：退回 git ls-remote
                    try:
                        out = subprocess.run(["git", "ls-remote", f"https://{repo}.git"],
                                             capture_output=True, text=True, timeout=90).stdout
                        refs = {ln.split()[0] for ln in out.splitlines() if ln.strip()}
                        sha_ok = rev in refs
                        err = "" if sha_ok else "（API 限流；ls-remote 未见该 commit，可能已不在 ref 上）"
                    except Exception as ex:
                        sha_ok, err = False, f"ls-remote 失败 {ex}"
                else:
                    sha_ok, err = False, f"HTTP {e.code}"
            except Exception as e:
                sha_ok, err = False, e.__class__.__name__
            if sha_ok:
                ok += 1
                print(f"✓  {repo:52s} {float(r['size_gb']):9.4f} GB  commit 存在")
            else:
                bad += 1
                print(f"✗  {repo:52s} commit {rev[:7]} 找不到 {err}")
            time.sleep(0.15)
            continue

        try:
            d = api(repo)
        except urllib.error.HTTPError as e:
            bad += 1
            print(f"✗  {repo:52s} HTTP {e.code}" + ("（gated，需 token）" if e.code in (401, 403) else ""))
            continue
        except Exception as e:
            bad += 1
            print(f"✗  {repo:52s} {e.__class__.__name__}"); continue
        problems = []
        if d.get("sha") != rev:
            problems.append(f"sha {rev[:7]}→{str(d.get('sha'))[:7]}")
        files = [(s["rfilename"], s.get("size") or 0) for s in (d.get("siblings") or [])]
        if inc:
            hit = [s for f, s in files if fnmatch.fnmatch(f, inc)]
            if not hit:
                problems.append(f"include 不存在: {inc}")
            got = sum(hit) / 1e9
        else:
            got = sum(s for f, s in files
                      if not any(fnmatch.fnmatch(f, p) for p in EXCLUDES)) / 1e9
        want = float(r["size_gb"])
        if want and abs(got - want) / want > TOLERANCE:
            problems.append(f"体积 {want}→{got:.2f}")
        if problems:
            bad += 1
            print(f"✗  {repo:52s} " + "；".join(problems))
        else:
            ok += 1
            print(f"✓  {repo:52s} {got:9.2f} GB")
        time.sleep(0.12)
    print(f"\n通过 {ok} / 需修 {bad} / 跳过 {skipped}")
    return 0 if bad == 0 else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
