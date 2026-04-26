# Git Worktrees 最佳实践

## 1. 什么是 Worktree

Git worktree 允许你在同一个仓库中同时检出多个分支到不同的工作目录。每个 worktree 拥有独立的文件系统视图，但共享同一个 `.git` 对象数据库。

```
myrepo.git/          ← bare 仓库（核心）
├── main/            ← main 分支的 worktree
├── feature-foo/     ← feature/foo 分支的 worktree
└── hotfix-bar/      ← hotfix/bar 分支的 worktree
```

## 2. 为什么使用 Worktree

| 场景 | 传统方式 | Worktree 方式 |
|------|----------|---------------|
| 紧急 hotfix | `git stash` → 切换分支 → 修复 → 切换回来 → `git stash pop` | 直接进入 hotfix 目录，修复提交 |
| 多分支并行开发 | 频繁 `git checkout`，重建构建产物 | 每个分支独立目录，增量编译保留 |
| 代码评审 | `git checkout origin/PR-branch` | 单独目录检出，不影响当前工作 |
| 长时间运行任务 | 分支被占用，无法做其他事 | 独立目录，互不干扰 |

## 3. 推荐的工作流：Bare + Worktrees

### 3.1 初始化仓库

```bash
# 克隆为 bare 仓库（约定加 .git 后缀）
git clone --bare <remote-url> myproject.git
cd myproject.git

# 设置 git config，让 fetch 能更新所有 refs
git config remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
git fetch origin
```

### 3.2 添加 Worktree

```bash
# 基于远程分支创建 worktree
git worktree add ../main main
git worktree add ../feature-login feature/login
git worktree add ../hotfix-auth hotfix/auth

# 目录结构
myproject.git/
main/
feature-login/
hotfix-auth/
```

### 3.3 日常操作

```bash
# 查看所有 worktree
git worktree list
# 输出示例：
# /path/to/myproject.git  (bare)
# /path/to/main           1234abc [main]
# /path/to/feature-login  5678def [feature/login]

# 创建新特性分支的 worktree
git worktree add -b feature/payment ../feature-payment origin/main

# 删除 worktree（先删除目录，再 prune）
rm -rf ../feature-payment
git worktree prune

# 或一并删除分支
git worktree remove ../feature-payment  # Git 2.17+，会自动清理
```

## 4. 命名与目录规范

### 4.1 目录命名

```
# 推荐：扁平结构，与仓库同级
myproject.git/       # bare 仓库
myproject-main/      # main 分支
myproject-feature-xxx/   # 特性分支
myproject-hotfix-xxx/    # 热修复分支

# 或集中式子目录
myproject/
  .git-repo/         # bare 仓库
  main/
  features/
    login/
    payment/
  hotfixes/
    auth-2026-04/
```

### 4.2 分支命名映射

| 分支名 | Worktree 目录名 |
|--------|-----------------|
| `main` | `main` |
| `feature/login` | `feature-login` |
| `bugfix/memory-leak` | `bugfix-memory-leak` |
| `release/v2.3` | `release-v2.3` |

> 斜杠 `/` 在目录名中可能引发嵌套歧义，建议替换为连字符 `-`。

## 5. 关键命令速查

```bash
# 创建 worktree
git worktree add <path> <branch>              # 基于已有分支
git worktree add -b <new-branch> <path> <base> # 创建并检出到新分支

# 查看状态
git worktree list
git worktree list --porcelain                 # 脚本解析用

# 锁定 worktree（防止被自动清理）
git worktree lock <path>

# 解锁
git worktree unlock <path>

# 移动 worktree（Git 2.33+）
git worktree move <old-path> <new-path>

# 删除
git worktree remove <path>                    # 安全删除，检查未提交更改
git worktree remove -f <path>                 # 强制删除

# 清理残留记录
git worktree prune
```

## 6. 注意事项与陷阱

### 6.1 同一个分支不能同时存在于多个 worktree

```bash
# 错误：main 已检出到 ../main
git worktree add ../another-main main
# fatal: 'main' is already checked out at '/path/to/main'
```

**解决**：一个分支只能对应一个 worktree。如需第二个副本，创建临时分支。

### 6.2 子模块

Worktree 中的子模块默认独立初始化，需手动同步：

```bash
cd <worktree-path>
git submodule update --init --recursive
```

### 6.3 未提交更改的保护

```bash
# git worktree remove 会阻止删除有未提交更改的 worktree
git worktree remove ../feature-x
# error: 'feature-x' contains modified or untracked files, use --force to delete it

# 建议先清理或提交，再删除；或使用 --force 谨慎强制删除
```

### 6.4 IDE 与工具兼容性

- VS Code: 可直接打开各 worktree 目录作为独立窗口
- JetBrains: 每个 worktree 作为独立项目打开
- 全局搜索工具（如 `ripgrep`）：注意排除其他 worktree 目录避免重复结果

## 7. 清理策略

```bash
# 手动清理已合并的特性分支 worktree
git branch --merged main | grep feature/ | while read branch; do
    dir=$(echo "$branch" | tr '/' '-')
    git worktree remove "../$dir" 2>/dev/null || true
    git branch -d "$branch"
done

# 自动清理失效的 worktree 记录
git worktree prune
```

## 8. 与主流工作流的结合

### Git Flow

```bash
# 开发新特性
git worktree add -b feature/awesome ../feature-awesome develop

# 准备发布
git worktree add -b release/1.2 ../release-1.2 develop

# 生产热修复
git worktree add -b hotfix/critical ../hotfix-critical main
```

### GitHub Flow / Trunk-based

```bash
# 基于 main 快速创建 PR 分支
git worktree add -b feat/small-change ../pr-small-change main
# ... 开发、提交、推送到远程创建 PR ...
# PR 合并后清理
git worktree remove ../pr-small-change
git branch -D feat/small-change
```

## 9. 总结

| 原则 | 说明 |
|------|------|
| **使用 bare 仓库** | 作为管理中心，避免主工作目录污染 |
| **目录命名清晰** | 分支名映射到目录名，一目了然 |
| **用完即删** | 合并后的特性分支及时删除 worktree 和目录 |
| **定期 prune** | 清理残留记录，保持 `git worktree list` 准确 |
| **锁定重要目录** | 长期运行的 worktree 使用 `lock` 防止误删 |