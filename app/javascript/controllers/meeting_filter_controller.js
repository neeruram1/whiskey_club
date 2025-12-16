import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = [
    "item", "list",
    "query", "year", "status",
    "sortButton",
    "count", "empty",
    "chipsRow",
    "chipStatus", "chipStatusText",
    "chipYear", "chipYearText",
    "clearAll"
  ]

  connect() {
    this.currentSort = "date_desc"
    this.setActiveSort()
    this.applyAll({ animate: false })
  }

  filter(event) {
    const fromSearch = event?.target === this.queryTarget

    if (fromSearch) {
      // Search clears filters
      this.yearTarget.value = ""
      this.statusTarget.value = ""
      this.chipsRowTarget.classList.add("hidden")

      if (this._t) clearTimeout(this._t)
      this._t = setTimeout(() => {
        this.applyAll({ animate: false })
      }, 80)
      return
    }

    // Filter changes are immediate
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
    if (key === "year") this.yearTarget.value = ""
    if (key === "status") this.statusTarget.value = ""

    if (this._t) clearTimeout(this._t)
    this.applyAll({ animate: false })
  }

  clearAll() {
    this.queryTarget.value = ""
    this.yearTarget.value = ""
    this.statusTarget.value = ""

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
    const status = this.statusTarget.value

    // Filters win over search
    if ((year || status) && q) {
      this.queryTarget.value = ""
      q = ""
    }

    this.itemTargets.forEach(item => {
      const bottleName = (item.dataset.bottleName || "").toLowerCase()
      const distillery = (item.dataset.distillery || "").toLowerCase()
      const spiritGuide = (item.dataset.spiritGuide || "").toLowerCase()
      const text = `${bottleName} ${distillery} ${spiritGuide}`
      
      const itemYear = item.dataset.year
      const hasBottle = item.dataset.hasBottle === "true"
      const isPast = item.dataset.isPast === "true"
      const isUnrated = item.dataset.unrated === "true"

      const matchesQuery = !q || text.includes(q)
      const matchesYear = !year || itemYear === year
      
      let matchesStatus = true
      if (status === "has_bottle") matchesStatus = hasBottle
      else if (status === "no_bottle") matchesStatus = !hasBottle
      else if (status === "upcoming") matchesStatus = !isPast
      else if (status === "past") matchesStatus = isPast
      else if (status === "unrated") matchesStatus = isUnrated

      item.classList.toggle(
        "hidden",
        !(matchesQuery && matchesYear && matchesStatus)
      )
    })
  }

  applySort({ animate }) {
    const all = [...this.itemTargets]
    const visible = all.filter(i => !i.classList.contains("hidden"))
    const hidden = all.filter(i => i.classList.contains("hidden"))

    const dateNum = (el) => {
      const n = Number(el.dataset.date)
      return Number.isNaN(n) ? 0 : n
    }

    visible.sort((a, b) => {
      const ad = dateNum(a), bd = dateNum(b)

      switch (this.currentSort) {
        case "date_desc": return bd - ad
        case "date_asc": return ad - bd
        default: return 0
      }
    })

    const frag = document.createDocumentFragment()
    visible.forEach(i => frag.appendChild(i))
    hidden.forEach(i => frag.appendChild(i))
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

  updateUI() {
    const visibleCount = this.itemTargets.filter(i => !i.classList.contains("hidden")).length
    this.countTarget.textContent = String(visibleCount)
    this.emptyTarget.classList.toggle("hidden", visibleCount !== 0)

    const year = this.yearTarget.value
    const status = this.statusTarget.value
    const q = (this.queryTarget.value || "").trim()

    const statusLabels = { 
      "has_bottle": "With Bottle", 
      "no_bottle": "No Bottle", 
      "upcoming": "Upcoming",
      "past": "Past"
    }
    
    this.setChip(this.chipStatusTarget, this.chipStatusTextTarget, status ? statusLabels[status] : "")
    this.setChip(this.chipYearTarget, this.chipYearTextTarget, year ? `Year: ${year}` : "")

    const anyFiltersActive = Boolean(year || status)
    this.chipsRowTarget.classList.toggle("hidden", !anyFiltersActive)

    const anyActive = Boolean(q || anyFiltersActive)
    this.clearAllTarget.classList.toggle("hidden", !anyActive)
  }

  setChip(chipEl, textEl, text) {
    const show = Boolean(text)
    chipEl.classList.toggle("hidden", !show)
    if (show) textEl.textContent = text
  }
}
