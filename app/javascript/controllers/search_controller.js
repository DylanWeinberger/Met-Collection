import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  showLoader() {
    const loader = document.getElementById('page-loader')
    if (loader) {
      loader.classList.remove('hide');
    }
  }
}