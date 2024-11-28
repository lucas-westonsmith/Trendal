document.addEventListener('DOMContentLoaded', () => {
  const dropdown = document.getElementById('dropdown');
  const optionsList = document.getElementById('options_list');
  const selectedValue = document.getElementById('selected_value');
  const selectedOption = document.getElementById('selected_option');

  dropdown.addEventListener('click', () => {
    optionsList.style.display = optionsList.style.display === 'block' ? 'none' : 'block';
  });

  document.querySelectorAll('.option-item').forEach(option => {
    option.addEventListener('click', function () {
      selectedValue.value = this.getAttribute('data-value');
      selectedOption.textContent = this.textContent;
      optionsList.style.display = 'none';
    });
  });

  document.addEventListener('click', (e) => {
    if (!dropdown.contains(e.target)) {
      optionsList.style.display = 'none';
    }
  });
});
