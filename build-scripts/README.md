# Build and deploy process
The build and deploy process is as such:
| Step                          | Command                   | Local              | Remote             |
|-------------------------------|---------------------------|--------------------|--------------------|
| Check that prereqs are avail  | `check-prerequisites.sh`  | :heavy_check_mark: | :heavy_check_mark: |
| Install local prereqs         | `local-prepare.sh`        | :heavy_check_mark: | :heavy_check_mark: |
| Run pre tests                 | `local-tests.sh`          | :heavy_check_mark: | :heavy_check_mark: |
| Buid docker images            | `build-docker-images.sh`  | :heavy_check_mark: | :heavy_check_mark: |
| Generate secrets              | `generate-secrets.sh`     | :heavy_check_mark: | :heavy_check_mark: |
| Prepare cluster               | `prepare-cluster.sh`      | :heavy_check_mark: | :heavy_check_mark: |
| Deploy ecosystem              | `deploy-ecosystem.sh`     | :heavy_check_mark: | :heavy_check_mark: |
| Run integrated unit tests     | `run-unit-tests.sh`       | :heavy_check_mark: | :heavy_check_mark: |
| Run e2e tests                 | `run-e2e-tests.sh`        | :heavy_check_mark: | :heavy_check_mark: |
