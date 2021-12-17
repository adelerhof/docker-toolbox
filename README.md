# docker-toolbox

## Steps for github actions (random notes)

- When creating pull request do tests (docker build, infra-test)
- When merge to master create new release / tag (fix = +0.0.1, feature = +0.1, major = +1 )
- When new tag build docker image with same docker tag and push to packages

## Tagging new version

Build stage is without github tag docker image tag is `SHA_code` and `scan`.

When merging to master a tag for github is created / updated. By default it's updated as `patch` when the tag needs to be updated at a specific version use the `#minor`, `#major` or `#patch` in the commit message for the PR.

Based on this new github tag a package / docker-image will be created with the same tag.