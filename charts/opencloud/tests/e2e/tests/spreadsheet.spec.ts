import { expect, test, type BrowserContext, type Frame, type Page } from '@playwright/test';
import { login, randomLetters } from './helpers/auth';

declare const process: {
  env: Record<string, string | undefined>;
};

const editorCanvasSelector = '#document-canvas[aria-label="Online Editor"]';

async function findSpreadsheetEditorFrame(page: Page, timeout: number): Promise<Frame | null> {
  const deadline = Date.now() + timeout;

  while (Date.now() < deadline) {
    for (const frame of page.frames()) {
      if (frame === page.mainFrame()) {
        continue;
      }

      const canvasCount = await frame.locator(editorCanvasSelector).count().catch(() => 0);
      if (canvasCount > 0) {
        return frame;
      }
    }

    await page.waitForTimeout(500);
  }

  return null;
}

async function waitForSpreadsheetFile(page: Page, fileBaseName: string, fileNamePattern: RegExp, timeout: number): Promise<boolean> {
  const deadline = Date.now() + timeout;

  while (Date.now() < deadline) {
    const textMatches = await page.getByText(fileNamePattern).count().catch(() => 0);
    const listMatches = await page
      .locator(
        `[href*="${fileBaseName}"], [title*="${fileBaseName}"], [data-path*="${fileBaseName}"], [aria-label*="${fileBaseName}"]`
      )
      .count()
      .catch(() => 0);

    if (textMatches + listMatches > 0) {
      return true;
    }

    await page.waitForTimeout(500);
  }

  return false;
}

async function openSpreadsheetFromFilesList(
  page: Page,
  context: BrowserContext,
  fileBaseName: string,
  fileNamePattern: RegExp,
  popupWaitTimeout: number,
  editorReadyTimeout: number
): Promise<Page> {
  await page.goto('/files/spaces/personal', { waitUntil: 'domcontentloaded' });

  const searchBox = page.getByRole('searchbox', { name: /enter search term/i }).first();
  if (await searchBox.isVisible({ timeout: 2000 }).catch(() => false)) {
    await searchBox.fill(fileBaseName);
    await searchBox.press('Enter').catch(() => {});
  }

  const fileFound = await waitForSpreadsheetFile(page, fileBaseName, fileNamePattern, editorReadyTimeout);
  expect(fileFound, `Created spreadsheet ${fileBaseName} did not appear in the file list`).toBeTruthy();

  const popupPromise = context.waitForEvent('page', { timeout: popupWaitTimeout }).catch(() => null);
  const hrefMatch = page.locator(`[href*="${fileBaseName}"]`).first();
  const namedEntry = page.getByText(fileNamePattern).first();
  const fallbackEntry = page
    .locator(`[title*="${fileBaseName}"], [data-path*="${fileBaseName}"], [aria-label*="${fileBaseName}"]`)
    .first();

  if ((await hrefMatch.count().catch(() => 0)) > 0) {
    await hrefMatch.click();
  } else if ((await namedEntry.count().catch(() => 0)) > 0) {
    await namedEntry.click();
  } else {
    await fallbackEntry.click();
  }

  const popupPage = await Promise.race([
    popupPromise,
    findSpreadsheetEditorFrame(page, editorReadyTimeout).then((frame) => (frame ? null : null))
  ]);

  return popupPage ?? page;
}

test('can create spreadsheet, edit A1, save and close', async ({ page, context }) => {
  test.setTimeout(90_000);

  const editorReadyTimeout = process.env.CI ? 30_000 : 10_000;
  const popupWaitTimeout = process.env.CI ? 20_000 : 3_000;
  const sheetFrameSelector = 'iframe[title*="Collabora" i], iframe[src*="loleaflet" i], iframe';

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

  const popupPromise = context.waitForEvent('page', { timeout: popupWaitTimeout }).catch(() => null);
  await createButton.click();

  let popupPage = await Promise.race([
    popupPromise,
    findSpreadsheetEditorFrame(page, editorReadyTimeout).then((frame) => (frame ? null : null))
  ]);

  let editorPage = popupPage ?? page;

  let sheetFrame = await findSpreadsheetEditorFrame(editorPage, editorReadyTimeout);
  if (!sheetFrame) {
    editorPage = await openSpreadsheetFromFilesList(
      page,
      context,
      fileBaseName,
      fileNamePattern,
      popupWaitTimeout,
      editorReadyTimeout
    );
    popupPage = editorPage === page ? null : editorPage;
    sheetFrame = await findSpreadsheetEditorFrame(editorPage, editorReadyTimeout);
  }

  expect(sheetFrame, 'Could not find spreadsheet editor frame after opening the document').toBeTruthy();
  if (!sheetFrame) {
    throw new Error('Could not find spreadsheet editor frame after opening the document');
  }

  await editorPage.waitForLoadState('domcontentloaded');
  await editorPage.waitForTimeout(2500);
  const viewport = editorPage.viewportSize();
  if (viewport) {
    await editorPage.mouse.click(viewport.width / 2, viewport.height / 2);
  } else {
    await editorPage.mouse.click(640, 360);
  }
  await editorPage.keyboard.press('Escape').catch(() => {});

  const sheetFrameElement = editorPage.locator(sheetFrameSelector).first();
  await expect(sheetFrameElement).toBeVisible({ timeout: editorReadyTimeout });
  sheetFrame = sheetFrame ?? (await findSpreadsheetEditorFrame(editorPage, editorReadyTimeout));
  expect(sheetFrame, 'Could not find spreadsheet editor frame after the editor page became visible').toBeTruthy();
  if (!sheetFrame) {
    throw new Error('Could not find spreadsheet editor frame after the editor page became visible');
  }

  const closeWelcomeOverlay = sheetFrame.locator('#welcome-close').first();
  if (await closeWelcomeOverlay.isVisible({ timeout: 5000 }).catch(() => false)) {
    if (await closeWelcomeOverlay.isVisible({ timeout: 1000 }).catch(() => false)) {
      await sheetFrame.locator('body').press('Escape').catch(() => {});
    }
    await expect(closeWelcomeOverlay).toBeHidden({ timeout: 5000 });
  }

  const editorCanvas = sheetFrame.locator(editorCanvasSelector).first();
  await expect(editorCanvas).toBeVisible({ timeout: editorReadyTimeout });
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
