# OpenCV 4.2.0 with Openjdk 8

opencv:4.2.0
openjdk:8-jdk-alpine
#### Description

The Docker image is based on the latest Alpine Linux for a minimum size image. It uses Alpine packages from testing and community repos.

https://alpinelinux.org

The OpenCV lib is compiled from source and contains no contrib modules.

https://github.com/opencv/opencv/releases

Older versions can be found under different tags.

#### Usage
Use like you would any other base image:
```dockerfile
FROM deemocat/alpine-opencv-java:latest
ENTRYPOINT ["/bin/sh"]
```

#### Download
To get the image use `sudo docker pull deemocat/alpine-opencv-java:latest`

#### License
Licensed under MIT license, see LICENSE file.