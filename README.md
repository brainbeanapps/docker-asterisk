# Asterisk in Docker image

Dockerized version of [Asterisk](https://www.asterisk.org/) by [Brainbean Apps](https://brainbeanapps.com)

## Usage

```bash
docker run \
  --name asterisk \
  --restart unless-stopped \
  --net=host \
  -v /pbx/asterisk/etc:/etc/asterisk:ro \
  -v /pbx/asterisk/log:/var/log/asterisk:rw \
  -v /pbx/asterisk/lib:/var/lib/asterisk:rw \
  -v /pbx/asterisk/spool:/var/spool/asterisk:rw \
  brainbeanapps/asterisk:latest
```
