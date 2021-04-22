FROM adoptopenjdk/openjdk15:alpine-jre

RUN apk add --no-cache mariadb-dev mariadb-client curl bash

ARG HADOOP_VERSION=2.6.1
# Download and extract the Hadoop binary package.
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
# RUN curl https://apachemirror.wuchna.com/hadoop/common/hadoop-2.10.1/hadoop-2.10.1.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s "/opt/hadoop-$HADOOP_VERSION" /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc 

# Add awssdk jars to the classpath
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Set hadoop environment variables. 
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/spark/bin:/opt/hadoop/bin:${PATH}"

ARG HIVE_VERSION=2.1.1
# Download and install the standalone metastore binary.

RUN curl "https://archive.apache.org/dist/hive/hive-${HIVE_VERSION}/apache-hive-${HIVE_VERSION}-bin.tar.gz" \
	| tar xvz -C /opt/ \
	&& ln -s "/opt/apache-hive-${HIVE_VERSION}-bin" /opt/hive

ENV HIVE_HOME="/opt/hive"
ENV HIVE_CONF_DIR="${HIVE_HOME}/conf"

# Download and install the mysql connector.
# mariadb/mysql odbc/jdbc lib package is still WIP in alpine, installing platform independent binary
ARG MYSQL_DRV_VERSION=8.0.18
RUN mkdir -p /usr/share/java \
    && curl -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRV_VERSION}.tar.gz" \
    | tar -xzC /usr/share/java/ \
    && echo "export CLASSPATH=/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar:$CLASSPATH" >> /etc/profile \
    && ln -s "/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar" /opt/hadoop/share/hadoop/common/lib/ \
    && ln -s "/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar" /opt/hive/lib/ 

COPY files/metastore-site.xml HIVE_CONF_DIRhive-site.xml
COPY files/core-site.xml /opt/hive/conf/core-site.xml
COPY hive2.1/entrypoint.sh /entrypoint.sh

WORKDIR ${HIVE_HOME}

EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
