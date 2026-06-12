# Integration Tests

Integration tests use an in-memory Drift database (not the on-disk production DB).

Run with:
```
flutter test test/integration/
```

Each test suite must:
- Create its own AppDatabase instance using `NativeDatabase.memory()`
- Close the database in `tearDown`
- Never share state between test cases
