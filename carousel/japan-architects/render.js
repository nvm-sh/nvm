// Renders each .slide of carousel.html to slides/NN.png (1818×2000)
const { chromium } = require('playwright');
const path = require('path');
(async () => {
  const browser = await chromium.launch();
  const page = await browser.newPage({ viewport: { width: 1900, height: 2100 } });
  await page.goto('file://' + path.join(__dirname, 'carousel.html'));
  await page.evaluate(() => document.fonts.ready);
  await page.evaluate(() => window.__ready);
  await page.waitForTimeout(800);
  const slides = await page.$$('.slide');
  for (let i = 0; i < slides.length; i++) {
    await slides[i].screenshot({ path: path.join(__dirname, 'slides', String(i + 1).padStart(2, '0') + '.png') });
  }
  await browser.close();
})();
