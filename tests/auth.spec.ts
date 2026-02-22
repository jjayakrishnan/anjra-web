import { test, expect } from '@playwright/test';

test.use({ actionTimeout: 10000, navigationTimeout: 15000 });

test.describe('Anjra App Authentication & Dashboard Flows', () => {

  test('Parent Login and Send Money Web Test', async ({ page }) => {
    // 1. Navigate to local Flutter Web server
    await page.goto('http://localhost:8085');
    await page.waitForLoadState('load');

    // Wait for Flutter Web engine to initialize and mount the Canvas
    await page.waitForTimeout(10000);
    await page.waitForTimeout(5000);

    // Switch to Parent mode toggle
    await page.keyboard.press('Tab');
    await page.keyboard.press('ArrowRight'); // Usually switches the toggle
    await page.keyboard.press('Enter');

    // Email field
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.type('evergreenjk@gmail.com', { delay: 100 });

    // Password field
    await page.keyboard.press('Tab');
    await page.keyboard.type('test1234', { delay: 100 });

    // Login button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    console.log("Submitted login. Waiting for dashboard...");
    await page.waitForTimeout(5000);

    // Now we should be on the dashboard page.
    await page.screenshot({ path: 'test-results/dashboard-web.png' });

    // Assuming Tab order: 'Admin Panel', 'Add Kid', 'Send', 'Receive'
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab'); // 'Send'
    await page.keyboard.press('Enter');

    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/send-money-web.png' });

    // Autocomplete field
    await page.keyboard.press('Tab');
    await page.keyboard.type('Kid 1', { delay: 100 });

    await page.waitForTimeout(2000);

    // Press down to select the first autocomplete suggestion
    await page.keyboard.press('ArrowDown');
    await page.keyboard.press('Enter');

    // Tab to amount
    await page.keyboard.press('Tab');
    await page.keyboard.type('5.00', { delay: 100 });

    // Note field
    await page.keyboard.press('Tab');
    await page.keyboard.type('Playwright automated test', { delay: 100 });

    // Send button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    // Wait for transfer and reload dashboard
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'test-results/dashboard-after-send-web.png' });
  });

  test('Kid Login and View Transactions Web Test', async ({ page }) => {
    // 1. Navigate to local Flutter Web server
    await page.goto('http://localhost:8085');
    await page.waitForLoadState('load');

    // Wait for Flutter Web engine to initialize and mount the Canvas
    await page.waitForTimeout(10000);
    await page.waitForTimeout(5000);

    // Kid mode is default. Tab to Username
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.type('lakshan', { delay: 100 });

    // PIN field
    await page.keyboard.press('Tab');
    await page.keyboard.type('1234', { delay: 100 });

    // Login button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    console.log("Submitted kid login. Waiting for dashboard...");
    await page.waitForTimeout(5000);

    // Now we should be on the dashboard page, scroll down or wait to verify transactions load
    await page.screenshot({ path: 'test-results/kid-dashboard-web.png' });

    // Additional wait to ensure transactions are completely visible
    await page.waitForTimeout(2000);
    await page.screenshot({ path: 'test-results/kid-transaction-history.png' });
  });

});

