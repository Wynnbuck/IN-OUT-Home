<h3>Building ARP Scan Docker Image</h3>
<h2>Create the <code>Project Folder</code></h2>

```
mkdir arp-tracker # Note this can be changed to whatever you would like to call project folder 
cd arp-scan 
```

<h2>Create<code>Dockerfile</code></h2>

```
FROM debian:stable-slim

RUN apt-get update && \
    apt-get install -y arp-scan iproute2 curl && \
    apt-get clean

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
```

<h2>Create <code>entrypoint.sh</code></h2>

```
#!/bin/bash

# Ensure output folder exists
mkdir -p /output

# Run arp-scan and output results
arp-scan --interface=eth0 --localnet > /output/scan.txt
```

<h2>Make <code>entrypoint.sh</code> Executable</h2>

```
chmod +x entrypoint.sh
```

<h2>Make the Docker Image</h2>

Upon completion of all above steps you want to then build the Docker image. Note this command is to be just ran within the project folder you orginally created in the beginning of this section. 

```
docker build -t arp-tracker .
```
If you would like to verify that the image was created; in the terminal simply code
```
docker images
```
If not a root user place <code>sudo</code> in front of the command. 
