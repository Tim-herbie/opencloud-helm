import { test } from '@playwright/test';
import { login } from './helpers/auth';

test('can submit login form with provided credentials', async ({ page }) => {
  await login(page);
});
