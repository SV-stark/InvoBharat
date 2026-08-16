// ==========================================================================
// InvoBharat GitHub Pages Script (Interactive Elements & GST Simulator)
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
  initTheme();
  initMobileMenu();
  initShowcaseTabs();
  initGstSimulator();
});

/* --------------------------------------------------------------------------
   1. Theme Management (Light/Dark Mode)
   -------------------------------------------------------------------------- */
function initTheme() {
  const themeToggle = document.getElementById('theme-toggle');
  const htmlElement = document.documentElement;
  
  // Load saved theme or default to dark
  const savedTheme = localStorage.getItem('theme') || 'dark';
  htmlElement.setAttribute('data-theme', savedTheme);
  updateThemeIcon(savedTheme);

  themeToggle.addEventListener('click', () => {
    const currentTheme = htmlElement.getAttribute('data-theme');
    const newTheme = currentTheme === 'dark' ? 'light' : 'dark';
    
    htmlElement.setAttribute('data-theme', newTheme);
    localStorage.setItem('theme', newTheme);
    updateThemeIcon(newTheme);
  });
}

function updateThemeIcon(theme) {
  const themeIcon = document.querySelector('#theme-toggle i');
  if (theme === 'dark') {
    themeIcon.className = 'fa-solid fa-sun';
  } else {
    themeIcon.className = 'fa-solid fa-moon';
  }
}

/* --------------------------------------------------------------------------
   2. Mobile Menu (Hamburger)
   -------------------------------------------------------------------------- */
function initMobileMenu() {
  const menuToggle = document.getElementById('menu-toggle');
  const navMenu = document.querySelector('.nav-menu');
  const navLinks = document.querySelectorAll('.nav-link');

  menuToggle.addEventListener('click', () => {
    navMenu.classList.toggle('active');
    const icon = menuToggle.querySelector('i');
    if (navMenu.classList.contains('active')) {
      icon.className = 'fa-solid fa-xmark';
    } else {
      icon.className = 'fa-solid fa-bars';
    }
  });

  // Close menu when a link is clicked
  navLinks.forEach(link => {
    link.addEventListener('click', () => {
      navMenu.classList.remove('active');
      menuToggle.querySelector('i').className = 'fa-solid fa-bars';
    });
  });
}

/* --------------------------------------------------------------------------
   3. Showcase Tabs
   -------------------------------------------------------------------------- */
const slideTitles = {
  dashboard: 'Dashboard View (Windows Fluent Design)',
  editor: 'Invoice Editor (Fluent Form Controls)',
  pdf: 'Printed A4 PDF (Indian Formatting & QR Code)',
  mobile: 'Mobile Analytics Companion (Material 3 Theme)'
};

function initShowcaseTabs() {
  const tabButtons = document.querySelectorAll('.tab-btn');
  const slides = document.querySelectorAll('.showcase-slide');
  const windowTitle = document.getElementById('showcase-title');

  tabButtons.forEach(btn => {
    btn.addEventListener('click', () => {
      const targetTab = btn.getAttribute('data-tab');

      // Update active button state
      tabButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');

      // Update window title bar text
      if (windowTitle && slideTitles[targetTab]) {
        windowTitle.textContent = slideTitles[targetTab];
      }

      // Hide all slides and show selected with animation
      slides.forEach(slide => {
        slide.classList.remove('active');
        if (slide.id === `slide-${targetTab}`) {
          // Trigger reflow for transition
          slide.offsetHeight; 
          slide.classList.add('active');
        }
      });
    });
  });
}

/* --------------------------------------------------------------------------
   4. GST Billing & Words Simulator
   -------------------------------------------------------------------------- */
function initGstSimulator() {
  const subtotalInput = document.getElementById('sim-subtotal');
  const gstRateSelect = document.getElementById('sim-gst-rate');
  const isInterstateSelect = document.getElementById('sim-is-interstate');
  const senderStateSelect = document.getElementById('sim-sender-state');
  const receiverStateSelect = document.getElementById('sim-receiver-state');

  // Event Listeners for Live updates
  subtotalInput.addEventListener('input', runCalculations);
  gstRateSelect.addEventListener('change', runCalculations);
  
  isInterstateSelect.addEventListener('change', (e) => {
    const isInterstate = e.target.value === 'true';
    if (isInterstate) {
      // Force different states if inter-state is selected
      if (senderStateSelect.value === receiverStateSelect.value) {
        // change receiver to Karnataka (29) if seller is Maharashtra (27)
        if (senderStateSelect.value === '27') {
          receiverStateSelect.value = '29';
        } else {
          receiverStateSelect.value = '27';
        }
      }
    } else {
      // Force same states if intra-state is selected
      receiverStateSelect.value = senderStateSelect.value;
    }
    runCalculations();
  });

  senderStateSelect.addEventListener('change', () => {
    updateInterstateDropdown();
    runCalculations();
  });

  receiverStateSelect.addEventListener('change', () => {
    updateInterstateDropdown();
    runCalculations();
  });

  // Initial calculation run
  runCalculations();
}

function updateInterstateDropdown() {
  const senderState = document.getElementById('sim-sender-state').value;
  const receiverState = document.getElementById('sim-receiver-state').value;
  const isInterstateSelect = document.getElementById('sim-is-interstate');
  
  if (senderState === receiverState) {
    isInterstateSelect.value = 'false';
  } else {
    isInterstateSelect.value = 'true';
  }
}

// Helpers for quick preset amounts
window.setSimAmount = function(amount) {
  const subtotalInput = document.getElementById('sim-subtotal');
  if (subtotalInput) {
    subtotalInput.value = amount;
    runCalculations();
  }
};

function formatIndianCurrency(amount) {
  // Use Indian number grouping standard
  return new Intl.NumberFormat('en-IN', {
    style: 'currency',
    currency: 'INR',
    minimumFractionDigits: 2
  }).format(amount);
}

function runCalculations() {
  const subtotal = parseFloat(document.getElementById('sim-subtotal').value) || 0;
  const gstRate = parseFloat(document.getElementById('sim-gst-rate').value) || 0;
  const senderStateSelect = document.getElementById('sim-sender-state');
  const receiverStateSelect = document.getElementById('sim-receiver-state');
  
  const senderCode = senderStateSelect.value;
  const receiverCode = receiverStateSelect.value;
  const isInterstate = senderCode !== receiverCode;

  const senderName = senderStateSelect.options[senderStateSelect.selectedIndex].text;
  const receiverName = receiverStateSelect.options[receiverStateSelect.selectedIndex].text;

  // Calculators
  const gstAmount = subtotal * (gstRate / 100);
  const total = subtotal + gstAmount;

  // Display fields
  const displaySupplyType = document.getElementById('display-supply-type');
  const displayGstLogic = document.getElementById('display-gst-logic');
  const displaySubtotal = document.getElementById('display-subtotal');
  const displayTotal = document.getElementById('display-total');
  const displayWords = document.getElementById('display-words');

  // Formatted Subtotal & Total
  displaySubtotal.textContent = formatIndianCurrency(subtotal);
  displayTotal.textContent = formatIndianCurrency(total);

  // Setup splitting columns
  const cgstRow = document.getElementById('cgst-row');
  const sgstRow = document.getElementById('sgst-row');
  const igstRow = document.getElementById('igst-row');

  if (isInterstate) {
    displaySupplyType.textContent = 'Inter-State (IGST)';
    displaySupplyType.className = 'text-gradient';
    displayGstLogic.textContent = `Seller in ${senderName.split(' ')[0]} and Client in ${receiverName.split(' ')[0]} differ.`;
    
    cgstRow.classList.add('hidden');
    sgstRow.classList.add('hidden');
    igstRow.classList.remove('hidden');

    document.getElementById('igst-label').textContent = `IGST (${gstRate}%):`;
    document.getElementById('display-igst').textContent = formatIndianCurrency(gstAmount);
  } else {
    displaySupplyType.textContent = 'Intra-State (CGST + SGST)';
    displaySupplyType.className = 'text-gradient-teal';
    displayGstLogic.textContent = `Seller and Client are both located in ${senderName.split(' ')[0]}.`;

    cgstRow.classList.remove('hidden');
    sgstRow.classList.remove('hidden');
    igstRow.classList.add('hidden');

    const halfRate = gstRate / 2;
    const halfGstAmount = gstAmount / 2;

    document.getElementById('cgst-label').textContent = `CGST (${halfRate}%):`;
    document.getElementById('display-cgst').textContent = formatIndianCurrency(halfGstAmount);
    
    document.getElementById('sgst-label').textContent = `SGST (${halfRate}%):`;
    document.getElementById('display-sgst').textContent = formatIndianCurrency(halfGstAmount);
  }

  // Update words conversion
  displayWords.textContent = convertNumberToWords(total);
}

/* --------------------------------------------------------------------------
   5. Indian Standard Number-to-Words Algorithm (Lakhs & Crores)
   -------------------------------------------------------------------------- */
function convertNumberToWords(amount) {
  if (amount === 0) return 'Rupees Zero Only';

  const parts = amount.toFixed(2).split('.');
  const rupees = parseInt(parts[0], 10);
  const paise = parseInt(parts[1], 10);

  let rupeeWords = '';
  if (rupees > 0) {
    rupeeWords = convertIndianNumberToWords(rupees) + ' Rupees';
  }

  let paiseWords = '';
  if (paise > 0) {
    paiseWords = convertIndianNumberToWords(paise) + ' Paise';
  }

  let finalWords = '';
  if (rupeeWords && paiseWords) {
    finalWords = rupeeWords + ' and ' + paiseWords + ' Only';
  } else if (rupeeWords) {
    finalWords = rupeeWords + ' Only';
  } else if (paiseWords) {
    finalWords = paiseWords + ' Only';
  } else {
    finalWords = 'Rupees Zero Only';
  }

  return finalWords;
}

function convertIndianNumberToWords(num) {
  const ones = [
    '', 'One', 'Two', 'Three', 'Four', 'Five', 'Six', 'Seven', 'Eight', 'Nine',
    'Ten', 'Eleven', 'Twelve', 'Thirteen', 'Fourteen', 'Fifteen', 'Sixteen',
    'Seventeen', 'Eighteen', 'Nineteen'
  ];

  const tens = [
    '', '', 'Twenty', 'Thirty', 'Forty', 'Fifty', 'Sixty', 'Seventy', 'Eighty', 'Ninety'
  ];

  if (num === 0) return 'Zero';

  function helper(n) {
    let str = '';
    if (n >= 100) {
      str += ones[Math.floor(n / 100)] + ' Hundred ';
      n %= 100;
    }
    if (n >= 20) {
      str += tens[Math.floor(n / 10)] + ' ';
      n %= 10;
    }
    if (n > 0) {
      str += ones[n] + ' ';
    }
    return str.trim();
  }

  let wordResult = '';
  
  // Crores (1,00,00,000)
  if (num >= 10000000) {
    wordResult += helper(Math.floor(num / 10000000)) + ' Crore ';
    num %= 10000000;
  }

  // Lakhs (1,00,000)
  if (num >= 100000) {
    wordResult += helper(Math.floor(num / 100000)) + ' Lakh ';
    num %= 100000;
  }

  // Thousands (1,000)
  if (num >= 1000) {
    wordResult += helper(Math.floor(num / 1000)) + ' Thousand ';
    num %= 1000;
  }

  // Under Thousand
  if (num > 0) {
    wordResult += helper(num);
  }

  return wordResult.trim();
}

/* --------------------------------------------------------------------------
   6. Copy Setup Commands Button Helper
   -------------------------------------------------------------------------- */
window.copyCode = function() {
  const codeBlock = document.getElementById('dev-commands');
  const copyBtn = document.getElementById('copy-code-btn');
  
  if (codeBlock && copyBtn) {
    navigator.clipboard.writeText(codeBlock.innerText).then(() => {
      copyBtn.innerHTML = '<i class="fa-solid fa-check"></i> Copied!';
      setTimeout(() => {
        copyBtn.innerHTML = '<i class="fa-regular fa-copy"></i> Copy';
      }, 2000);
    }).catch(err => {
      console.error('Failed to copy code: ', err);
    });
  }
};
