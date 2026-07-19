import { expect, test } from '@playwright/test';
import { appShellIndicator, passwordInput, personalHeading, usernameInput, waitForLoginOrApp } from './helpers/auth';

test('login page is reachable and fields are visible', async ({ page }) => {
  const response = await page.goto('/', { waitUntil: 'domcontentloaded' });

  expect(response, 'No HTTP response received from base URL').not.toBeNull();
  expect(response!.status(), 'Base URL returned server error').toBeLessThan(500);
  await waitForLoginOrApp(page);

  if ((await personalHeading(page).count()) > 0) {
    await expect(personalHeading(page)).toBeVisible();
  } else if ((await appShellIndicator(page).count()) > 0) {
    await expect(appShellIndicator(page).first()).toBeVisible();
  } else {
    await expect(usernameInput(page)).toBeVisible();
    await expect(passwordInput(page)).toBeVisible();
  }
});
