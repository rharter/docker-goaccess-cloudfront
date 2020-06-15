# Docker GoAccess CloudFront

A Docker container which syncs [CloudFront][1] logs from an S3 bucket, processes them with [GoAccess][2], and serves them using [Nginx][3].

 [1]: https://aws.amazon.com/cloudfront/
 [2]: https://goaccess.io/
 [3]: https://www.nginx.com/

[![Docker Image Version](https://img.shields.io/docker/v/rharter/goaccess-cloudfront?sort=semver)][hub]
[![Docker Image Size](https://img.shields.io/docker/image-size/rharter/goaccess-cloudfront)][layers]

 [hub]: https://hub.docker.com/r/rharter/goaccess-cloudfront
 [layers]: https://microbadger.com/images/rharter/goaccess-cloudfront

## Usage

### Environment Variables

This container uses the [s6 overlay][overlay], so you can set the `PUID`, `PGID` and `TZ` environment variables to set the appropriate user, group and timezone.

 [overlay]: https://github.com/just-containers/s6-overlay
 
The following environment variables are used in addition the the standard s6 overlay variables.

| Variable | Description |
| --- | --- |
| BUCKET | The S3 bucket to which CloudFront writes it's logs. |
| AWS_ACCESS_KEY_ID | The AWS Access Key Id with read permissions for the log bucket. Alternatively, you can use a config file based credentials in `/config/.aws/credentials`. |
| AWS_SECRET_ACCESS_KEY | The AWS Secret Access Key paired with the id. Alternatively, you can use a config file based credentials in `/config/.aws/credentials`. |
| CRON | (Optional) The cron schedule to sync. If missing, the container will perform a one time sync on launch. |
| HTML_FILENAME | (Optional) The name of the html file to generate (without the extension). This can be used to generate analytics reports for multiple sites. |
| NO_SERVER | (Optional) If this variable is set then the nginx server won't be started in this container. |
| POST_ACTION | (Optional) Specify one of the possible post execution actions to take place after the sync script completes.<br/><ul><li>**prune**: Deletes processed log files from S3.</li><li>**script**: A shell script to execute, placed in `/config`.</li><li>**command**: A shell command to execute.</li></ul>

If you specify a `POST_ACTION` script, it will receive the generated analytics HMTL file as `$1`.

### Volumes

The container uses two volumes, `/logs` and `/config`.  Synced log files will be stored in the volume mounted at `/logs`.  A customizable `nginx.conf` file will be written to `/config`, and the resulting analytics report will be written to an html file in `/config/html`.

## Examples

You can run the container using Docker Compose, or using a standard Docker command.

### One-off processing

The following command will sync the log files from `my-access-logs` into `/tmp/goaccess-cloudfront/logs`, process them with `goaccess`, writing the resulting html file to `/tmp/goaccess-cloudfront/html/index.html`, and exit.

```sh
docker run \
  -e "PUID=1000" \
  -e "PGID=998" \
  -e "AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}" \
  -e "AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}" \
  -e "BUCKET=my-access-logs" \
  -e "NO_SERVER=1" \
  -v "/tmp/goaccess-cloudfront/logs:/logs:rw" \
  -v "/tmp/goaccess-cloudfront:/config:rw" \
  rharter/goaccess-cloudfront
```

### Docker Compose

By adding the following configuration to a Docker Compose `yaml` file, the container will continuously run, syncing CloudFront access logs from S3 bucket `my-access-logs` every 5 minutes and updating the served html report. The generated analytics report can be accessed at `http://server.address/index.html`.

```yaml
  analytics:
    container_name: analytics
    image: rharter/goaccess-cloudfront
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - BUCKET=my-access-logs
      - CRON=*/5 * * * *
    ports:
    - "80:80"
    volumes:
      - ${USERDIR}/docker/analytics/logs:/logs:rw
      - ${USERDIR}/docker/analytics:/config:rw
```

### Multiple Sites with Docker Compose

To generate analytics for multiple sites that are served by a single service, run multiple instances of the container, but only have one of them serve the resulting files. Make sure that you separate the log directories.

```yaml
  analytics-foo-com:
    container_name: analytics-foo-com
    image: rharter/goaccess-cloudfront
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - BUCKET=foo.com-access-logs
      - CRON=*/5 * * * *
      - NO_SERVER=1
      - HTML_FILENAME=foo
    volumes:
      - ${USERDIR}/docker/analytics/logs/foo.com:/logs:rw
      - ${USERDIR}/docker/analytics:/config:rw
      
  analytics-main:
    container_name: analytics-main
    image: rharter/goaccess-cloudfront
    restart: unless-stopped
    environment:
      - PUID=${PUID}
      - PGID=${PGID}
      - TZ=${TZ}
      - AWS_ACCESS_KEY_ID=${AWS_ACCESS_KEY_ID}
      - AWS_SECRET_ACCESS_KEY=${AWS_SECRET_ACCESS_KEY}
      - BUCKET=ryanharter.com-access-logs
      - CRON=*/5 * * * *
      - HTML_FILENAME=ryanharter
    ports:
    - "80:80"
    volumes:
      - ${USERDIR}/docker/analytics/logs/ryanharter.com:/logs:rw
      - ${USERDIR}/docker/analytics:/config:rw
```

Analytics for `foo.com` will be available on the host at `http://server.address/foo.html`, and analytics for `ryanharter.com` will be available at `http://server.address/ryanharter.html`.  By placing a custom file at `${USERDIR}/docker/analytics/index.html`, you can have a landing page that directs users to your other analytics reports.

# License

MIT. See `LICENSE.txt`

    Copyright 2020 Ryan Harter

