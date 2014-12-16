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

# Install Vim, for debugging. TODO remove when done.
RUN     apt-get install -qq vim

# Set CLASSPATH
ENV     CLASSPATH /dita-ot/src/main/:/dita-ot/src/main/lib/:/dita-ot/src/main/lib/dost.jar:/dita-ot/src/main/lib/xercesImpl.jar:/dita-ot/src/main/lib/xml-apis.jar:/dita-ot/src/main/lib/commons-codec-1.4.jar:/dita-ot/src/main/lib/saxon/saxon9-dom.jar:/dita-ot/src/main/lib/saxon/saxon9.jar:/dita-ot/src/main/lib/resolver.jar:/dita-ot/src/main/lib/icu4j.jar:/dita-ot/src/main/lib/commons-io.jar:/dita-ot/src/main/resources

# Run demo with default options at all prompts
ADD     gemfirexd-140 /gemfirexd-140

# Replace relative links to DTDs with absolute paths. Look away now.
RUN     sed --in-place --expression='s| *"[./a-z]*reference\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/reference.dtd"|' `grep -rl --include=*.xml --include=*.dita reference.dtd /gemfirexd-140/*`

RUN     sed --in-place --expression='s| *"[./a-z]*topic\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/topic.dtd"|' `grep -rl --include=*.xml --include=*.dita topic.dtd /gemfirexd-140/*`

RUN     sed --in-place --expression='s| *"[./a-z]*concept\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/concept.dtd"|' `grep -rl --include=*.xml --include=*.dita concept.dtd /gemfirexd-140/*`

RUN     sed --in-place --expression='s| *"[./a-z]*task\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/task.dtd"|' `grep -rl --include=*.xml --include=*.dita task.dtd /gemfirexd-140/*`

RUN     sed --in-place --expression='s| *"[./a-z]*ditabase\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/ditabase.dtd"|' `grep -rl --include=*.xml --include=*.dita ditabase.dtd /gemfirexd-140/*`

RUN     sed --in-place --expression='s| *"[./a-z]*generalTask\.dtd"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/generalTask.dtd"|' `grep -rl --include=*.xml --include=*.dita generalTask.dtd /gemfirexd-140/*`

ADD     gemfire_build.xml /dita-ot/gemfire_build.xml
RUN     yes  | ant -f gemfire_build.xml
