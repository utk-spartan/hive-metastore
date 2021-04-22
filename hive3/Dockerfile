FROM adoptopenjdk/openjdk15:alpine-jre

RUN apk add --no-cache mariadb-dev mariadb-client curl bash

ARG HADOOP_VERSION=3.2.0
# Download and extract the Hadoop binary package.
RUN curl https://archive.apache.org/dist/hadoop/core/hadoop-$HADOOP_VERSION/hadoop-$HADOOP_VERSION.tar.gz \
	| tar xvz -C /opt/  \
	&& ln -s "/opt/hadoop-$HADOOP_VERSION" /opt/hadoop \
	&& rm -r /opt/hadoop/share/doc 

# Add awssdk jars to the classpath
RUN ln -s /opt/hadoop/share/hadoop/tools/lib/hadoop-aws* /opt/hadoop/share/hadoop/common/lib/ && \
    ln -s /opt/hadoop/share/hadoop/tools/lib/aws-java-sdk* /opt/hadoop/share/hadoop/common/lib/

# Set hadoop environment variables. 
ENV HADOOP_HOME="/opt/hadoop"
ENV PATH="/opt/spark/bin:/opt/hadoop/bin:${PATH}"

ARG HIVE_METASTORE_VERSION=3.0.0
# Download and install the standalone metastore binary.

RUN curl "https://archive.apache.org/dist/hive/hive-standalone-metastore-${HIVE_METASTORE_VERSION}/hive-standalone-metastore-${HIVE_METASTORE_VERSION}-bin.tar.gz" \
	| tar xvz -C /opt/ \
	&& ln -s "/opt/apache-hive-metastore-${HIVE_METASTORE_VERSION}-bin" /opt/hive-metastore

# Download and install the mysql connector.
# mariadb/mysql odbc/jdbc lib package is still WIP in alpine, installing platform independent binary
ARG MYSQL_DRV_VERSION=8.0.18
RUN mkdir -p /usr/share/java \
    && curl -SL "https://dev.mysql.com/get/Downloads/Connector-J/mysql-connector-java-${MYSQL_DRV_VERSION}.tar.gz" \
    | tar -xzC /usr/share/java/ \
    && echo "export CLASSPATH=/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar:$CLASSPATH" >> /etc/profile \
    && ln -s "/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar" /opt/hadoop/share/hadoop/common/lib/ \
    && ln -s "/usr/share/java/mysql-connector-java-${MYSQL_DRV_VERSION}/mysql-connector-java-${MYSQL_DRV_VERSION}.jar" /opt/hive-metastore/lib/ 

COPY files/metastore-site.xml /opt/hive-metastore/conf/
COPY files/core-site.xml /opt/hadoop/etc/hadoop/
COPY entrypoint.sh /entrypoint.sh


EXPOSE 8080
ENTRYPOINT ["/entrypoint.sh"]
