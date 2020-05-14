FROM mcr.microsoft.com/java/jdk:8-zulu-alpine

MAINTAINER deemocat <deathswaltz@hotmail.com>

ENV LANG=C.UTF-8

ENV ANT_VERSION 1.9.14
ENV ANT_HOME /etc/ant-${ANT_VERSION}
ENV PATH ${PATH}:${ANT_HOME}/bin
ENV ANT_CONTRIB_VERSION 1.0b2

ARG OPENCV_VERSION=4.2.0

USER root
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.tuna.tsinghua.edu.cn/g' /etc/apk/repositories

RUN echo "https://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community\nhttps://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main\nhttps://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/releases" >> /etc/apk/repositories

RUN apk upgrade && apk update && \
    apk add  --no-cache -t  \
    --update  \
    # Deps start
    # Build dependencies
    build-base clang clang-dev cmake pkgconf wget openblas openblas-dev \
    linux-headers \
    # Image IO packages
    libjpeg-turbo libjpeg-turbo-dev \
    libpng libpng-dev \
    libwebp libwebp-dev \
    tiff tiff-dev \
    jasper-libs jasper-dev \
    openexr openexr-dev \
    # Video depepndencies
    ffmpeg-libs ffmpeg-dev \
    libavc1394 libavc1394-dev \
    gstreamer gstreamer-dev \
    gst-plugins-base gst-plugins-base-dev \
    # libstdc++ curl ca-certificates bash java-cacerts \
    libgphoto2 libgphoto2-dev && \
    apk add --repository https://mirrors.tuna.tsinghua.edu.cn/alpine/edge/community \
    --repository https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/main \
    --repository https://mirrors.tuna.tsinghua.edu.cn/alpine/latest-stable/releases \
            --update --no-cache libtbb libtbb-dev &&  \
    cd /tmp && \
    # Downloads Ant
    wget http://www.us.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    mkdir ant-${ANT_VERSION} && \
    tar -zxf apache-ant-${ANT_VERSION}-bin.tar.gz  && \
    mv apache-ant-${ANT_VERSION} ${ANT_HOME} && \
    rm apache-ant-${ANT_VERSION}-bin.tar.gz && \
    rm -rf ant-${ANT_VERSION} && \
    rm -rf ${ANT_HOME}/manual && \
    unset ANT_VERSION && \
    # Downloads Ant-contrib
    wget http://kent.dl.sourceforge.net/project/ant-contrib/ant-contrib/ant-contrib-${ANT_CONTRIB_VERSION}/ant-contrib-${ANT_CONTRIB_VERSION}-bin.tar.gz && \
    tar -zxf ant-contrib-${ANT_CONTRIB_VERSION}-bin.tar.gz  && \
    cp ant-contrib/lib/ant-contrib.jar ${ANT_HOME}/lib && \
    rm -rf ant-contrib && \
    rm ant-contrib-${ANT_CONTRIB_VERSION}-bin.tar.gz  && \
    unset ANT_CONTRIB_VERSION && \
    # Deps end
    # Downloads opencv
    wget https://github.com/opencv/opencv/archive/$OPENCV_VERSION.tar.gz && \
    #wget https://gitee.com/mirrors/opencv/repository/archive/$OPENCV_VERSION.tar.gz && \
    tar -xzf $OPENCV_VERSION.tar.gz && \
    rm -rf $OPENCV_VERSION.tar.gz && \
    # Configure
    mkdir -vp /tmp/opencv-$OPENCV_VERSION/build && \    
    #mkdir -vp /tmp/opencv/build && \    
    mkdir -vp /usr/local/opencv && \
    cd /tmp/opencv-$OPENCV_VERSION/build && \
    #cd /tmp/opencv/build && \
    cmake \
        # Compiler params
        -D CMAKE_BUILD_TYPE=RELEASE \
        -D CMAKE_C_COMPILER=/usr/bin/clang \
        -D CMAKE_CXX_COMPILER=/usr/bin/clang++ \
        -D CMAKE_INSTALL_PREFIX=/usr/local/opencv \
        # No examples
        -D INSTALL_PYTHON_EXAMPLES=NO \
        -D INSTALL_C_EXAMPLES=NO \
        # Support
        -D WITH_IPP=NO \
        -D WITH_1394=NO \
        -D WITH_LIBV4L=NO \
        -D WITH_V4l=YES \
        -D WITH_TBB=YES \
        -D WITH_FFMPEG=YES \
        -D WITH_GPHOTO2=YES \
        -D WITH_GSTREAMER=YES \
        # NO doc test and other bindings
        -D BUILD_DOCS=NO \
        -D BUILD_TESTS=NO \
        -D BUILD_PERF_TESTS=NO \
        -D BUILD_EXAMPLES=NO \
        -D BUILD_opencv_python2=NO \
        -D BUILD_ANDROID_EXAMPLES=NO \
        # Build Java bindings only
        -D BUILD_opencv_java=YES .. && \
    # Build
    make -j`grep -c '^processor' /proc/cpuinfo` && \
    make install && \
    # Cleanup
    cd / && rm -rf /tmp/opencv-$OPENCV_VERSION && \
    #cd / && rm -rf /tmp/opencv && \
    rm -rf ${ANT_HOME} && \
    apk del --purge build-base clang clang-dev cmake pkgconf wget openblas-dev \
                   openexr-dev gstreamer-dev gst-plugins-base-dev libgphoto2-dev \
                   libtbb-dev libjpeg-turbo-dev libpng-dev tiff-dev jasper-dev \
                   ffmpeg-dev libavc1394-dev python3-dev && \
     rm -vrf /var/cache/apk/*