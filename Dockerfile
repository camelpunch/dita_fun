# DOCKER-VERSION 1.2.0

FROM    ubuntu:14.10

# Use utopic-proposed, fixes https://bugs.launchpad.net/ubuntu/+source/icedtea-web/+bug/1363785
RUN     echo 'deb http://archive.ubuntu.com/ubuntu/ utopic-proposed restricted main multiverse universe' >> /etc/apt/sources.list
RUN     apt-get update

RUN     apt-get install -qq vim
RUN     apt-get install -qq git

# Old JDK that works with 1.7. Newer DITA-OT needs Oracle.
RUN     apt-get install -qq openjdk-6-jdk

# Install Ant from upstream distribution, fixes https://github.com/dita-ot/dita-ot/issues/1613
ADD     http://apache.mirrors.timporter.net//ant/binaries/apache-ant-1.9.4-bin.tar.bz2 ant.tar.bz2
RUN     tar -jxf ant.tar.bz2
ENV     PATH /apache-ant-1.9.4/bin/:$PATH

# Install old version of DITA-OT that works with our ditamaps
RUN     git clone https://github.com/dita-ot/dita-ot.git
WORKDIR dita-ot
RUN     git checkout 1.7.5
RUN     git submodule update --init --recursive
RUN 	ant jar
RUN     ant -f src/main/integrator.xml

ENV     CLASSPATH /dita-ot/src/main/lib/xercesImpl.jar:/dita-ot/src/main/lib/xml-apis.jar:/dita-ot/src/main/lib/resolver.jar:/dita-ot/src/main/lib/commons-codec-1.4.jar:/dita-ot/src/main/lib/icu4j.jar:/dita-ot/src/main/lib/saxon/saxon9-dom.jar:/dita-ot/src/main/lib/saxon/saxon9.jar:target/classes:/dita-ot/src/main/:/dita-ot/src/main/lib/:/dita-ot/src/main/lib/dost.jar

RUN     ant test

ADD     gemfirexd-140 /gemfirexd-140

ADD     gemfire_build.xml /dita-ot/gemfire_build.xml
RUN     ant -f gemfire_build.xml
