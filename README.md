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

### Docker Compose

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
      - BUCKET=my-log-bucket-name
      - CRON=*/5 * * * *
    ports:
    - "80:80"
    volumes:
      - ${USERDIR}/docker/analytics/logs:/logs:rw
      - ${USERDIR}/docker/analytics:/config:rw
```

# License

MIT. See `LICENSE.txt`

    Copyright 2020 Ryan Harter

