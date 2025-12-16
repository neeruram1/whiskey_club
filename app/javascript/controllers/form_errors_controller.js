import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = { errorId: String }

  clearError(event) {
    const field = event.currentTarget
    const errorId = event.params.errorId
    
    // Remove error styling from the field
    field.classList.remove('border-red-500', 'bg-red-50')
    field.classList.add('border-lagavulin-green/30', 'bg-white')
    
    // Remove the error message by ID
    const errorMessage = document.getElementById(errorId)
    if (errorMessage) {
      errorMessage.remove()
    }
  }
}
