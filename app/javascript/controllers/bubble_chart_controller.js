// app/javascript/controllers/bubble_chart_controller.js
import { Controller } from "stimulus";

export default class extends Controller {
  static targets = ['chart'];

  connect() {
    // Remplacer cet exemple par les données réelles venant du backend
    this.data = [
      { country: 'USA', posts: 100, color: 'rgba(66, 133, 244, 0.8)' },
      { country: 'Canada', posts: 50, color: 'rgba(219, 68, 55, 0.8)' },
      { country: 'UK', posts: 75, color: 'rgba(244, 180, 0, 0.8)' },
      { country: 'Australia', posts: 80, color: 'rgba(15, 157, 88, 0.8)' },
      { country: 'Germany', posts: 60, color: 'rgba(219, 68, 55, 0.8)' }
    ];

    this.renderBubbles();
  }

  renderBubbles() {
    // Supprime les bulles existantes avant de redessiner
    this.chartTarget.innerHTML = '';

    this.data.forEach(item => {
      const bubble = document.createElement('div');
      bubble.classList.add('bubble');

      const size = Math.max(40, item.posts); // Utilise le nombre de posts pour définir la taille de la bulle
      bubble.style.width = `${size}px`;
      bubble.style.height = `${size}px`;
      bubble.style.backgroundColor = item.color;

      // Positionnement aléatoire des bulles dans le conteneur
      const x = Math.random() * (this.chartTarget.clientWidth - size);
      const y = Math.random() * (this.chartTarget.clientHeight - size);
      bubble.style.left = `${x}px`;
      bubble.style.top = `${y}px`;

      // Tooltip pour afficher les informations sur la bulle
      const tooltip = document.createElement('div');
      tooltip.classList.add('tooltip');
      tooltip.textContent = `${item.country}: ${item.posts} posts`;
      bubble.appendChild(tooltip);

      this.chartTarget.appendChild(bubble);
    });
  }
}
