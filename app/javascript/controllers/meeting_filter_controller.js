import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item", "list", "query", "year", "count", "empty", "clearAll"]

  connect() {
    // default sort: newest first (matches the vibe)
    this.sortByDateDesc()
    this.updateUI()
  }

  filter() {
    clearTimeout(this._t)
    this._t = setTimeout(() => {
      this.applyFilter()
      this.sortByDateDesc()
      this.updateUI()
    }, 80)
  }

  clearAll() {
    this.queryTarget.value = ""
    this.yearTarget.value = ""
    if (this._t) clearTimeout(this._t)

    this.applyFilter()
    this.sortByDateDesc()
    this.updateUI()
  }

  applyFilter() {
    const q = (this.queryTarget.value || "").trim().toLowerCase()
    const year = this.yearTarget.value

    this.itemTargets.forEach(item => {
      const host = (item.dataset.host || "").toLowerCase()
      const matchesQuery = !q || host.includes(q)
      const matchesYear = !year || item.dataset.year === year

      item.classList.toggle("hidden", !(matchesQuery && matchesYear))
    })
  }

  sortByDateDesc() {
    const all = [...this.itemTargets]
    const visible = all.filter(i => !i.classList.contains("hidden"))
    const hidden = all.filter(i => i.classList.contains("hidden"))

    visible.sort((a, b) => Number(b.dataset.date) - Number(a.dataset.date))

    const frag = document.createDocumentFragment()
    visible.forEach(i => frag.appendChild(i))
    hidden.forEach(i => frag.appendChild(i))
    this.listTarget.appendChild(frag)
  }

  updateUI() {
    const visibleCount = this.itemTargets.filter(i => !i.classList.contains("hidden")).length
    this.countTarget.textContent = String(visibleCount)
    this.emptyTarget.classList.toggle("hidden", visibleCount !== 0)

    const anyActive = Boolean(
      (this.queryTarget.value || "").trim() ||
      this.yearTarget.value
    )
    this.clearAllTarget.classList.toggle("hidden", !anyActive)
  }
}
