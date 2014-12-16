# DOCKER-VERSION 1.2.0

# base
FROM    ubuntu:14.10
RUN     apt-get update
RUN     apt-get install -qy build-essential wget

# create user
RUN     adduser --disabled-password web

# git
RUN     apt-get install -qq git

# Java
RUN     apt-get install -qq openjdk-8-jdk

# Ant
RUN     apt-get install -qq ant

# DITA
RUN     git clone https://github.com/dita-ot/dita-ot.git
WORKDIR dita-ot
RUN     git submodule update --init --recursive

# Compile DITA
RUN 	ant jar
RUN     ant jar.plug-ins

# Install plugins
RUN     ant -f src/main/integrator.xml

# Set CLASSPATH
ENV     CLASSPATH /dita-ot/src/main/:/dita-ot/src/main/lib/:/dita-ot/src/main/lib/dost.jar:/dita-ot/src/main/lib/xercesImpl.jar:/dita-ot/src/main/lib/xml-apis.jar:/dita-ot/src/main/lib/commons-codec-1.4.jar:/dita-ot/src/main/lib/saxon/saxon9-dom.jar:/dita-ot/src/main/lib/saxon/saxon9.jar:/dita-ot/src/main/lib/xml-resolver.jar:/dita-ot/src/main/lib/icu4j.jar:/dita-ot/src/main/lib/commons-io.jar

# Run demo with default options at all prompts
WORKDIR src/main
RUN     cp -a plugins/org.oasis-open.dita.v1_2/dtd/* dtd/
RUN     yes  | ant -f build_demo.xml
