# Prometheus Installation 

## Create the prometheus user:

```bash
sudo useradd -M -r -s /bin/false prometheus
```
## Create the prometheus directories:
```bash
sudo mkdir /etc/prometheus /var/lib/prometheus
```
## Download the pre-compiled binaries:
```bash
wget https://github.com/prometheus/prometheus/releases/download/v2.16.0/prometheus-2.16.0.linux-amd64.tar.gz
```
## Extract the binaries:
```bash
tar xzf prometheus-2.16.0.linux-amd64.tar.gz prometheus-2.16.0.linux-amd64/
```

## Move the files from the downloaded archive to the appropriate locations, and set ownership on these files and directories to the prometheus user:

```bash
sudo cp prometheus-2.16.0.linux-amd64/{prometheus,promtool} /usr/local/bin/
sudo chown prometheus:prometheus /usr/local/bin/{prometheus,promtool}
sudo cp -r prometheus-2.16.0.linux-amd64/{consoles,console_libraries} /etc/prometheus/
sudo cp prometheus-2.16.0.linux-amd64/prometheus.yml /etc/prometheus/prometheus.yml
sudo chown -R prometheus:prometheus /etc/prometheus
sudo chown prometheus:prometheus /var/lib/prometheus
```

## Run Prometheus in the foreground to make sure everything is set up correctly so far:

```bash
prometheus --config.file=/etc/prometheus/prometheus.yml
```

## In the output, we should see a message stating, "Server is ready to receive web requests."

Press Ctrl+C to stop the process.

# Configure Prometheus as a systemd Service

## Create a systemd unit file for Prometheus:
```bash
sudo vi /etc/systemd/system/prometheus.service
```
## Define the Prometheus service in the unit file:
```bash
[Unit]
Description=Prometheus Time Series Collection and Processing Server
Wants=network-online.target
After=network-online.target

[Service]
User=prometheus
Group=prometheus
Type=simple
ExecStart=/usr/local/bin/prometheus \
    --config.file /etc/prometheus/prometheus.yml \
    --storage.tsdb.path /var/lib/prometheus/ \
    --web.console.templates=/etc/prometheus/consoles \
    --web.console.libraries=/etc/prometheus/console_libraries

[Install]
WantedBy=multi-user.target
```
Save and exit the file by pressing Escape followed by wq!.

## Make sure systemd picks up the changes we made:
```bash
sudo systemctl daemon-reload
```
## Start the Prometheus service:
```bash
sudo systemctl start prometheus
```
## Enable the Prometheus service so it will automatically start at boot:
```bash
sudo systemctl enable prometheus
```
## Verify the Prometheus service is healthy:
```bash
sudo systemctl status prometheus
```
We should see its state is active (running).

Press Ctrl+C to stop the process.

Make an HTTP request to Prometheus to verify it is able to respond:
```bash
curl localhost:9090
```
The result should be <a href="/graph">Found</a>.

In a new browser tab, access Prometheus by navigating to http://<PROMETHEUS_SERVER_PUBLIC_IP>:9090 (replacing <PROMETHEUS_SERVER_PUBLIC_IP> with the IP listed on the lab page). We should then see the Prometheus expression browser. 

# Prometheus Configuration
* You can reload the config without restarting prometheus as follows:
```bash
sudo killall -HUP prometheus 
```

---
# Collecting Linux Server Metrics with Prometheus 

# Install and Configure Node Exporter on the JupyterHub Server

* Create a user and group that will be used to run Node Exporter:
```bash
[cloud_user@limedrop]$ sudo useradd -M -r -s /bin/false node_exporter
```
    
* Download the Node Exporter binary:

```bash
[cloud_user@limedrop]$ wget https://github.com/prometheus/node_exporter/releases/download/v0.18.1/node_exporter-0.18.1.linux-amd64.tar.gz
```
* Extract the Node Exporter binary:
```bash
[cloud_user@limedrop]$ tar xvfz node_exporter-0.18.1.linux-amd64.tar.gz
```
* Copy the Node Exporter binary to the appropriate location:
```bash
[cloud_user@limedrop]$ sudo cp node_exporter-0.18.1.linux-amd64/node_exporter /usr/local/bin/
```
* Set ownership on the Node Exporter binary:
```bash
[cloud_user@limedrop]$ sudo chown node_exporter:node_exporter /usr/local/bin/node_exporter
```
* Create a systemd unit file for Node Exporter:
```bash
[cloud_user@limedrop]$ sudo vi /etc/systemd/system/node_exporter.service
```
* Define the Node Exporter service in the unit file:
```bash
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
```
* Save and exit the file by pressing Escape followed by :wq!.

* Make sure systemd picks up the changes we made:
```bash
[cloud_user@limedrop]$ sudo systemctl daemon-reload
```
* Start the node_exporter service:
```bash
[cloud_user@limedrop]$ sudo systemctl start node_exporter
```
* Enable the node_exporter service so it will automatically start at boot:
```bash
[cloud_user@limedrop_web]$ sudo systemctl enable node_exporter
```
* Test that your Node Exporter is working by making a request to it from localhost:
```bash
[cloud_user@limedrop]$ curl localhost:9100/metrics
```
* You should see some metric data in response to this request.

## Configure Prometheus to Scrape Metrics from the LimeDrop Web Server

* Open a new terminal session.

* Log in to the Prometheus server:

* ssh cloud_user@<PROMETHEUS_PUBLIC_IP_ADDRESS>

* Edit the Prometheus config file:
```bash
[cloud_user@prometheus]$ sudo vi /etc/prometheus/prometheus.yml
```
* Locate the scrape_configs section and add the following beneath it (ensuring it's indented to align with the existing job_name section):
```yaml
- job_name: 'LimeDrop Web Server'
   static_configs:
   - targets: ['10.0.1.102:9100']
```

* Save and exit the file by pressing Escape followed by :wq!.

* Restart Prometheus to load the new config:

```bash
[cloud_user@prometheus]$ sudo systemctl restart prometheus
```

* Navigate to the Prometheus expression browser in your web browser using the public IP address of your Prometheus server: <PROMETHEUS_SERVER_PUBLIC_IP>:9090.

* In the expression field (the box at the top of the page), paste in the following query to verify you are able to get some metric data from the LimeDrop web server:

<p> node_filesystem_avail_bytes{job="LimeDrop Web Server"} </p>

Click Execute. We should then see several results.