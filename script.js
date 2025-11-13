// Hidden referral code - this will be used internally but not displayed
const HIDDEN_REFERRAL_CODE = 'CC398';
const ORIGINAL_URL = 'https://CC398.pecv3595.net/';

// Function to redirect to login page
function redirectToLogin() {
  try {
    // In a real implementation, you would redirect to the actual login page
    // For demo purposes, we'll show an alert
    window.location.href = ORIGINAL_URL + 'login';
  } catch (error) {
    console.error('Redirect error:', error);
    // Fallback for older browsers
    window.location.replace(ORIGINAL_URL + 'login');
  }
}

// Function to redirect to register page
function redirectToRegister() {
  try {
    // Redirect to the register page while maintaining the referral code internally
    window.location.href = 'register.html';
  } catch (error) {
    console.error('Redirect error:', error);
    // Fallback for older browsers
    window.location.replace('register.html');
  }
}

// Make functions globally available
window.redirectToRegister = redirectToRegister;
window.redirectToLogin = redirectToLogin;

// Function to go back
function goBack() {
  window.location.href = 'index.html';
}

// Function to toggle password visibility
function togglePassword() {
  const passwordInput = document.getElementById('password');
  const eyeBtn = document.querySelector('.eye-btn svg');
  
  if (passwordInput.type === 'password') {
    passwordInput.type = 'text';
    eyeBtn.innerHTML = `
      <path d="M17.94 17.94A10.07 10.07 0 0 1 12 20C7 20 2.73 16.39 1 12A18.45 18.45 0 0 1 5.06 5.06L17.94 17.94Z" stroke="#666" stroke-width="2"/>
      <path d="M9.9 4.24A9.12 9.12 0 0 1 12 4C17 4 21.27 7.61 23 12A18.5 18.5 0 0 1 19.42 16.42" stroke="#666" stroke-width="2"/>
      <path d="M1 1L23 23" stroke="#666" stroke-width="2"/>
      <path d="M10.5 10.5A2 2 0 0 1 13.5 13.5" stroke="#666" stroke-width="2"/>
    `;
  } else {
    passwordInput.type = 'password';
    eyeBtn.innerHTML = `
      <path d="M1 12S5 4 12 4S23 12 23 12S19 20 12 20S1 12 1 12Z" stroke="#666" stroke-width="2"/>
      <circle cx="12" cy="12" r="3" stroke="#666" stroke-width="2"/>
    `;
  }
}

// Function to handle registration form submission
function handleRegister(event) {
  event.preventDefault();
  
  try {
    // Get form data
    const formData = new FormData(event.target);
    const username = document.getElementById('username-input').value.trim();
    const password = document.getElementById('password').value.trim();
    const nickname = document.getElementById('confirm-password').value.trim();
    const mobile = document.getElementById('mobile').value.trim();
    
    // Validate form
    if (!username || !password || !nickname || !mobile) {
      showAlert('กรุณากรอกข้อมูลให้ครบถ้วน');
      return;
    }
    
    // Check username format (4-10 characters, alphanumeric)
    if (!/^[a-zA-Z0-9]{4,10}$/.test(username)) {
      showAlert('ยูสเซอร์เนมต้องเป็นตัวอักษรหรือตัวเลข 4-10 ตัว');
      return;
    }
    
    // Check password format (6-10 characters, alphanumeric)
    if (!/^[a-zA-Z0-9]{6,10}$/.test(password)) {
      showAlert('รหัสผ่านต้องเป็นตัวอักษรหรือตัวเลข 6-10 ตัว');
      return;
    }
    
    // Check nickname length (max 8 characters)
    if (nickname.length > 8) {
      showAlert('ชื่อเล่นต้องไม่เกิน 8 ตัวอักษร');
      return;
    }
    
    // Check mobile format (10 digits)
    if (!/^[0-9]{10}$/.test(mobile)) {
      showAlert('เบอร์มือถือต้องเป็นตัวเลข 10 หลัก');
      return;
    }
    
    // Prepare registration data with hidden referral code
    const registrationData = {
      referralCode: HIDDEN_REFERRAL_CODE, // This is hidden from the user but included in the data
      username: username,
      password: password,
      nickname: nickname,
      mobile: mobile
    };
    
    // In a real implementation, you would send this data to your server
    console.log('Registration data:', registrationData);
    
    // For demo purposes, redirect to the original URL with the registration data
    const params = new URLSearchParams({
      action: 'register',
      ref: HIDDEN_REFERRAL_CODE,
      username: username
    });
    
    // Redirect to original site with hidden referral code
    const targetUrl = ORIGINAL_URL + 'register?' + params.toString();
    
    // Use different redirect methods for better cross-platform compatibility
    if (window.location.replace) {
      window.location.replace(targetUrl);
    } else {
      window.location.href = targetUrl;
    }
    
  } catch (error) {
    console.error('Registration error:', error);
    showAlert('เกิดข้อผิดพลาด กรุณาลองใหม่อีกครั้ง');
  }
}

// Cross-platform alert function
function showAlert(message) {
  if (typeof alert !== 'undefined') {
    alert(message);
  } else {
    // Fallback for environments without alert
    console.warn(message);
  }
}

// Function to handle OTP request
document.addEventListener('DOMContentLoaded', function() {
  const otpBtn = document.querySelector('.otp-btn');
  if (otpBtn) {
    otpBtn.addEventListener('click', function() {
      const mobileInput = document.getElementById('mobile');
      const mobile = mobileInput.value;
      
      if (!/^[0-9]{10}$/.test(mobile)) {
        alert('กรุณากรอกเบอร์มือถือให้ถูกต้อง (10 หลัก)');
        return;
      }
      
      // Simulate OTP request
      this.disabled = true;
      this.textContent = 'กำลังส่ง...';
      
      setTimeout(() => {
        this.textContent = 'ส่งแล้ว';
        setTimeout(() => {
          this.disabled = false;
          this.textContent = 'รับ OTP';
        }, 3000);
      }, 2000);
    });
  }
});

// Function to create a clean URL that hides the referral code
function createCleanUrl() {
  // This function can be used to generate clean URLs that don't show the referral code
  // but still maintain it internally
  return window.location.origin + window.location.pathname;
}

// Cross-platform initialization
function initializePage() {
  try {
    // Hide the referral code from the URL if it's visible
    if (window.location.search.includes('ref=') || window.location.search.includes('CC398')) {
      const cleanUrl = createCleanUrl();
      if (window.history && window.history.replaceState) {
        window.history.replaceState({}, document.title, cleanUrl);
      }
    }
    
    // Add touch event listeners for better mobile experience
    addTouchSupport();
    
    // Prevent zoom on iOS when focusing inputs
    preventIOSZoom();
    
  } catch (error) {
    console.error('Initialization error:', error);
  }
}

// Add touch support for better mobile experience
function addTouchSupport() {
  const buttons = document.querySelectorAll('button, .primary-btn, .secondary-btn');
  buttons.forEach(button => {
    // Add touch start/end events for better responsiveness
    button.addEventListener('touchstart', function() {
      this.style.opacity = '0.8';
    }, { passive: true });
    
    button.addEventListener('touchend', function() {
      this.style.opacity = '1';
    }, { passive: true });
  });
}

// Prevent iOS zoom when focusing on inputs
function preventIOSZoom() {
  if (/iPad|iPhone|iPod/.test(navigator.userAgent)) {
    const inputs = document.querySelectorAll('input');
    inputs.forEach(input => {
      input.addEventListener('focus', function() {
        this.style.fontSize = '16px';
      });
    });
  }
}

// Initialize the page with multiple fallbacks
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializePage);
} else {
  initializePage();
}

// Additional fallback for older browsers
if (window.addEventListener) {
  window.addEventListener('load', initializePage);
} else if (window.attachEvent) {
  window.attachEvent('onload', initializePage);
}
