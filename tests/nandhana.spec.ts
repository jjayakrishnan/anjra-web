import { test, expect } from '@playwright/test';

test.use({ actionTimeout: 20000, navigationTimeout: 30000 });
test.setTimeout(60000);

test('Nandhana Login and Check Features', async ({ page }) => {
    // Navigate to Vercel Server
    await page.goto('https://anjra.vercel.app');
    await page.waitForLoadState('load');

    // Wait for Flutter Web engine to initialize and mount the Canvas
    await page.waitForTimeout(10000);
    await page.waitForTimeout(5000);

    // Screenshot initial state
    await page.screenshot({ path: 'test-results/nandhana-1-initial.png' });

    // Kid mode is default. Tab to Username
    // With recent accessibility changes, the first focusable elements are the toggles.
    await page.keyboard.press('Tab'); // Focuses "I'm a Kid" toggle
    await page.keyboard.press('Tab'); // Focuses "I'm a Parent" toggle
    await page.keyboard.press('Tab'); // Focuses "Username" field
    await page.keyboard.type('nandhana', { delay: 100 });

    // PIN field
    await page.keyboard.press('Tab');
    await page.keyboard.type('2020', { delay: 100 });

    await page.screenshot({ path: 'test-results/nandhana-2-credentials.png' });

    // Login button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    console.log("Submitted kid login. Waiting for dashboard...");
    await page.waitForTimeout(5000);

    // Now we should be on the dashboard page
    await page.screenshot({ path: 'test-results/nandhana-3-dashboard.png' });

    // Tab order for kid dashboard? Let's assume there are tabs for "Receive" or "Send"
    // Print out page structure or just screenshot
    // Wait for transaction history to load
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'test-results/nandhana-4-dashboard-history.png' });
});
