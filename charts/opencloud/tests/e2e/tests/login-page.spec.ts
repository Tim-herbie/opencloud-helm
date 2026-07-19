import { expect, test } from '@playwright/test';
import { passwordInput, usernameInput } from './helpers/auth';

test('login page is reachable and fields are visible', async ({ page }) => {
  const response = await page.goto('/', { waitUntil: 'domcontentloaded' });

  expect(response, 'No HTTP response received from base URL').not.toBeNull();
  expect(response!.status(), 'Base URL returned server error').toBeLessThan(500);
  await expect(usernameInput(page)).toBeVisible();
  await expect(passwordInput(page)).toBeVisible();
});
