# Release Process

1. Updates `CHANGELOG.md` with version, date, and summary.

2. Commit changes

    git commit -am "Prepare version X.Y.Z"

3. Create annotated tag

    git tag -a X.Y.Z -m "Version X.Y.Z"

4. Push commit and tag

    git push && git push --tags

CI will take care of building and pushing to Docker Hub automatically.
