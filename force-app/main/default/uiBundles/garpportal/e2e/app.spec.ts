import { test, expect } from '@playwright/test';

test.describe('base-react-app', () => {
  test('root redirects to /home and shows hello world', async ({ page }) => {
    await page.goto('/');
    await expect(page).toHaveURL(/\/home$/);
    await expect(page.getByRole('heading', { name: 'Hello World' })).toBeVisible();
  });
});
