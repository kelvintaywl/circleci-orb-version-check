# CircleCI Orb Version Check

This is an unofficial tool (Docker image) that checks your CircleCI config for outdated Orbs used.


It simply returns 0 if all declared Orbs are of the latest available version, or 1 once an outdated Orb is detected.

## Usage

```sh
# Docker solution
cd /path/to/your/project
docker run -v $PWD/.circleci/:/home/circleci/project/.circleci/ kelvintaywl/circleci-orb-version-check
```
