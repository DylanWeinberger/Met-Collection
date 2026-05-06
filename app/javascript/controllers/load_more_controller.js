import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid", "button"]
  static values = { page: Number, query: String, departmentId: String }
  
  async loadMore() {
    const url = `/artworks/more?q=${this.queryValue}&page=${this.pageValue}`
    let html = null
    try {
        this.buttonTarget.disabled = true
        this.buttonTarget.textContent = "Loading..."
        const response = await fetch(url)
        html = await response.text()
    } catch(error) {
      console.error("Failed to load more artworks:", error)
      return
    } finally {
        this.buttonTarget.disabled = false
        this.buttonTarget.textContent = "Load More"    
    }
    if (html.trim() === "") {
      this.buttonTarget.hidden = true
      return
    }
    this.gridTarget.insertAdjacentHTML('beforeend', html)
    this.pageValue++
  }
}