# Asterisk in Docker image

[![Build Status](https://img.shields.io/docker/build/brainbeanapps/asterisk.svg)](https://hub.docker.com/r/brainbeanapps/asterisk)
[![Docker Pulls](https://img.shields.io/docker/pulls/brainbeanapps/asterisk.svg)](https://hub.docker.com/r/brainbeanapps/asterisk)
[![Docker Stars](https://img.shields.io/docker/stars/brainbeanapps/asterisk.svg)](https://hub.docker.com/r/brainbeanapps/asterisk)
[![Docker Layers](https://images.microbadger.com/badges/image/brainbeanapps/asterisk.svg)](https://microbadger.com/images/brainbeanapps/asterisk)

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
