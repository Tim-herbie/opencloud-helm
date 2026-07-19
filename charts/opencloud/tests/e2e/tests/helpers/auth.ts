import { expect, type Page } from '@playwright/test';

const username = process.env.OPENCLOUD_USERNAME;
const password = process.env.OPENCLOUD_PASSWORD;

export function usernameInput(page: Page) {
  return page
    .locator(
      'input[name="username"], input#username, input[autocomplete="username"], input[type="email"]'
    )
    .first();
}

export function passwordInput(page: Page) {
  return page
    .locator('input[name="password"], input#password, input[autocomplete="current-password"]')
    .first();
}

export function personalHeading(page: Page) {
  return page.getByRole('heading', { name: 'Personal' });
}

export async function waitForLoginOrApp(page: Page) {
  await expect
    .poll(
      async () => {
        const hasUser = await usernameInput(page).count();
        const hasPass = await passwordInput(page).count();
        const hasPersonal = await personalHeading(page).count();
        return hasPersonal > 0 || (hasUser > 0 && hasPass > 0);
      },
      { timeout: 10000, intervals: [300, 700, 1200] }
    )
    .toBeTruthy();
}

export function randomLetters(length: number): string {
  const alphabet = 'abcdefghijklmnopqrstuvwxyz';
  let result = '';
  for (let i = 0; i < length; i += 1) {
    result += alphabet[Math.floor(Math.random() * alphabet.length)];
  }
  return result;
}

export async function login(page: Page) {
  expect(username, 'Missing OPENCLOUD_USERNAME. Set it in charts/opencloud/tests/e2e/.env').toBeTruthy();
  expect(password, 'Missing OPENCLOUD_PASSWORD. Set it in charts/opencloud/tests/e2e/.env').toBeTruthy();

  await page.goto('/', { waitUntil: 'domcontentloaded' });

  await waitForLoginOrApp(page);
  if ((await personalHeading(page).count()) > 0) {
    await expect(personalHeading(page)).toBeVisible();
    return;
  }

  await usernameInput(page).fill(username!);
  await passwordInput(page).fill(password!);

  const submit = page
    .locator('button[type="submit"], input[type="submit"], button[name="login"]')
    .first();

  await expect(submit).toBeVisible();
  await Promise.all([
    page.waitForURL(/\/files\//, { timeout: 10000 }),
    submit.click()
  ]);

  await expect(personalHeading(page)).toBeVisible();
}
