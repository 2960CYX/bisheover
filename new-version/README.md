# Vitesse AI Dock 调整

该目录提供了一个可在 Vitesse 项目中直接复用的 `AiAssistantDock` 组件，用于解决 AI 对话窗口被文章引用层遮挡、回答区域过窄的问题。

## 主要特性

- **自适应宽高**：根据视窗宽度自动在 `360px ~ 620px` 范围内调整宽度，纵向高度可覆盖 70% 以上屏幕，最大 680px。
- **固定定位与高层级**：通过 `fixed` + `z-index: 40` 保证窗口不会被正文 blockquote 等内容遮住。
- **可滚动内容区**：回答区启用了 `overflow: auto` 与稳定滚动槽，引用内容使用 `::v-deep blockquote` 重置边距，避免顶到边界。
- **移动端优化**：在 640px 以下的屏幕会自动横向撑满并降低圆角，使得输入与回答区域仍然可用。

## 使用方式

```vue
<script setup lang="ts">
import AiAssistantDock from '@/components/ai/AiAssistantDock.vue'
const open = ref(true)
</script>

<template>
  <AiAssistantDock v-model:open="open">
    <template #body>
      <!-- 你的 AI 回答 -->
    </template>
    <template #footer>
      <!-- 输入框等 -->
    </template>
  </AiAssistantDock>
</template>
```

将组件放在 `App.vue` 或任意页面的根节点即可生效，无需额外样式依赖。
