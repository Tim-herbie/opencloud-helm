import { expect, test, type Page } from '@playwright/test';
import { login, randomLetters } from './helpers/auth';

test('can create spreadsheet, edit A1, save and close', async ({ page, context }) => {
  test.setTimeout(15_000);

  await login(page);
  const fileBaseName = randomLetters(10);
  const fileName = `${fileBaseName}.ods`;
  const fileNamePattern = new RegExp(`${fileBaseName}(?:\\.ods)?`, 'i');

  const newButton = page
    .locator('button:has-text("New"), [role="button"]:has-text("New")')
    .first();
  await expect(newButton).toBeVisible({ timeout: 10000 });
  await newButton.click();

  const spreadsheetMenuItem = page
    .locator('[role="menuitem"]:has-text("Spreadsheet"), button:has-text("Spreadsheet")')
    .first();
  await expect(spreadsheetMenuItem).toBeVisible();
  await spreadsheetMenuItem.click();

  const fileNameInput = page
    .locator(
      'input[placeholder*="name" i], input[aria-label*="name" i], input[value$=".ods"], input[type="text"]'
    )
    .first();
  await expect(fileNameInput).toBeVisible();
  await fileNameInput.fill(fileName);

  const createButton = page
    .locator('button:has-text("Create"), [role="button"]:has-text("Create")')
    .first();
  await expect(createButton).toBeVisible();
  await expect(createButton).toBeEnabled({ timeout: 10000 });

  const pageCountBeforeCreate = context.pages().length;
  await createButton.click();

  let popupPage: Page | null = null;
  const popupDeadline = Date.now() + 3000;
  while (Date.now() < popupDeadline) {
    const pagesNow = context.pages();
    if (pagesNow.length > pageCountBeforeCreate) {
      popupPage = pagesNow[pagesNow.length - 1];
      break;
    }
    await page.waitForTimeout(100);
  }

  const editorPage = popupPage ?? page;

  await editorPage.waitForTimeout(2500);
  const viewport = editorPage.viewportSize();
  if (viewport) {
    await editorPage.mouse.click(viewport.width / 2, viewport.height / 2);
  } else {
    await editorPage.mouse.click(640, 360);
  }
  await editorPage.keyboard.press('Escape').catch(() => {});

  const sheetFrameSelector = 'iframe[title*="Collabora" i], iframe[src*="loleaflet" i], iframe';
  const sheetFrameElement = editorPage.locator(sheetFrameSelector).first();
  await expect(sheetFrameElement).toBeVisible({ timeout: 10000 });
  const sheetFrame = editorPage.frameLocator(sheetFrameSelector).first();

  const closeWelcomeOverlay = sheetFrame.locator('#welcome-close').first();
  if (await closeWelcomeOverlay.isVisible({ timeout: 5000 }).catch(() => false)) {
    if (await closeWelcomeOverlay.isVisible({ timeout: 1000 }).catch(() => false)) {
      await sheetFrame.locator('body').press('Escape').catch(() => {});
    }
    await expect(closeWelcomeOverlay).toBeHidden({ timeout: 5000 });
  }

  const editorCanvas = sheetFrame.locator('#document-canvas[aria-label="Online Editor"]').first();
  await expect(editorCanvas).toBeVisible({ timeout: 10000 });
  await editorCanvas.click({ position: { x: 90, y: 45 }, force: true });
  await editorPage.keyboard.type('word test');
  await editorPage.keyboard.press('Enter');

  const saveButton = editorPage
    .locator('button:has-text("Save"), [aria-label*="save" i], [title*="save" i]')
    .first();
  if (await saveButton.isVisible({ timeout: 5000 }).catch(() => false)) {
    await saveButton.click();
  } else {
    await editorPage.keyboard.press('ControlOrMeta+s');
  }
  await editorPage.waitForTimeout(1000);

  if (popupPage) {
    await editorPage.close();
  } else {
    const closeEditor = page
      .locator('button:has-text("Close"), button[aria-label*="close" i], [role="button"][aria-label*="close" i]')
      .first();
    if (await closeEditor.isVisible({ timeout: 5000 }).catch(() => false)) {
      await closeEditor.click();
    }
    await page.waitForURL(/\/files\//, { timeout: 10000 });
  }

  await page.goto('/files/spaces/personal', { waitUntil: 'domcontentloaded' });

  const searchBox = page.getByRole('searchbox', { name: /enter search term/i }).first();
  if (await searchBox.isVisible({ timeout: 2000 }).catch(() => false)) {
    await searchBox.fill(fileBaseName);
    await searchBox.press('Enter').catch(() => {});
  }

  await expect
    .poll(
      async () => {
        const textMatches = await page.getByText(fileNamePattern).count();
        const listMatches = await page
          .locator(
            `[href*="${fileBaseName}"], [title*="${fileBaseName}"], [data-path*="${fileBaseName}"], [aria-label*="${fileBaseName}"]`
          )
          .count();
        const bodyContainsName = await page.evaluate((name) => {
          return document.body.innerText.toLowerCase().includes(name.toLowerCase());
        }, fileBaseName);
        return textMatches + listMatches + (bodyContainsName ? 1 : 0);
      },
      {
        timeout: 6000,
        intervals: [300, 600, 1000]
      }
    )
    .toBeGreaterThan(0);
});
