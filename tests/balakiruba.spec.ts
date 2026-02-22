import { test, expect } from '@playwright/test';

test.use({ actionTimeout: 20000, navigationTimeout: 30000 });

test('Debug balakiruba@gmail.com Login', async ({ page }) => {
    await page.goto('https://anjra.vercel.app');
    await page.waitForLoadState('load');

    await page.waitForTimeout(10000);
    await page.screenshot({ path: 'test-results/bala-1-initial.png' });

    // Switch to Parent mode toggle
    await page.keyboard.press('Tab');
    await page.keyboard.press('ArrowRight');
    await page.keyboard.press('Enter');

    await page.waitForTimeout(1000);
    await page.screenshot({ path: 'test-results/bala-2-parent-mode.png' });

    // Email field
    await page.keyboard.press('Tab');
    await page.keyboard.press('Tab');
    await page.keyboard.type('balakiruba@gmail.com', { delay: 100 });

    // Password field
    await page.keyboard.press('Tab');
    await page.keyboard.type('123456', { delay: 100 });
    await page.screenshot({ path: 'test-results/bala-3-filled-credentials.png' });

    // Login button
    await page.keyboard.press('Tab');
    await page.keyboard.press('Enter');

    console.log("Submitted login. Waiting 5s...");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'test-results/bala-4-after-login-5s.png' });

    console.log("Waiting another 5s...");
    await page.waitForTimeout(5000);
    await page.screenshot({ path: 'test-results/bala-5-after-login-10s.png' });
});
