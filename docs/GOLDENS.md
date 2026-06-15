# Golden tests (visual regression)

This project uses `golden_test` to capture UI screenshots and compare them against baseline images.

Why:

- Catch visual regressions before merging.
- Provide deterministic UI checks across developers/CI.

Local commands:

Run the golden checks (do not update baselines):

```bash
flutter test test/goldens
```

Regenerate baselines (only when you accept visual changes):

```bash
flutter test test/goldens --update-goldens
# then commit the changed PNG files under test/goldens/
```

CI (what the workflow does):

- Runs `flutter analyze` and `flutter test test/goldens` on PRs and pushes to `main`.
- Uploads golden images as job artifacts so you can review them in the Actions UI.
- Provides a manual `workflow_dispatch` job to regenerate baselines and push them to a branch for review.

Best practices:

- Keep tests deterministic: use `ProviderScope` overrides and the test-specific `contentOverride`/`previewContent` flags added to widgets.
- Avoid calling `--update-goldens` automatically in PRs; instead run it locally or on a protected branch and review the images before merging.
- If a golden fails in CI, download the artifact and inspect the PNG diffs to decide whether to accept the change (and update baselines) or fix a bug.

If you want, I can also create a protected branch workflow to automatically open a PR with updated baselines.
