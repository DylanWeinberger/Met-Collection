# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "photoswipe", to: "https://cdn.jsdelivr.net/npm/photoswipe/dist/photoswipe.esm.js"
pin "page_loader", to: "page_loader.js"
pin_all_from "app/javascript/controllers", under: "controllers"
