#!/bin/bash

# sudo crontab -e
# @reboot /home/jenkins/bin/startJenkinsAgent.sh

java -jar /home/jenkins/node1/agent.jar -jnlpUrl http://localhost:8080/computer/agent1/jenkins-agent.jnlp -secret 428738c20cf21f28a2a30e1ead9434995a4185615b40a5ff60a61d8642127693 -workDir "/home/jenkins/node1"



