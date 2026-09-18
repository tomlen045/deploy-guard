# 🚦 deploy-guard

> **Should I deploy? Let me check.** Pre-deployment safety checker with attitude.

English | [简体中文](#中文)

```bash
curl -fsSL https://raw.githubusercontent.com/tomlen045/deploy-guard/main/deploy-guard.sh | bash
```

**One command. 8 safety checks. GO / NO-GO verdict in 3 seconds.**

## Why

Every developer has deployed on Friday afternoon. Or shipped without running tests. Or pushed to prod with uncommitted changes. `deploy-guard` catches these mistakes **before** they become incidents.

## What it checks

| Check | What it catches |
|-------|----------------|
| 📅 Day of week | Friday afternoon, weekends, late night deploys |
| 📝 Git status | Uncommitted changes, unpushed commits, WIP messages |
| 🧪 Test config | Reminds you to run tests before shipping |
| 🔐 Secrets in git | .env files tracked by git? |
| 🏷 TODO/FIXME | Unfinished work in staged changes |
| 🌿 Branch check | Deploying directly to main? |
| 💾 Disk space | Will the deploy fail mid-way? |
| 🧠 Memory | OOM risk during deployment |

## Sample output

```
🚫 NO-GO — Fix these first:
    • It's Friday afternoon. You KNOW how this ends.
    • 3 uncommitted change(s) — commit or stash before deploying
    • .env is tracked by git! Remove it: git rm --cached .env

Also consider:
    • Found test script in package.json — did you run npm test?

Checks: 5 passed · 2 warnings · 3 critical
```

## Usage

```bash
bash deploy-guard.sh                  # standard mode
bash deploy-guard.sh --strict         # stricter (blocks direct deploys to main)
bash deploy-guard.sh --skip-weekend   # skip weekend check (for on-call)
echo $?                               # 0=GO, 1=NO-GO, 2=THINK TWICE
```

Use in CI/CD pipeline:
```yaml
- name: Deploy Guard
  run: bash deploy-guard.sh --strict
```

## 中文

**部署前安全检查工具。** 每个开发者都干过：周五下午部署、没跑测试就上线、修改了配置没写回滚方案。

`deploy-guard` 在你执行部署前自动检查 8 项安全条件：

- 📅 今天是周五下午吗？（经典送命题）
- 📝 有没有未提交的代码？
- 🧪 测试跑过了吗？
- 🔐 .env 文件有没有泄露到 git？
- 🏷 有没有未完成的 TODO？
- 🌿 是不是直接在 main 分支上操作？
- 💾 磁盘空间够吗？
- 🧠 内存够不够？

输出 **GO / THINK TWICE / NO-GO** 判定，支持 CI/CD 集成。

## License

MIT

---

<p align="center">🔍 搜「小薅薅」· 每天一个运维好工具</p>
---

<div align="center">

### 🫰 点击关注「小薅薅」

**年轻人的赛博工具箱** · 每天发现一个好玩的开源项目，为你节省 1 小时

📱 微信搜索公众号 **「小薅薅」** · 后台回复「工具」获取全部工具离线合集

![关注小薅薅](https://img.shields.io/badge/微信-搜「小薅薅」-green?style=for-the-badge&logo=wechat)

</div>

> 💡 如果你懒得一个个翻项目，直接关注微信公众号 **小薅薅**，后台对话聊天就行了：
> - 回复「**运维**」→ 推荐运维/安全相关的开源项目
> - 回复「**工具**」→ 获取全部工具离线合集
> - 回复「**加群**」→ 加入交流群，一起搞事情

---

### 🔗 更多作品 · 点下方卡片查看

| 项目 | 描述 | 链接 |
|:---|:---|:---|
| **🛡 ops-skills** | 10个AI运维技能包，让Claude Code变成SRE专家 | [GitHub](https://github.com/tomlen045/ops-skills) · [Gitee](https://gitee.com/tomlen/ops-skills) |
| **🩺 ops-doctor** | 一条命令给Linux服务器做全套体检+健康分 | [GitHub](https://github.com/tomlen045/ops-doctor) · [Gitee](https://gitee.com/tomlen/ops-doctor) |
| **🔮 shellmbti** | 你的终端历史暴露了你是谁——Shell MBTI人格测试 | [GitHub](https://github.com/tomlen045/shellmbti) · [Gitee](https://gitee.com/tomlen/shellmbti) |
| **🧋 naicha-mbti** | 8道题测出你的奶茶人格，生成分享卡片 | [GitHub](https://github.com/tomlen045/naicha-mbti) · [在线玩](https://tomlen045.github.io/naicha-mbti/) |
| **🔥 fafa-generator** | 发疯文学生成器——一键生成发疯文案+卡片 | [GitHub](https://github.com/tomlen045/fafa-generator) · [在线玩](https://tomlen045.github.io/fafa-generator/) |
| **⏳ life-progress** | 人生进度条——把你的时间摆在眼前 | [GitHub](https://github.com/tomlen045/life-progress) · [在线玩](https://tomlen045.github.io/life-progress/) |
| **🪵 gongde-tap** | 电子木鱼功德计数器——赛博积德 | [GitHub](https://github.com/tomlen045/gongde-tap) · [在线玩](https://tomlen045.github.io/gongde-tap/) |
| **💞 mbti-match** | MBTI灵魂配对——神仙组合还是塑料同窗 | [GitHub](https://github.com/tomlen045/mbti-match) · [在线玩](https://tomlen045.github.io/mbti-match/) |

---

<div align="center">

**🎯 更多宝藏工具 · 手机点开即玩**

[🧋 奶茶MBTI](https://tomlen045.github.io/naicha-mbti/) | [🔥 发疯文学](https://tomlen045.github.io/fafa-generator/) | [⏳ 人生进度条](https://tomlen045.github.io/life-progress/) | [🪵 电子功德](https://tomlen045.github.io/gongde-tap/) | [💞 MBTI配对](https://tomlen045.github.io/mbti-match/)

**⭐ 觉得有用？给个 Star 让更多人看到 →**

[![GitHub](https://img.shields.io/github/stars/tomlen045?style=social)](https://github.com/tomlen045)

</div>
