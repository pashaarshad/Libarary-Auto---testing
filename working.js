setTimeout(() => {
  // Step 1: Find the "memid" input and type "123"
  const input = document.querySelector('input[name="memid"]');
  if (input) {
    input.value = '123';
    input.dispatchEvent(new Event('input', { bubbles: true })); // Tell Angular/React that the value changed
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
}, 2000); // Wait 2 seconds for the form to load
