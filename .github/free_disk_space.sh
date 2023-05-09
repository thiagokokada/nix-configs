#!/usr/bin/env bash
# Based on: https://github.com/apache/flink/blob/6dd75e1d39597d6482eb920a610b1ebc55f39458/tools/azure-pipelines/free_disk_space.sh

# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

echo "Listing 25 largest packages"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 25
df -h

echo "Removing large packages"
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '.*llvm.*'
sudo apt-get remove -y 'php.*'
sudo apt-get remove -y '^mongodb-.*'
sudo apt-get remove -y '^mysql-.*'
sudo apt-get remove -y '^temurin-.*'
sudo apt-get remove -y \
	azure-cli \
	google-cloud-sdk \
	hhvm \
	google-chrome-stable \
	microsoft-edge-stable \
	firefox \
	powershell \
	mono-devel \
	snapd \
	moby-containerd
sudo apt-get autoremove -y
sudo apt-get clean
df -h

echo "Removing large directories"
sudo rm -rf /usr/local/
df -h
