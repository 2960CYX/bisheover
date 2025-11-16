<script setup lang="ts">
import { computed } from 'vue'

type Placement = 'right' | 'left'

defineProps<{ open: boolean; placement?: Placement; title?: string }>()

const emit = defineEmits<{ (e: 'update:open', value: boolean): void }>()

const padding = 24
const minWidth = 360
const maxWidth = 620
const minHeight = 320
const maxHeight = 680

const dockStyle = computed(() => {
  const vw = Math.min(typeof window === 'undefined' ? maxWidth : window.innerWidth, 1440)
  const width = Math.min(Math.max(vw * 0.32, minWidth), maxWidth)
  const height = Math.min(Math.max((typeof window === 'undefined' ? maxHeight : window.innerHeight) * 0.7, minHeight), maxHeight)
  return {
    width: `${width}px`,
    height: `${height}px`,
    padding: `${padding}px`,
  }
})

function close() {
  emit('update:open', false)
}
</script>

<template>
  <Transition name="ai-dock" mode="out-in">
    <section
      v-if="open"
      class="ai-dock"
      :style="dockStyle"
    >
      <header class="ai-dock__header">
        <p class="ai-dock__title">{{ title ?? 'AI 助理' }}</p>
        <button class="ai-dock__close" type="button" @click="close">×</button>
      </header>
      <div class="ai-dock__body">
        <slot name="body" />
      </div>
      <footer class="ai-dock__footer">
        <slot name="footer" />
      </footer>
    </section>
  </Transition>
</template>

<style scoped>
.ai-dock-enter-active,
.ai-dock-leave-active {
  transition: opacity 0.2s ease, transform 0.2s ease;
}

.ai-dock-enter-from,
.ai-dock-leave-to {
  opacity: 0;
  transform: translateY(12px) scale(0.98);
}

.ai-dock {
  position: fixed;
  inset-block-end: clamp(16px, 4vh, 32px);
  inset-inline-end: clamp(16px, 6vw, 64px);
  z-index: 40;
  display: flex;
  flex-direction: column;
  gap: 12px;
  border-radius: 20px;
  border: 1px solid rgb(255 255 255 / 0.25);
  background: color-mix(in srgb, rgb(17 25 40 / 0.95), transparent 5%);
  box-shadow: 0 20px 65px rgba(15, 23, 42, 0.25);
  color: #f8fafc;
  backdrop-filter: blur(22px);
  max-width: min(92vw, 640px);
  max-height: min(88vh, 720px);
  box-sizing: border-box;
}

.ai-dock__header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  gap: 8px;
}

.ai-dock__title {
  font-size: 1rem;
  font-weight: 600;
}

.ai-dock__close {
  width: 32px;
  height: 32px;
  border-radius: 999px;
  border: none;
  background: rgb(148 163 184 / 0.2);
  color: inherit;
  font-size: 20px;
  cursor: pointer;
  display: grid;
  place-items: center;
  transition: background 0.15s ease;
}

.ai-dock__close:hover {
  background: rgb(148 163 184 / 0.35);
}

.ai-dock__body {
  flex: 1;
  min-height: 200px;
  padding-block: 4px;
  overflow: auto;
  scrollbar-gutter: stable both-edges;
}

.ai-dock__body ::v-deep blockquote {
  margin-inline-start: 0;
  padding-inline-start: 1rem;
  border-inline-start: 3px solid rgb(148 163 184 / 0.35);
}

.ai-dock__footer {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

@media (max-width: 640px) {
  .ai-dock {
    inset-inline: clamp(12px, 4vw, 20px);
    width: auto !important;
    min-width: 0;
    border-radius: 16px;
  }
}
</style>
