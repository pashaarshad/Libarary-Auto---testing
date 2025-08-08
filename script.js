// Ensure text color adapts to the background gradient
const textElements = document.querySelectorAll('.welcome-text, .kiosk-text, .designed-by');
let colorIndex = 0;
const colors = ['white', 'black'];

function updateTextColor() {
    colorIndex = (colorIndex + 1) % colors.length;
    textElements.forEach(el => el.style.color = colors[colorIndex]);
}

// Change text color every 3 seconds
setInterval(updateTextColor, 1000);

// Show iframe after 10 seconds
setTimeout(() => {
    const loader = document.querySelector('.loader');
    const iframe = document.getElementById('kiosk-frame');
    
    // Hide the loader
    loader.style.display = 'none';
    
    // Show the iframe
    iframe.style.display = 'block';
}, 1530);