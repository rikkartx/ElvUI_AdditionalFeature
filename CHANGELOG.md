> Developed by Gemini

# Changelog

[English](#english) | [简体中文](#简体中文)

---

## [0.1.2] - Target & Focus Colors

### English

#### Added
- **Target Nameplate Color**: Added a new feature to set a custom health bar color for your current target, helping you easily track your primary target in chaotic situations.
- **Focus Nameplate Color**: Added the ability to set a custom health bar color for your focus target.
- **Color Priority System**: Implemented a strict priority order for nameplate colors (Target > Focus > Quest > Threat/Normal).
- **Nameplate Quest Text Alpha**: Added a new feature to modify the transparency of nameplate quest text.

---

### 简体中文

#### 新增
- **当前目标染色**：新增功能，可将当前选中目标的姓名板血条修改为自定义颜色，助你在混乱的战斗中一眼锁定目标。
- **焦点目标染色**：新增功能，支持为你的焦点目标设置专属的血条颜色。
- **色彩优先级系统**：为姓名板渲染建立了严格的优先级规则（当前目标 > 焦点 > 任务怪 > 常规/仇恨染色）。
- **姓名板任务文本透明度**：新增功能，修改姓名板任务文本透明度

---

## [0.1.1] - Quest Highlighting & Modularization

### English

#### Added
- **Nameplate Quest Color**: Added a new feature to change the health bar color of quest objectives. (Active in the open world only to prevent API restriction errors inside instances).
- **Smart Quest Tracking**: Implemented regex parsing for Tooltips. The addon now intelligently stops coloring mobs once their specific quest requirement (e.g., "10/10" or "100%") is fulfilled.
- **Modular Codebase**: Refactored the entire addon into separate, easily maintainable modules (`Aura`, `Nameplate`, `Tag`, `Locales`).
- **Locales**: Added fully translated, dedicated locale files for `deDE`, `esES`, `frFR`, `itIT`, `koKR`, `ptBR`, and `ruRU`.

#### Fixed
- **Text Overlap Bug**: Fixed an ElvUI native visual bug where the target's name (`TargetText`) would overlap with the interrupter's name (`[Interrupted by Player]`) on the castbar upon a successful interrupt. The target's name is now correctly hidden.
- **API Compliance**: Removed legacy combat log hooks to comply with Blizzard's WoW 12.0.0+ API restrictions. Interrupt colors now work reliably without depending on combat log interrupter data.

---

### 简体中文

#### 新增
- **任务目标变色**：新增功能，可将属于当前任务目标的小怪姓名板血条强制修改为自定义颜色。（仅在野外生效，进入副本自动禁用以规避暴雪 API 限制）。
- **智能任务进度追踪**：引入了正则表达式解析 Tooltip 进度。当特定小怪的击杀/收集需求达成时（如 "10/10" 或 "100%"），插件会自动停止染色，恢复其原本颜色。
- **代码重构**：将臃肿的单文件重构为模块化结构，拆分出光环 (`Aura`)、姓名板 (`Nameplate`)、标签 (`Tag`) 和多语言 (`Locales`) 独立模块，极大提升运行效率和代码可维护性。
- **多语言扩展**：新增并完善了德语、西班牙语、法语、意大利语、韩语、葡萄牙语和俄语的独立本地化翻译文件。

#### 修复
- **文本重叠 Bug**：修复了施法被打断时，施法条上的目标文本（`TargetText`）与打断者名字（`[被 xxx 打断]`）发生重叠的视觉错误。打断发生时目标文本现已被强制隐藏。
- **12.0 API 适配**：移除了过时的战斗日志监听，全面适配 12.0.0+ 严格 API。打断变色功能不再因获取不到打断者信息而失效。

---

## [0.1.0] - Initial Release

### English

#### Added
- **Force Solo Threat Color**: Added toggle to force ElvUI to use solo threat coloring in nameplates regardless of party/raid state.
- **Nameplate Interrupt Color**: Added a castbar hook that changes the color of a nameplate's castbar when successfully interrupted.
- **Interrupt Color Settings**: Added fallback mechanisms and a color picker to allow users to override the default interrupt color.
- **Custom Reaction Color Tag**: Implemented a dynamic custom text tag (`[eAF_reactioncolor]` by default) for use in UnitFrames and Nameplates.
- **Reaction Colors**: Added individual color pickers for Good (Friendly), Neutral, and Bad (Hostile) reaction states.
- **Aura Sweep Disabler**: Added an option to completely hide the radial cooldown animation (sweep) on player auras while preserving text timers.
- **Internationalization (i18n)**: Fully localized the addon settings for English (`enUS`), German (`deDE`), Spanish (`esES`/`esMX`), French (`frFR`), Italian (`itIT`), Korean (`koKR`), Portuguese (`ptBR`), Russian (`ruRU`), Simplified Chinese (`zhCN`), and Traditional Chinese (`zhTW`).

---

### 简体中文

#### 新增
- **强制单人仇恨颜色**：新增选项，可强制 ElvUI 姓名板使用单人仇恨颜色，无视当前的队伍/团队状态。
- **姓名板打断变色**：新增施法条 Hook，当成功打断目标施法时改变姓名板施法条的颜色。
- **打断颜色设置**：新增自定义颜色选择器以及兜底机制，允许玩家覆盖默认的打断颜色。
- **自定义声望颜色标签**：实现了动态文本标签（默认为 `[eAF_reactioncolor]`），可用于任何单位框架和姓名板。
- **声望颜色设置**：为友善（Good）、中立（Neutral）和敌对（Bad）状态添加了独立的颜色选择器。
- **关闭光环转圈动画**：新增选项，可彻底隐藏玩家光环上的冷却阴影转圈动画，仅保留文字倒计时。
- **国际化 (i18n)**：为插件设置添加了全面的多语言支持，包括英语 (`enUS`)、德语 (`deDE`)、西班牙语 (`esES`/`esMX`)、法语 (`frFR`)、意大利语 (`itIT`)、韩语 (`koKR`)、葡萄牙语 (`ptBR`)、俄语 (`ruRU`)、简体中文 (`zhCN`) 以及繁体中文 (`zhTW`)。