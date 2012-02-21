default[:zookeeper][:tickTime] = 2000
default[:zookeeper][:initLimit] = 10
default[:zookeeper][:syncLimit] = 5
default[:zookeeper][:dataDir] = "/var/lib/zookeeper"
default[:zookeeper][:clientPort] = 2181
default[:zookeeper][:servers] = ["localhost"]
default[:zookeeper][:leaderPort] = 2888
default[:zookeeper][:electionPort] = 3888
