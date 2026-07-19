import 'dotenv/config';
import { defineConfig, devices } from '@playwright/test';

const baseURL = process.env.OPENCLOUD_BASE_URL;

if (!baseURL) {
  throw new Error(
    'Missing OPENCLOUD_BASE_URL. Set it in charts/opencloud/tests/e2e/.env or as an environment variable.'
  );
}

export default defineConfig({
  testDir: './tests',
  timeout: process.env.CI ? 120_000 : 15_000,
  expect: {
    timeout: process.env.CI ? 15_000 : 10_000
  },
  fullyParallel: true,
  forbidOnly: !!process.env.CI,
  retries: process.env.CI ? 2 : 0,
  workers: process.env.CI ? 1 : undefined,
  reporter: process.env.CI ? [['html', { open: 'never' }], ['github']] : [['list'], ['html']],
  use: {
    baseURL,
    ignoreHTTPSErrors: process.env.OPENCLOUD_IGNORE_HTTPS_ERRORS === 'true',
    trace: 'on-first-retry',
    screenshot: 'only-on-failure',
    video: 'retain-on-failure'
  },
  projects: [
    {
      name: 'chromium',
      use: { ...devices['Desktop Chrome'] }
    }
  ]
});
