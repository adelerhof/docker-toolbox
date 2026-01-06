# docker-toolbox

## Steps for github actions (random notes)

- When creating pull request do tests (docker build, infra-test)
- When merge to master create new release / tag (fix = +0.0.1, feature = +0.1, major = +1 )
- When new tag build docker image with same docker tag and push to packages

## Tagging new version

Build stage is without github tag docker image tag is `SHA_code` and `scan`.

When merging to master a tag for github is created / updated. By default it's updated as `patch` when the tag needs to be updated at a specific version use the `#minor`, `#major` or `#patch` in the commit message for the PR.

Based on this new github tag a package / docker-image will be created with the same tag.

## Testing notes

### Test PostgresSql database connections

```bash
pg_isready -h 10.0.0.1 -p 5432
10.0.0.1:5432 - accepting connections
```

```bash
nc -v 10.0.0.1 5432 -h
Connection to 10.0.0.1 5432 port [tcp/postgresql] succeeded!
```

```bash
telnet 10.0.0.1 5432
Connected to 10.0.0.1
```

### Test mail servers

```bash
./mailrelaytest.sh 127.0.0.1 25  from@example.com to@example.com
```

This script requires four arguments:

1.  recepient mail server
2.  port (typically 25 or 465)
3.  mail from (e.g. from@example.com)
4.  mail to (e.g. to@example.com)
