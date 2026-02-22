# Changelog

[English](#english) | [简体中文](#简体中文)

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