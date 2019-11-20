# oozie_rerun
script to rerun Oozie workflow submitted by Hue for Cloudera system

## Installation
1. Login to the server that Oozie installed
2. switch user to hue

   ``` bash
   sudo su -s /bin/bash hue
   ```

3. clone

   ``` bash
   git clone https://github.com/peepeepopapapeepeepo/oozie_rerun.git
   ```

## Usage
1. Login to the server that Oozie installed
2. switch user to hue

   ``` bash
   sudo su -s /bin/bash hue
   ```
3. go to installtion directory

   ``` bash
   cd oozie_rerun
   ```

4. run this script

   ``` bash
   ./oozie_rerun "<Coordinator Name>" "<since datetime in format yyyy-MM-dd'T'HH:mm'Z' e.g. 2019-01-01T00:00Z>"
   ```
