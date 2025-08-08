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
    
    // Wait for iframe to load, then inject auto-login script
    iframe.onload = function() {
        console.log('📄 Iframe loaded, attempting auto-login...');
        
        // Create a script to inject into the iframe
        const autoLoginScript = `
            setTimeout(() => {
                // Step 1: Find the "memid" input and type "123"
                const input = document.querySelector('input[name="memid"]');
                if (input) {
                    input.value = '123';
                    input.dispatchEvent(new Event('input', { bubbles: true }));
                    console.log('✅ Filled memid with 123');
                } else {
                    console.warn('⚠️ Could not find input[name="memid"]');
                }

                // Step 2: Click the submit button
                const button = document.querySelector('button[type="submit"]');
                if (button) {
                    button.click();
                    console.log('✅ Clicked submit button');
                } else {
                    console.warn('⚠️ Could not find submit button');
                }
            }, 2000);
        `;
        
        try {
            // Try to execute script in iframe context
            iframe.contentWindow.eval(autoLoginScript);
            console.log('✅ Auto-login script injected successfully');
        } catch (error) {
            console.warn('⚠️ Cannot inject script due to cross-origin restrictions');
            console.log('🔄 Alternative: Trying to modify iframe src with auto-submit');
            
            // Alternative approach: Add auto-submit parameters to URL
            setTimeout(() => {
                const originalSrc = iframe.src;
                iframe.src = originalSrc + '?autoLogin=true';
            }, 2000);
        }
    };
    
}, 1530);