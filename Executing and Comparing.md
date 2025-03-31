<h2>Running The Code</h2>
<h3>Executing</h3>
<p>Now that we have the Docker project setup and the files contained within the Docker container, we must execute.</p>
<p>Execution of just the ARP scan alone allows us to compare the MAC addresses of our devices to specify which devices we want to monitor</p>
<p>The MAC addresses of our devices will have to be placed in our scan tool to compare lists for notification of change.</p>

<h2>Run The Container</h2>

```
docker run --rm \
  --net=host \
  --cap-add=NET_RAW \
  --cap-add=NET_ADMIN \
  -v $PWD/output:/output \
  arp-tracker
```
<p>At this point you should see a list of MAC addresses on your network. Take note of the ones in which you would like to monitor. The MAC addresses of the devices can be found within the devices with some digging, this is for if the presented MAC addresses are unclear for correlated devices.</p>

<h2>Create a Comparison Script</h2>
<p>Name this script whatever you would like, in this example I have the script named <code>notify.sh</code></p>
<p>Make sure to replace the <code>YOUR_PUSHOVER_APP_TOKEN</code> and <code>YOUR_PUSHOVER_USER_KEY</code> with your pushover information. </p>
