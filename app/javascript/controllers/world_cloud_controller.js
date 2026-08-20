import { Controller } from "@hotwired/stimulus"

const DESKTOP_POSITIONS = [
  { x: 18, y: 15, size: "large", tilt: -4 },
  { x: 39, y: 12, size: "small", tilt: 3 },
  { x: 58, y: 16, size: "medium", tilt: -1 },
  { x: 77, y: 22, size: "small", tilt: 5 },
  { x: 27, y: 29, size: "small", tilt: 4 },
  { x: 49, y: 31, size: "large", tilt: 2 },
  { x: 69, y: 36, size: "small", tilt: -2 },
  { x: 17, y: 43, size: "medium", tilt: -3 },
  { x: 36, y: 48, size: "medium", tilt: 2 },
  { x: 56, y: 52, size: "small", tilt: -5 },
  { x: 76, y: 55, size: "large", tilt: 3 },
  { x: 26, y: 65, size: "small", tilt: -2 },
  { x: 45, y: 68, size: "tiny", tilt: -5 },
  { x: 64, y: 72, size: "medium", tilt: 4 },
  { x: 81, y: 76, size: "tiny", tilt: -4 },
  { x: 36, y: 80, size: "medium", tilt: 2 }
]

const MOBILE_POSITIONS = [
  { x: 14, y: 12, size: "medium", tilt: -4 },
  { x: 58, y: 9, size: "small", tilt: 3 },
  { x: 36, y: 24, size: "large", tilt: -1 },
  { x: 81, y: 32, size: "small", tilt: 5 },
  { x: 12, y: 40, size: "small", tilt: 4 },
  { x: 55, y: 49, size: "medium", tilt: 2 },
  { x: 30, y: 61, size: "large", tilt: -3 },
  { x: 70, y: 63, size: "small", tilt: 4 },
  { x: 86, y: 73, size: "tiny", tilt: -2 },
  { x: 15, y: 84, size: "small", tilt: 3 },
  { x: 55, y: 88, size: "medium", tilt: -5 },
  { x: 80, y: 91, size: "small", tilt: 2 }
]

const MAX_PER_CONTINENT = 3
const ROTATION_INTERVAL = 9000
const FADE_OUT = 1450
const SETTLE = 1800
const SHORT_NAME = 7
const MEDIUM_NAME = 13
const LONG_NAME = 20

const clamp = (value, min, max) => Math.min(Math.max(value, min), max)

const shuffle = (array) => {
  const copy = [...array]

  for (let i = copy.length - 1; i > 0; i -= 1) {
    const j = Math.floor(Math.random() * (i + 1))
    ;[copy[i], copy[j]] = [copy[j], copy[i]]
  }

  return copy
}

const randomIndexes = (count, total) => {
  const indexes = new Set()

  while (indexes.size < count && indexes.size < total) indexes.add(Math.floor(Math.random() * total))

  return [...indexes]
}

const staggers = (count) => {
  const delays = [0]

  for (let i = 1; i < count; i += 1) delays.push(350 + Math.floor(Math.random() * 1050))

  return delays.sort((a, b) => a - b)
}

export default class extends Controller {
  static values = { cities: Array }

  connect() {
    this.pool = this.citiesValue.flatMap(({ continent, cities }) => cities.map((city) => ({ city, continent })))
    this.positions = this.#phone ? MOBILE_POSITIONS : DESKTOP_POSITIONS
    this.shown = new Set()
    this.counts = new Map()
    this.bubbles = this.positions.map((position, index) => this.#buildBubble(position, index))
    this.element.replaceChildren(...this.bubbles)

    if (window.matchMedia("(prefers-reduced-motion: reduce)").matches) return

    this.listeners = new AbortController()
    if (this.#phone) this.#startDragging()
    else this.#startRepelling()
    this.timer = setInterval(() => this.#rotate(), ROTATION_INTERVAL)
  }

  disconnect() {
    clearInterval(this.timer)
    cancelAnimationFrame(this.frame)
    this.listeners?.abort()
  }

  get #phone() {
    return window.matchMedia("(max-width: 640px)").matches
  }

  get #signal() {
    return this.listeners.signal
  }

  #buildBubble(position, index) {
    const bubble = document.createElement("span")
    bubble.className = "world-bubble"
    bubble.style.setProperty("--delay", `-${1600 + index * 730}ms`)
    this.#place(bubble, position)
    this.#fill(bubble, this.#claimCity() ?? this.pool[0], position)

    return bubble
  }

  // Spreads the visible cities over the continents rather than letting a
  // shuffle land six German towns at once.
  #claimCity() {
    const shuffled = shuffle(this.pool)
    const spread = shuffled.find(
      ({ city, continent }) => !this.shown.has(city) && (this.counts.get(continent) ?? 0) < MAX_PER_CONTINENT
    )
    const entry = spread ?? shuffled.find(({ city }) => !this.shown.has(city))
    if (!entry) return null

    this.shown.add(entry.city)
    this.counts.set(entry.continent, (this.counts.get(entry.continent) ?? 0) + 1)

    return entry
  }

  #releaseCity(city, continent) {
    this.shown.delete(city)
    this.counts.set(continent, Math.max(0, (this.counts.get(continent) ?? 0) - 1))
  }

  #place(bubble, position) {
    const floatY = 0.36 + ((position.x * 3 + position.y) % 9) * 0.035

    bubble.style.setProperty("--x", `${position.x}%`)
    bubble.style.setProperty("--y", `${position.y}%`)
    bubble.style.setProperty("--tilt", `${position.tilt || 0}deg`)
    bubble.style.setProperty("--float-duration", `${10 + Math.abs(position.tilt || 0) * 0.65}s`)
    bubble.style.setProperty("--float-x", `${0.08 + ((position.x + position.y) % 7) * 0.025}rem`)
    bubble.style.setProperty("--float-y", `${floatY}rem`)
    bubble.style.setProperty("--float-y-mid", `${floatY * 0.55}rem`)
    bubble.style.setProperty("--float-y-low", `${floatY * 0.42}rem`)
  }

  #fill(bubble, entry, position) {
    bubble.textContent = entry.city
    bubble.dataset.continent = entry.continent
    bubble.dataset.size = this.#sizeFor(entry.city, position)
  }

  #sizeFor(city, position) {
    if (position.size === "large") return city.length <= SHORT_NAME ? "medium" : "large"
    if (position.size === "medium") return city.length <= SHORT_NAME ? "small" : "medium"
    if (city.length <= SHORT_NAME) return "tiny"
    if (city.length <= MEDIUM_NAME) return "small"
    if (city.length >= LONG_NAME) return "large"

    return "medium"
  }

  #jitter(position, seed) {
    return {
      ...position,
      x: clamp(position.x + (((seed * 17) % 7) - 3) * 0.35, 2, 94),
      y: clamp(position.y + (((seed * 23) % 7) - 3) * 0.45, 5, 92),
      tilt: clamp(((seed * 29 + position.x * 3 + position.y) % 15) - 7, -7, 7)
    }
  }

  #rotate() {
    const indexes = randomIndexes(Math.random() < 0.5 ? 2 : 3, this.bubbles.length)
    const delays = staggers(indexes.length)

    indexes.forEach((index, nth) => {
      const bubble = this.bubbles[index]
      const { continent } = bubble.dataset
      const city = bubble.textContent

      this.#releaseCity(city, continent)
      const entry = this.#claimCity()
      if (!entry) {
        this.shown.add(city)
        this.counts.set(continent, (this.counts.get(continent) ?? 0) + 1)
        return
      }

      const position = this.#jitter(this.positions[index], nth + 3)
      setTimeout(() => this.#swap(bubble, entry, position), delays[nth])
    })
  }

  #swap(bubble, entry, position) {
    if (bubble.classList.contains("is-dragging")) return

    bubble.classList.add("is-changing")

    setTimeout(() => {
      this.#place(bubble, position)
      this.#fill(bubble, entry, position)
      bubble.classList.replace("is-changing", "is-settling")
      setTimeout(() => bubble.classList.remove("is-settling"), SETTLE)
    }, FADE_OUT)
  }

  #offset(bubble, x, y) {
    bubble.style.setProperty("--repel-x", `${x.toFixed(2)}px`)
    bubble.style.setProperty("--repel-y", `${y.toFixed(2)}px`)
  }

  #settle(states, step) {
    let moving = false

    states.forEach((state) => {
      step(state)
      this.#offset(state.bubble, state.x, state.y)

      if (Math.abs(state.x - state.targetX) > 0.08 || Math.abs(state.y - state.targetY) > 0.08) moving = true
      if (state.dragging) moving = true
    })

    this.frame = moving ? requestAnimationFrame(() => this.#settle(states, step)) : null
  }

  #tick(states, step) {
    if (!this.frame) this.#settle(states, step)
  }

  #startRepelling() {
    const states = this.bubbles.map((bubble) => ({ bubble, x: 0, y: 0, targetX: 0, targetY: 0 }))
    const pointer = { active: false, x: 0, y: 0 }
    const radius = 170
    const maxPush = 28

    const aim = () => {
      states.forEach((state) => {
        if (!pointer.active) {
          state.targetX = 0
          state.targetY = 0
          return
        }

        const box = state.bubble.getBoundingClientRect()
        const dx = box.left + box.width / 2 - pointer.x
        const dy = box.top + box.height / 2 - pointer.y
        const distance = Math.hypot(dx, dy) || 1

        if (distance > radius) {
          state.targetX = 0
          state.targetY = 0
          return
        }

        const push = maxPush * (1 - distance / radius) ** 2
        state.targetX = (dx / distance) * push
        state.targetY = (dy / distance) * push
      })
    }

    const step = (state) => {
      state.x += (state.targetX - state.x) * 0.08
      state.y += (state.targetY - state.y) * 0.08
      if (Math.abs(state.x) < 0.03) state.x = 0
      if (Math.abs(state.y) < 0.03) state.y = 0
    }

    const follow = (event) => {
      pointer.active = true
      pointer.x = event.clientX
      pointer.y = event.clientY
      aim()
      this.#tick(states, step)
    }

    const release = () => {
      pointer.active = false
      aim()
      this.#tick(states, step)
    }

    this.element.addEventListener("pointermove", follow, { signal: this.#signal })
    this.element.addEventListener("pointerleave", release, { signal: this.#signal })
    this.element.addEventListener("pointercancel", release, { signal: this.#signal })
    window.addEventListener("blur", release, { signal: this.#signal })
  }

  #startDragging() {
    const states = this.bubbles.map((bubble) => ({
      bubble,
      x: 0,
      y: 0,
      vx: 0,
      vy: 0,
      targetX: 0,
      targetY: 0,
      startX: 0,
      startY: 0,
      startOffsetX: 0,
      startOffsetY: 0,
      dragging: false
    }))
    const byBubble = new Map(states.map((state) => [state.bubble, state]))
    const dragging = new Map()
    let topLayer = 10

    const limit = (x, y) => {
      const distance = Math.hypot(x, y)
      const furthest = clamp(window.innerWidth * 0.12, 34, 52)
      if (distance <= furthest || distance === 0) return { x, y }

      const scale = furthest / distance

      return { x: x * scale, y: y * scale }
    }

    const step = (state) => {
      const spring = state.dragging ? 0.2 : 0.08
      const damping = state.dragging ? 0.62 : 0.78

      state.vx = (state.vx + (state.targetX - state.x) * spring) * damping
      state.vy = (state.vy + (state.targetY - state.y) * spring) * damping
      state.x += state.vx
      state.y += state.vy

      if (!state.dragging && Math.abs(state.x) < 0.03 && Math.abs(state.vx) < 0.03) {
        state.x = 0
        state.vx = 0
      }
      if (!state.dragging && Math.abs(state.y) < 0.03 && Math.abs(state.vy) < 0.03) {
        state.y = 0
        state.vy = 0
      }
    }

    const grab = (event) => {
      const state = byBubble.get(event.currentTarget)
      if (!state) return

      event.preventDefault()
      state.dragging = true
      state.startX = event.clientX
      state.startY = event.clientY
      state.startOffsetX = state.targetX
      state.startOffsetY = state.targetY
      state.bubble.classList.add("is-dragging")
      topLayer += 1
      state.bubble.style.zIndex = String(topLayer)
      dragging.set(event.pointerId, state)
      state.bubble.setPointerCapture?.(event.pointerId)
      this.#tick(states, step)
    }

    const drag = (event) => {
      const state = dragging.get(event.pointerId)
      if (!state) return

      event.preventDefault()
      const next = limit(
        state.startOffsetX + event.clientX - state.startX,
        state.startOffsetY + event.clientY - state.startY
      )
      state.targetX = next.x
      state.targetY = next.y
      this.#tick(states, step)
    }

    const drop = (event) => {
      const state = dragging.get(event.pointerId)
      if (!state) return

      dragging.delete(event.pointerId)
      state.dragging = false
      state.targetX = 0
      state.targetY = 0
      state.bubble.classList.remove("is-dragging")

      if (state.bubble.hasPointerCapture?.(event.pointerId)) state.bubble.releasePointerCapture(event.pointerId)
      this.#tick(states, step)
    }

    const dropAll = () => {
      dragging.clear()
      states.forEach((state) => {
        state.dragging = false
        state.targetX = 0
        state.targetY = 0
        state.bubble.classList.remove("is-dragging")
      })
      this.#tick(states, step)
    }

    for (const bubble of this.bubbles) {
      bubble.addEventListener("pointerdown", grab, { signal: this.#signal })
    }

    window.addEventListener("pointermove", drag, { signal: this.#signal })
    window.addEventListener("pointerup", drop, { signal: this.#signal })
    window.addEventListener("pointercancel", drop, { signal: this.#signal })
    window.addEventListener("blur", dropAll, { signal: this.#signal })
  }
}
