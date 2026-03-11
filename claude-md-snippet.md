## Todo 系统
- 用户通过 shell 命令 `td "想法"` 直接写入项目的 `.claude/todo.md`，不经过 CC 对话
- 对话开始时，检查 `.claude/todo.md`，如果有内容，主动告知用户有 N 条待处理 todo
- 当用户说"看看 todo"时，读取并逐条讨论/执行
- 处理完的条目删除

## Memory 系统（per project）

每个项目在 auto-memory 目录下的结构：

```
memory/
  MEMORY.md              # 索引，< 100 行，永远自动加载
  logs/                  # 流水账，PreCompact hook 自动写入
    2026-03-11.md
  knowledge/             # 提炼的知识，手动触发
    decisions.md         # 架构决策（为什么选 A 不选 B）
    gotchas.md           # 踩过的坑
    patterns.md          # 代码模式和约定
    dependencies.md      # 外部库/API 关键知识
    preferences.md       # 用户偏好
```

### PreCompact（自动）
- hook 自动把当前 session 的工作摘要写入 `memory/logs/YYYY-MM-DD.md`
- 只记流水账，不做分类

### 命令："record"
当用户说 "record" 时，从**当前对话**中提取知识，直接写入：
1. 回顾当前对话，识别有长期价值的知识点
2. 直接写入 `memory/knowledge/` 对应文件（decisions/gotchas/patterns/dependencies/preferences）
3. 每条格式：`[YYYY-MM-DD] 内容`，新的在最上面
4. 更新 MEMORY.md 索引
5. 简要告知用户记录了什么

### 命令："distill"
当用户说 "distill" 时，从**积累的日志**中批量提取知识，直接写入：
1. 读取 `memory/logs/` 下所有未标记的日志
2. 提取有长期价值的知识点，直接写入 `memory/knowledge/` 对应文件
3. 已处理的日志标记 `<!-- distilled: YYYY-MM-DD -->`
4. 更新 MEMORY.md 索引
5. 简要告知用户提取了什么

### 通用规则
- 所有 memory 操作都是 per project，不跨项目
- knowledge 文件超过 200 行时自动拆分
