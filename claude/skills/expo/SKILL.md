---
name: expo
description: Expo / React Native with a first-class web target - project layout, the jest-expo unit setup, and driving the web build with Playwright so an agent can verify its own work. Use in Expo repos.
---

# Expo

For repos built on Expo / React Native where **web is a real target**, not an afterthought.

## Why web matters here

Mobile is the worst case for agent-verifiable work: simulators are slow, builds are slow, and there
is no equivalent of "open the page and click the button". `react-native-web` gives the *same
components* a browser surface, so an agent gets a fast loop it can actually observe.

That makes the web target the verification surface, and it carries one obligation: **anything that
genuinely differs on device must be recorded as unverified rather than assumed passing.** See the
last section.

## Testing: two layers, two tools

| Layer | Tool | Runs |
|---|---|---|
| Unit / component | **`jest` with the `jest-expo` preset** | every change |
| End-to-end (web) | **Playwright** | per feature |
| End-to-end (device) | Maestro | before a release |

**Use `jest-expo`, not vitest.** Expo ships and maintains this preset; it handles the RN transform
pipeline, the platform-suffix resolution and the native module mocks. Reaching for vitest here means
rebuilding all of that by hand.

```json
{
  "scripts": { "test": "jest --watchAll" },
  "jest": { "preset": "jest-expo" }
}
```

### Platform-suffixed tests

Test files select their platform by extension, and this is the mechanism that makes one component
testable on several targets:

```
Button.test.tsx        shared
Button.test.web.tsx    web only
Button.test.ios.tsx    iOS only
Button.test.native.tsx native (ios + android)
Button.test.node.ts    node, no renderer
```

Write the shared test first. Add a platform-suffixed one only when behaviour genuinely diverges -
a suffixed file is a claim that the platforms differ, so it should be true.

## E2E on web with Playwright

Expo Router supports driving the dev server from Playwright directly. The shape:

```ts
import { test, expect } from '@playwright/test';

test('the thing the user actually does', async ({ page }) => {
  await page.goto(baseURL);
  await expect(page.locator('[data-testid="counter"]')).toHaveText('0');
  await page.locator('[data-testid="increment"]').click();
  await expect(page.locator('[data-testid="counter"]')).toHaveText('1');
});
```

- Put stable `testID` props on anything a test targets. On web, `testID` becomes `data-testid`, so
  one prop serves both surfaces.
- Assert on **user-visible outcomes**, never on component internals or state.
- Collect page errors and assert the list is empty - a test that passes while the console throws is
  a test that will keep passing when the feature breaks.

## Layout

```
app/            expo-router routes - file-based, the route tree IS this directory
components/     shared presentational components
features/<x>/   feature-scoped components, hooks, logic
lib/            platform-agnostic helpers, no React
```

Keep platform branching at the leaves. `Platform.select` inside a shared component is fine;
a component that is 80% platform branches should be two files with a platform suffix.

## What does NOT work on web - the unverified list

These differ genuinely, and web passing tells you nothing about them:

- **Camera / image picker** - permission flows are entirely different
- **OCR / on-device ML** - usually native-only
- **Push notifications** - no equivalent
- **Secure storage** - `expo-secure-store` is Keychain/Keystore on device; web falls back to
  something weaker, so a web test proves nothing about the security property
- **Background tasks, haptics, biometrics**
- **Deep links** - similar in shape, different in mechanics

**Anything touching these goes in the change's "unverified" list and needs a device check before it
ships.** Do not let a green web suite imply these were tested. A record listing only successes
teaches you to trust output nobody checked.

## Reading platform data from the phone

Worth knowing before designing a feature around it: **you cannot read other apps' notifications or
SMS on iOS at all**, and on Android `NotificationListenerService` needs special permission plus a
Play Store policy justification. If a feature depends on this, verify feasibility before designing
around it - a provider API is the durable route.
