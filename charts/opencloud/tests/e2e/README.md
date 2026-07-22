# OpenCloud E2E Tests with Playwright

## 1) Install

Run inside this folder:

npm ci
npx playwright install --with-deps chromium

## 2) Configure test target and login

Create `.env` based on `.env.example` and set values for your environment.

## 3) Run first smoke test (without login credentials required)

npm run test -- -g "login page is reachable"

## 4) Run login submit test

Set `OPENCLOUD_USERNAME` and `OPENCLOUD_PASSWORD` in `.env`, then run:

npm run test -- -g "can submit login form"

## 5) Debug selectors in UI mode

npm run test:ui

If login test fails because the button/field labels differ, inspect locators in UI mode and adjust `tests/example.spec.ts`.
