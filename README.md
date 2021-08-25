# CircleCI Orb Version Check

This is an unofficial tool (Docker image) that checks your CircleCI config for outdated Orbs used.


It simply returns 0 if all declared Orbs are of the latest available version, or 1 once an outdated Orb is detected.

## Usage Examples

### Local (with Docker)

```sh
docker pull kelvintaywl/circleci-orb-version-check

cd /path/to/your/project
docker run -v $PWD/.circleci/:/home/circleci/project/.circleci/ kelvintaywl/circleci-orb-version-check
```

### CircleCI

```yml
version: 2.1

jobs:
  check_orbs:
    docker:
      - image: kelvintaywl/circleci-orb-version-check
    environment:
      CIRCLE_WORKING_DIRECTORY: /home/circleci/project
    steps:
      - checkout
      - run:
          command: |
            /tmp/orb-version-check.sh

workflows:
  my_workflow:
    jobs:
      - check_orbs
```
