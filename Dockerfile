# DOCKER-VERSION 1.2.0

# base
FROM    ubuntu:14.10
RUN     apt-get update

# Install Vim, for debugging. TODO remove when done.
RUN     apt-get install -qq vim

RUN     apt-get install -qq git

# Install Oracle JDK (openjdk doesn't cut it)
RUN     apt-get install -qq software-properties-common
RUN     add-apt-repository ppa:webupd8team/java
RUN     apt-get update
RUN     echo oracle-java7-installer shared/accepted-oracle-license-v1-1 select true | /usr/bin/debconf-set-selections
RUN     apt-get install -qq oracle-java7-installer
RUN     apt-get install -qq oracle-java7-set-default
RUN     apt-get install -qq ant

# Install DITA
RUN     git clone https://github.com/dita-ot/dita-ot.git
WORKDIR dita-ot
RUN     git submodule update --init --recursive
RUN 	ant

# These fail on e.g. openjdk
RUN     ant test

ENV     CLASSPATH /dita-ot/src/main/:/dita-ot/src/main/lib/:/dita-ot/src/main/lib/dost.jar:/dita-ot/src/main/lib/xercesImpl.jar:/dita-ot/src/main/lib/xml-apis.jar:/dita-ot/src/main/lib/commons-codec-1.4.jar:/dita-ot/src/main/lib/saxon/saxon9-dom.jar:/dita-ot/src/main/lib/saxon/saxon9.jar:/dita-ot/src/main/lib/resolver.jar:/dita-ot/src/main/lib/icu4j.jar:/dita-ot/src/main/lib/commons-io.jar:/dita-ot/src/main/resources

ADD     gemfirexd-140 /gemfirexd-140

ADD     convert_utf16_to_utf8 /usr/local/bin/convert_utf16_to_utf8
RUN     convert_utf16_to_utf8 /gemfirexd-140

# Replace relative links to DTDs with absolute paths. Look away now.
RUN     sed --in-place --regexp-extended --expression='s> *"[./a-z]*(reference|topic|concept|task|generalTask)\.dtd"> "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/\1.dtd">' `grep -rl --include=*.xml --include=*.dita -E '(reference|topic|concept|task|generalTask).dtd' /gemfirexd-140/*`

RUN     sed --in-place --regexp-extended --expression='s| *"[./a-z]*dita(base\.dtd)?"| "/dita-ot/src/main/plugins/org.oasis-open.dita.v1_2/dtd/technicalContent/dtd/ditabase.dtd"|' `grep -rl --include=*.xml --include=*.dita -E "dita(base)?.dtd" /gemfirexd-140/*`

ADD     gemfire_build.xml /dita-ot/gemfire_build.xml
RUN     ant -f gemfire_build.xml
