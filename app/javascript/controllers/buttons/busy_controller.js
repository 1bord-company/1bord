import { Controller } from "@hotwired/stimulus"

// Connects to data-controller="buttons--busy"
export default class extends Controller {
  busy = () => this.element.setAttribute("aria-busy", true)
}
