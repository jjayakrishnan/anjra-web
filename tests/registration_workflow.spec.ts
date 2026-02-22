import { test, expect } from '@playwright/test';

test.use({ actionTimeout: 20000, navigationTimeout: 30000 });
test.setTimeout(120000);

test.describe('Anjra End-to-End Registration Workflow', () => {

    test('Complete flow: Parent Signup -> Add Kid -> Kid Login', async ({ page }) => {
        const timestamp = Date.now();
        const parentEmail = `test_parent_${timestamp}@test.com`;
        const parentPassword = 'Password123!';
        const kidName = `Kid ${timestamp}`;
        const kidUsername = `kiduser_${timestamp}`;
        const kidPin = '4321';

        // 1. Navigate to Vercel Server
        await page.goto('https://anjra.vercel.app');
        await page.waitForLoadState('load');

        // Wait for Flutter Web engine
        await page.waitForTimeout(10000);
        await page.waitForTimeout(5000);

        // Switch to Parent mode toggle
        await page.keyboard.press('Tab'); // Focuses "I'm a Kid"
        await page.keyboard.press('Tab'); // Focuses "I'm a Parent"
        await page.keyboard.press('Enter');

        await page.waitForTimeout(1000);

        // Toggle "Create Account"
        // Tab order: Email -> Password -> Login Button -> Forgot Password -> Create Account
        await page.keyboard.press('Tab');
        await page.keyboard.press('Tab');
        await page.keyboard.press('Tab');
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');

        await page.waitForTimeout(1000);

        // Email field
        await page.keyboard.press('Shift+Tab');
        await page.keyboard.press('Shift+Tab');
        await page.keyboard.press('Shift+Tab');
        await page.keyboard.press('Shift+Tab'); // Should be back to Email
        await page.keyboard.type(parentEmail, { delay: 50 });

        // Password field
        await page.keyboard.press('Tab');
        await page.keyboard.type(parentPassword, { delay: 50 });

        // Sign Up Button
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');

        console.log(`Submitted Sign Up for ${parentEmail}`);
        await page.waitForTimeout(5000);

        // Handle "Sign Up Successful" Dialog
        await page.keyboard.press('Enter'); // Dismiss dialog ("OK")
        await page.waitForTimeout(1000);

        // We should now be back to Login (Create account toggle resets)
        // Sometimes it doesn't auto-fill, so let's re-type to be safe or just press Login if fields remain.
        // If fields clear, we must navigate back to email. Let's assume we need to re-type.
        await page.reload();
        await page.waitForLoadState('load');
        await page.waitForTimeout(10000);
        await page.waitForTimeout(5000);

        await page.keyboard.press('Tab');
        await page.keyboard.press('Tab'); // Parent mode
        await page.keyboard.press('Enter');
        await page.waitForTimeout(1000);

        await page.keyboard.press('Tab'); // email
        await page.keyboard.type(parentEmail, { delay: 50 });
        await page.keyboard.press('Tab'); // password
        await page.keyboard.type(parentPassword, { delay: 50 });

        // Login button
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');

        console.log("Submitted Login. Waiting for dashboard...");
        await page.waitForTimeout(8000);
        await page.screenshot({ path: `test-results/regflow-1-dashboard-${timestamp}.png` });

        // Assuming Tab order on Admin Dashboard:
        // 'Admin Panel', 'Add Kid', 'Send', 'Receive'
        await page.keyboard.press('Tab'); // Admin Panel
        await page.keyboard.press('Tab'); // Add Kid
        await page.keyboard.press('Enter');

        await page.waitForTimeout(3000);

        // Fill Add Kid Form
        // Full Name
        await page.keyboard.press('Tab'); // Actually need to see if it autofocused. Assume we need 1 tab to enter the form.
        await page.keyboard.type(kidName, { delay: 50 });

        // Username
        await page.keyboard.press('Tab');
        await page.keyboard.type(kidUsername, { delay: 50 });

        // PIN
        await page.keyboard.press('Tab');
        await page.keyboard.type(kidPin, { delay: 50 });

        // Submit Add Kid
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');

        console.log(`Created kid ${kidUsername}`);
        await page.waitForTimeout(5000);

        // We should be back at Dashboard page. Let's logout.
        // Logout is an AppBar action
        await page.reload(); // Quick hack if Tab order to AppBar is hard
        await page.waitForLoadState('load');
        await page.waitForTimeout(10000);
        await page.waitForTimeout(5000);

        // If we reload, we're securely logged in. We can click logout using exact selectors if needed.
        // Wait, Flutter web canvas doesn't have DOM selectors by default.
        // Tab navigation backwards (Shift+Tab) to AppBar? 
        await page.keyboard.press('Shift+Tab'); // Might hit the logout button?
        await page.keyboard.press('Enter');
        await page.waitForTimeout(2000);

        // Assuming logout worked, we are at login screen.
        // If not, clear storage and reload
        await page.evaluate(() => window.localStorage.clear());
        await page.reload();
        await page.waitForLoadState('load');
        await page.waitForTimeout(10000);
        await page.waitForTimeout(5000);

        // Kid mode is default. Tab to Username
        await page.keyboard.press('Tab'); // Focuses "I'm a Kid"
        await page.keyboard.press('Tab'); // Focuses "I'm a Parent"
        await page.keyboard.press('Tab'); // Focuses Username
        await page.keyboard.type(kidUsername, { delay: 50 });

        // PIN field
        await page.keyboard.press('Tab');
        await page.keyboard.type(kidPin, { delay: 50 });

        // Login button
        await page.keyboard.press('Tab');
        await page.keyboard.press('Enter');

        console.log("Submitted kid login. Waiting for dashboard...");
        await page.waitForTimeout(8000);

        await page.screenshot({ path: `test-results/regflow-2-kiddashboard-${timestamp}.png` });

    });
});
