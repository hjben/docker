FROM hjben/centos-openjdk:11
MAINTAINER hjben <hj.ben.kim@gmail.com>

ENV HADOOP_HOME /opt/hadoop

RUN if [ ! -e /usr/bin/python ]; then ln -s /usr/bin/python2.7 /usr/bin/python; fi

RUN wget https://archive.apache.org/dist/hadoop/core/hadoop-3.2.2/hadoop-3.2.2.tar.gz && \ 
    tar -xzf hadoop-3.2.2.tar.gz && \
    rm -f hadoop-3.2.2.tar.gz && \
    mv hadoop-3.2.2 $HADOOP_HOME && \
    for user in hadoop hdfs yarn mapred; do \
         useradd -U -M -d /opt/hadoop/ --shell /bin/bash ${user}; \
    done && \

    for user in root hdfs yarn mapred; do \
         usermod -G hadoop ${user}; \
    done && \

    echo "export JAVA_HOME=$JAVA_HOME" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_DATANODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_NAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export HDFS_SECONDARYNAMENODE_USER=root" >> $HADOOP_HOME/etc/hadoop/hadoop-env.sh && \
    echo "export YARN_RESOURCEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "export YARN_NODEMANAGER_USER=root" >> $HADOOP_HOME/etc/hadoop/yarn-env.sh && \
    echo "PATH=$PATH:$HADOOP_HOME/bin" >> ~/.bashrc

RUN ssh-keygen -t rsa -P '' -f ~/.ssh/id_rsa && \
    cat ~/.ssh/id_rsa.pub >> ~/.ssh/authorized_keys && \
    chmod 0600 ~/.ssh/authorized_keys

ADD *xml $HADOOP_HOME/etc/hadoop/
ADD workers $HADOOP_HOME/etc/hadoop/workers

ADD ssh_config /root/.ssh/config
ADD *start-all.sh /
RUN chmod 755 *start-all.sh
RUN mkdir $HADOOP_HOME/logs

EXPOSE 50010 50020 50070 50075 50090 8020 9000
EXPOSE 10020 19888
EXPOSE 8088 9870 9864 19888 8042 8888

ENTRYPOINT ["/usr/sbin/init"]
