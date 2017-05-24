# Build and deploy process
The build and deploy process is as such:
| Step                          | Command                   | Local              | Remote             |
|-------------------------------|---------------------------|--------------------|--------------------|
| Check agent environment       | `check-agent.sh`          | :heavy_check_mark: | :heavy_check_mark: |
| Install local prereqs         | `prerequisites.sh`        | :heavy_check_mark: | :heavy_check_mark: |
| Run pre tests                 | `run-pretests.sh`         | :heavy_check_mark: | :heavy_check_mark: |
| Buid docker images            | `build-docker-images.sh`  | :heavy_check_mark: | :heavy_check_mark: |
| Prepare cluster               | `prepare-cluster.sh`      | :heavy_check_mark: | :heavy_check_mark: |
| Deploy ecosystem              | `deploy-ecosystem.sh`     | :heavy_check_mark: | :heavy_check_mark: |

