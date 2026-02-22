import { test, expect } from '@playwright/test';

test.use({ actionTimeout: 10000, navigationTimeout: 15000 });

test.describe('Anjra App Authentication & Dashboard Flows', () => {

  test('Parent Login and Send Money (via Autocomplete) Web Test', async ({ page }) => {
    // 1. Navigate to local Flutter Web server
    await page.goto('http://localhost:8080');
    await page.waitForLoadState('load');

    // Wait for Flutter glass pane to appear
    await page.waitForSelector('flt-glass-pane', { state: 'attached', timeout: 10000 });
    // Add wait to ensure Flutter has fully booted
    await page.waitForTimeout(5000);

    // 2. Perform Login via keyboard navigation (Flutter Web support)
    // Email field
    await page.keyboard.press('Tab');
    await page.keyboard.type('evergreenjk@gmail.com', { delay: 100 });

    // Password field
    await page.keyboard.press('Tab');
    await page.keyboard.type('test123', { delay: 100 });

    // Login button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    console.log("Submitted login. Waiting for dashboard...");
    await page.waitForTimeout(5000);

    // Now we should be on the dashboard page.
    await page.screenshot({ path: 'test-results/dashboard-web.png' });

    // Assuming Tab order: 'Admin Panel', 'Add Kid', 'Send', 'Receive'
    // This part is very dependent on the exact layout, but let's press tab to find 'Send'
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab'); // This might be Send
    await page.keyboard.press('Enter');

    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/send-money-web.png' });

    // Try to type in the username field
    await page.keyboard.press('Tab');
    await page.keyboard.type('testkid', { delay: 100 });

    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/send-money-search.png' });

    // Press down to select the first autocomplete suggestion
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');

    // Tab to amount
    await page.keyboard.press('Tab');
    await page.keyboard.type('50', { delay: 100 });

    // Send button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    await page.waitForTimeout(3000);
    await page.screenshot({ path: 'test-results/send-money-success.png' });
  });

});

