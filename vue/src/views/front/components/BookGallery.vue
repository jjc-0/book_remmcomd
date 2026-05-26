<script setup>
import { ref, onMounted, onUnmounted } from 'vue'
import { useRouter } from 'vue-router'
import { gsap } from 'gsap'
import request from '../../../utils/request'

const router = useRouter()
const galleryRef = ref(null)
const carouselRef = ref(null)
const offset = ref(0)
const books = ref([])
let animationFrameId = null

const loadBooks = () => {
  request.get('/book').then(res => {
    books.value = res.data.map(book => ({
      id: book.id,
      title: book.name,
      img: book.img
    }))
    totalWidth = books.value.length * (cardWidth + cardGap)
    isAnimating = true
    animate()
    updateCarousel()
  })
}

const cardWidth = 220
const cardGap = 30
let totalWidth = 0

let targetOffset = 0
let isAnimating = false
let autoSpeed = 0.4
let currentSpeed = 0.4
let userInteracting = false
let interactionTimeout = null

const updateCarousel = () => {
  if (!carouselRef.value) return

  const containerWidth = carouselRef.value.offsetWidth
  const items = carouselRef.value.querySelectorAll('.carousel__item')
  const centerX = containerWidth / 2 - cardWidth / 2
  const visibleHalf = containerWidth / 2 + cardWidth

  items.forEach((item, index) => {
    const baseX = index * (cardWidth + cardGap)
    let displayX = baseX - offset.value

    if (displayX < centerX - visibleHalf) displayX += totalWidth
    if (displayX > centerX + visibleHalf) displayX -= totalWidth

    const distFromCenter = Math.abs(displayX - centerX)
    const maxDist = visibleHalf

    const scale = 1 - (distFromCenter / maxDist) * 0.3
    const opacity = 1 - (distFromCenter / maxDist) * 0.45
    const zIndex = Math.round(100 - (distFromCenter / maxDist) * 60)

    gsap.set(item, {
      x: displayX,
      scale: Math.max(scale, 0.7),
      opacity: Math.max(opacity, 0.55),
      zIndex: zIndex
    })
  })
}

const animate = () => {
  if (!userInteracting) {
    currentSpeed += (autoSpeed - currentSpeed) * 0.02
  }
  targetOffset += currentSpeed
  if (targetOffset >= totalWidth) targetOffset -= totalWidth
  if (targetOffset < 0) targetOffset += totalWidth

  offset.value += (targetOffset - offset.value) * 0.06
  updateCarousel()

  if (isAnimating) {
    animationFrameId = requestAnimationFrame(animate)
  }
}

const onUserInteract = (delta) => {
  userInteracting = true
  currentSpeed = Math.min(Math.max(currentSpeed + delta, -3), 3)

  if (interactionTimeout) clearTimeout(interactionTimeout)
  interactionTimeout = setTimeout(() => {
    userInteracting = false
  }, 1500)
}

const handleWheel = (e) => {
  e.preventDefault()
  onUserInteract(e.deltaY * 0.02)
}

let touchStartX = 0
let mouseDownPos = { x: 0, y: 0 }
let mouseDownBookId = null

const handleTouchStart = (e) => {
  touchStartX = e.touches[0].clientX
}

const handleTouchMove = (e) => {
  e.preventDefault()
  const touchX = e.touches[0].clientX
  const deltaX = touchStartX - touchX
  onUserInteract(deltaX * 0.05)
  touchStartX = touchX
}

const handleMouseDown = (e, bookId) => {
  mouseDownPos = { x: e.clientX, y: e.clientY }
  mouseDownBookId = bookId
}

const handleMouseUp = (e) => {
  const dx = Math.abs(e.clientX - mouseDownPos.x)
  const dy = Math.abs(e.clientY - mouseDownPos.y)
  if (dx < 5 && dy < 5 && mouseDownBookId) {
    router.push('/front/goodsDetail?id=' + mouseDownBookId)
  }
  mouseDownBookId = null
}

const handleMouseEnter = () => {
  userInteracting = true
  currentSpeed = autoSpeed * 3
}

const handleMouseLeave = () => {
  userInteracting = false
}

const handleResize = () => {
  updateCarousel()
}

onMounted(() => {
  loadBooks()

  if (galleryRef.value) {
    galleryRef.value.addEventListener('wheel', handleWheel, { passive: false })
    galleryRef.value.addEventListener('touchstart', handleTouchStart, { passive: false })
    galleryRef.value.addEventListener('touchmove', handleTouchMove, { passive: false })
    galleryRef.value.addEventListener('mouseenter', handleMouseEnter)
    galleryRef.value.addEventListener('mouseleave', handleMouseLeave)
  }

  window.addEventListener('resize', handleResize)
})

onUnmounted(() => {
  isAnimating = false
  if (animationFrameId) {
    cancelAnimationFrame(animationFrameId)
  }
  if (interactionTimeout) {
    clearTimeout(interactionTimeout)
  }

  if (galleryRef.value) {
    galleryRef.value.removeEventListener('wheel', handleWheel)
    galleryRef.value.removeEventListener('touchstart', handleTouchStart)
    galleryRef.value.removeEventListener('touchmove', handleTouchMove)
    galleryRef.value.removeEventListener('mouseenter', handleMouseEnter)
    galleryRef.value.removeEventListener('mouseleave', handleMouseLeave)
  }
  window.removeEventListener('resize', handleResize)
})
</script>

<template>
  <div ref="galleryRef" class="book-gallery">
    <div class="gallery-title">
      <h2>精选图书推荐</h2>
      <p>探索知识的海洋</p>
    </div>

    <div ref="carouselRef" class="carousel">
      <div
        v-for="book in books"
        :key="book.id"
        class="carousel__item"
        @mousedown="(e) => handleMouseDown(e, book.id)"
        @mouseup="handleMouseUp"
      >
        <div class="carousel__card">
          <img :src="book.img" :alt="book.title" class="carousel__img" />
        </div>
      </div>
    </div>
  </div>
</template>

<style scoped>
.book-gallery {
  width: 100%;
  height: 480px;
  background: transparent;
  display: flex;
  flex-direction: column;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;
  cursor: grab;
}

.book-gallery:active {
  cursor: grabbing;
}

.gallery-title {
  text-align: center;
  margin-bottom: 16px;
  z-index: 10;
}

.gallery-title h2 {
  font-size: 2.4rem;
  font-weight: 700;
  color: #2c3e50;
  margin: 0 0 6px 0;
  letter-spacing: 2px;
}

.gallery-title p {
  font-size: 1.05rem;
  color: #909399;
  margin: 0;
  letter-spacing: 1px;
}

.carousel {
  position: relative;
  width: 100%;
  height: 340px;
}

.carousel__item {
  position: absolute;
  top: 50%;
  margin-top: -160px;
  width: 220px;
  height: 320px;
  will-change: transform, opacity;
}

.carousel__card {
  width: 100%;
  height: 100%;
  border-radius: 10px;
  overflow: hidden;
  cursor: pointer;
  box-shadow:
    0 4px 12px rgba(0, 0, 0, 0.08),
    0 8px 24px rgba(0, 0, 0, 0.06);
  border: 2px solid #e4e7ed;
  background: #ffffff;
}

.carousel__img {
  width: 100%;
  height: 100%;
  object-fit: cover;
  display: block;
}

@media (max-width: 768px) {
  .book-gallery {
    height: 380px;
  }

  .gallery-title h2 {
    font-size: 1.6rem;
  }

  .gallery-title p {
    font-size: 0.85rem;
  }

  .carousel {
    height: 260px;
  }

  .carousel__item {
    width: 150px;
    height: 220px;
    margin-top: -110px;
  }
}
</style>
