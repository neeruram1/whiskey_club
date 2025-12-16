import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "item", "list",
    "query", "distillery", "rating", "year",
    "sortButton",
    "count", "empty",
    "refinePanel", "refineToggle", "refineLabel", "refineChevron",
    "chipsRow",
    "chipDistillery", "chipDistilleryText",
    "chipRating", "chipRatingText",
    "chipYear", "chipYearText",
    "clearAll"
  ]

  connect() {
    this.currentSort = "date_desc"
    this.setActiveSort()
    this.applyAll({ animate: false })
  }

  toggleRefine() {
    const panelWasHidden = this.refinePanelTarget.classList.contains("hidden")
    const nowOpen = this.refinePanelTarget.classList.toggle("hidden") === false

    this.refineChevronTarget.classList.toggle("rotate-180", nowOpen)
    this.updateRefineLabel()

    // Auto-focus first filter when opening
    if (panelWasHidden && nowOpen) {
      requestAnimationFrame(() => this.distilleryTarget.focus())
    }
  }

  // Called by both input (search) and change (selects)
  filter(event) {
    const fromSearch = event?.target === this.queryTarget

    if (fromSearch) {
      // Search is authoritative: clear selects immediately
      this.distilleryTarget.value = ""
      this.ratingTarget.value = ""
      this.yearTarget.value = ""

      // Hide chips immediately (chips represent filters, not search)
      this.chipsRowTarget.classList.add("hidden")

      // Close the panel for clarity
      this.refinePanelTarget.classList.add("hidden")
      this.refineChevronTarget.classList.remove("rotate-180")

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

  clearOne(event) {
    const key = event.currentTarget.dataset.filterKey
    if (key === "distillery") this.distilleryTarget.value = ""
    if (key === "rating") this.ratingTarget.value = ""
    if (key === "year") this.yearTarget.value = ""

    if (this._t) clearTimeout(this._t)
    this.applyAll({ animate: false })
  }

  clearAll() {
    this.queryTarget.value = ""
    this.distilleryTarget.value = ""
    this.ratingTarget.value = ""
    this.yearTarget.value = ""

    if (this._t) clearTimeout(this._t)

    this.refinePanelTarget.classList.add("hidden")
    this.refineChevronTarget.classList.remove("rotate-180")

    this.applyAll({ animate: false })
  }

  applyAll({ animate }) {
    this.applyFilter()
    this.applySort({ animate })
    this.updateUI()
  }

  applyFilter() {
    let q = (this.queryTarget.value || "").trim().toLowerCase()
    const distillery = this.distilleryTarget.value
    const rating = this.ratingTarget.value
    const year = this.yearTarget.value

    // Filters win over search: if selects active, clear search AND q
    if ((distillery || rating || year) && q) {
      this.queryTarget.value = ""
      q = ""
    }

    this.itemTargets.forEach(item => {
      const itemRating = item.dataset.rating
      const text = `${item.dataset.distillery} ${item.dataset.name}`.toLowerCase()

      const matchesQuery = !q || text.includes(q)
      const matchesDistillery = !distillery || item.dataset.distillery === distillery
      const matchesRating = !rating || (itemRating && Number(itemRating) >= Number(rating))
      const matchesYear = !year || item.dataset.year === year

      item.classList.toggle(
        "hidden",
        !(matchesQuery && matchesDistillery && matchesRating && matchesYear)
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

    const dateNum = (el) => {
      const n = Number(el.dataset.date)
      return Number.isNaN(n) ? 0 : n
    }

    visible.sort((a, b) => {
      const ad = dateNum(a), bd = dateNum(b)
      const ar = ratingNum(a), br = ratingNum(b)
      const tie = bd - ad

      switch (this.currentSort) {
        case "date_desc": return (bd - ad) || (br - ar) || 0
        case "rating_desc": return (br - ar) || tie
        case "distillery_asc": return a.dataset.distillery.localeCompare(b.dataset.distillery) || tie
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
      btn.classList.toggle("text-lagavulin-gold", active)
      btn.classList.toggle("border-lagavulin-gold/70", active)
      btn.classList.toggle("text-[#E8D6A7]/70", !active)
      btn.classList.toggle("border-transparent", !active)
    })
  }

  updateUI() {
    const visibleCount = this.itemTargets.filter(i => !i.classList.contains("hidden")).length
    this.countTarget.textContent = String(visibleCount)
    this.emptyTarget.classList.toggle("hidden", visibleCount !== 0)

    const distillery = this.distilleryTarget.value
    const rating = this.ratingTarget.value
    const year = this.yearTarget.value
    const q = (this.queryTarget.value || "").trim()

    this.setChip(this.chipDistilleryTarget, this.chipDistilleryTextTarget, distillery ? `Distillery: ${distillery}` : "")
    this.setChip(this.chipRatingTarget, this.chipRatingTextTarget, rating ? `Rating: ${rating}+` : "")
    this.setChip(this.chipYearTarget, this.chipYearTextTarget, year ? `Year: ${year}` : "")

    // IMPORTANT: chips represent FILTERS ONLY (not search)
    const anyFiltersActive = Boolean(distillery || rating || year)
    this.chipsRowTarget.classList.toggle("hidden", !anyFiltersActive)

    // Clear-all should show if search OR filters are active
    const anyActive = Boolean(q || anyFiltersActive)
    this.clearAllTarget.classList.toggle("hidden", !anyActive)

    this.updateRefineLabel()
  }

  setChip(chipEl, textEl, text) {
    const show = Boolean(text)
    chipEl.classList.toggle("hidden", !show)
    if (show) textEl.textContent = text
  }

  updateRefineLabel() {
    const panelOpen = !this.refinePanelTarget.classList.contains("hidden")
    const distillery = this.distilleryTarget.value
    const rating = this.ratingTarget.value
    const year = this.yearTarget.value
    const active = [distillery, rating, year].filter(Boolean).length

    if (panelOpen) {
      this.refineLabelTarget.textContent = "Hide filters"
    } else {
      this.refineLabelTarget.textContent = active ? `Filters (${active})` : "Filters"
    }
  }
}


