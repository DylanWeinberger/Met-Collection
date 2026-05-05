import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["grid"]
  static values = { page: Number, query: String, departmentId: String }
  
  async loadMore() {
    const url = `/artworks/more?q=${this.queryValue}&page=${this.pageValue}`
    const response = await fetch(url)
    const html = await response.text()
    this.gridTarget.insertAdjacentHTML('beforeend', html)
    this.pageValue++
  }
}