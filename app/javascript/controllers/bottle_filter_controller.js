import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "item", "list",
    "query", "year",
    "ratingButton",
    "sortButton",
    "count", "empty",
    "chipsRow",
    "chipRating", "chipRatingText",
    "chipYear", "chipYearText",
    "clearAll"
  ]

  connect() {
    this.currentSort = "date_desc"
    this.currentRating = ""
    this.setActiveSort()
    this.setActiveRating()
    this.applyAll({ animate: false })
  }



  // Called by both input (search) and change (selects)
  filter(event) {
    const fromSearch = event?.target === this.queryTarget

    if (fromSearch) {
      // Search is authoritative: clear filters immediately
      this.yearTarget.value = ""
      this.currentRating = ""
      this.setActiveRating()

      // Hide chips immediately (chips represent filters, not search)
      this.chipsRowTarget.classList.add("hidden")

      // Cancel any pending debounce
      if (this._t) clearTimeout(this._t)

      // Debounce typing only
      this._t = setTimeout(() => {
        this.applyAll({ animate: false })
      }, 80)

      return
    }

    // Select changes are immediate
    if (this._t) clearTimeout(this._t)
    this.applyAll({ animate: false })
  }

  sort(event) {
    event.preventDefault()
    this.currentSort = event.currentTarget.dataset.sortValue
    this.setActiveSort()
    this.applyAll({ animate: true })
  }

  filterRating(event) {
    event.preventDefault()
    this.currentRating = event.currentTarget.dataset.ratingValue
    this.setActiveRating()
    if (this._t) clearTimeout(this._t)
    this.applyAll({ animate: false })
  }

  clearOne(event) {
    const key = event.currentTarget.dataset.filterKey
    if (key === "year") this.yearTarget.value = ""
    if (key === "rating") {
      this.currentRating = ""
      this.setActiveRating()
    }

    if (this._t) clearTimeout(this._t)
    this.applyAll({ animate: false })
  }

  clearAll() {
    this.queryTarget.value = ""
    this.yearTarget.value = ""
    this.currentRating = ""
    this.setActiveRating()

    if (this._t) clearTimeout(this._t)

    this.applyAll({ animate: false })
  }

  applyAll({ animate }) {
    this.applyFilter()
    this.applySort({ animate })
    this.updateUI()
  }

  applyFilter() {
    let q = (this.queryTarget.value || "").trim().toLowerCase()
    const year = this.yearTarget.value
    const rating = this.currentRating

    // Filters win over search: if any filter active, clear search AND q
    if ((year || rating) && q) {
      this.queryTarget.value = ""
      q = ""
    }

    this.itemTargets.forEach(item => {
      const itemRating = item.dataset.rating
      const isUnrated = item.dataset.unrated === "true"
      const text = `${item.dataset.distillery} ${item.dataset.name}`.toLowerCase()

      const matchesQuery = !q || text.includes(q)
      const matchesYear = !year || item.dataset.year === year
      
      let matchesRating = true
      if (rating === "unrated") {
        matchesRating = isUnrated
      } else if (rating) {
        matchesRating = itemRating && Number(itemRating) >= Number(rating)
      }

      item.classList.toggle(
        "hidden",
        !(matchesQuery && matchesYear && matchesRating)
      )
    })
  }

  applySort({ animate }) {
    const all = [...this.itemTargets]
    const visible = all.filter(i => !i.classList.contains("hidden"))
    const hidden = all.filter(i => i.classList.contains("hidden"))

    const ratingNum = (el) => {
      const v = el.dataset.rating
      return v === "" || v == null ? -1 : Number(v)
    }

    const avgRatingNum = (el) => {
      const v = el.dataset.avgRating
      return v === "" || v == null ? -1 : Number(v)
    }

    const dateNum = (el) => {
      const n = Number(el.dataset.date)
      return Number.isNaN(n) ? 0 : n
    }

    visible.sort((a, b) => {
      const ad = dateNum(a), bd = dateNum(b)
      const ar = ratingNum(a), br = ratingNum(b)
      const aar = avgRatingNum(a), bar = avgRatingNum(b)
      const tie = bd - ad

      switch (this.currentSort) {
        case "date_desc": return (bd - ad) || (br - ar) || 0
        case "rating_desc": return (br - ar) || tie
        case "avg_rating_desc": return (bar - aar) || tie
        case "distillery_asc": return a.dataset.distillery.localeCompare(b.dataset.distillery, undefined, { sensitivity: 'base' }) || tie
        case "distillery_desc": return b.dataset.distillery.localeCompare(a.dataset.distillery, undefined, { sensitivity: 'base' }) || tie
        case "bottle_asc": return a.dataset.name.localeCompare(b.dataset.name, undefined, { sensitivity: 'base' }) || tie
        case "bottle_desc": return b.dataset.name.localeCompare(a.dataset.name, undefined, { sensitivity: 'base' }) || tie
        default: return 0
      }
    })

    const frag = document.createDocumentFragment()
    visible.forEach(item => frag.appendChild(item))
    hidden.forEach(item => frag.appendChild(item))
    this.listTarget.appendChild(frag)

    if (animate) this.animateRows(visible)
  }

  animateRows(rows) {
    rows.forEach((el, idx) => {
      el.classList.add("transition-all", "duration-200", "opacity-0", "translate-y-1")
      setTimeout(() => el.classList.remove("opacity-0", "translate-y-1"), Math.min(idx * 10, 90))
    })
  }

  setActiveSort() {
    this.sortButtonTargets.forEach(btn => {
      const active = btn.dataset.sortValue === this.currentSort
      btn.classList.toggle("border-lagavulin-gold/70", active)
      btn.classList.toggle("text-lagavulin-gold", active)
      btn.classList.toggle("bg-lagavulin-gold/10", active)
      btn.classList.toggle("border-lagavulin-gold/30", !active)
      btn.classList.toggle("text-lagavulin-gold/70", !active)
      btn.classList.toggle("bg-transparent", !active)
    })
  }

  setActiveRating() {
    this.ratingButtonTargets.forEach(btn => {
      const active = btn.dataset.ratingValue === this.currentRating
      btn.classList.toggle("border-lagavulin-gold/70", active)
      btn.classList.toggle("text-lagavulin-gold", active)
      btn.classList.toggle("bg-lagavulin-gold/10", active)
      btn.classList.toggle("border-lagavulin-gold/30", !active)
      btn.classList.toggle("text-lagavulin-gold/70", !active)
      btn.classList.toggle("bg-transparent", !active)
    })
  }

  updateUI() {
    const visibleCount = this.itemTargets.filter(i => !i.classList.contains("hidden")).length
    this.countTarget.textContent = String(visibleCount)
    this.emptyTarget.classList.toggle("hidden", visibleCount !== 0)

    const year = this.yearTarget.value
    const rating = this.currentRating
    const q = (this.queryTarget.value || "").trim()

    const ratingStars = { "4": "★★★★ 4+", "3": "★★★ 3+", "2": "★★ 2+", "unrated": "Unrated" }
    this.setChip(this.chipRatingTarget, this.chipRatingTextTarget, rating ? ratingStars[rating] || rating : "")
    this.setChip(this.chipYearTarget, this.chipYearTextTarget, year ? `Year: ${year}` : "")

    // IMPORTANT: chips represent FILTERS ONLY (not search)
    const anyFiltersActive = Boolean(year || rating)
    this.chipsRowTarget.classList.toggle("hidden", !anyFiltersActive)

    // Clear-all should show if search OR filters are active
    const anyActive = Boolean(q || anyFiltersActive)
    this.clearAllTarget.classList.toggle("hidden", !anyActive)
  }

  setChip(chipEl, textEl, text) {
    const show = Boolean(text)
    chipEl.classList.toggle("hidden", !show)
    if (show) textEl.textContent = text
  }


}


