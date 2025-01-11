# Setting up network

This project assumes that both all routers and switches have been set up with a username and password.


The network infrastructure is organized in the following diagram:


![Diagram of homelab infrastructure](./resources/homelab_network_drawing.png)

A minor setup of the admin and users for each router is required before the following next step.

## Setting Up Default Core Router
The core router of the diagram (RB5009UPr+S+) needs to be manually set up before it is able to be set up via terraform. No default configuration will be saved, but be sure to set a password. To do the setup the file in `./scripts/default_core_router_setup.rsc` needs to be uploaded to the router via WebFig after initial setup. Afterwards, to reset the default config and override with our custom implementation using the following command.


```rsc
/system reset-configuration no-defaults=yes keep-users=yes run-after-reset="default_core_router_setup.rsc"
```

Once the configuration is finished, the following ports should be configured for specific devices.
* `ether1`: configured for wan.
* `ether3`: configured to be utilized by the access point.
* `ether4`: configured to be utliized by a device used for a tailscale subnet router.
* `sfp-sfpplus1`: configured to be utlized by the Homelab Router bridge.

## Setting Up Tailscale Subnet Router Device

The 'ether4' interface is set up for a single device to allow access throughout VLAN30 and base network to allow for 
configuration to be deployed via code. This is using tailscale subnet router vpn capabilities. The node connected to this port
must be configured to be a subnet router. Once an auth key is acquired, you can use the commands below. More docs can be found [here](https://tailscale.com/kb/1019/subnets).

```bash
# Install Tailscale. Auth key can be obtained on their website
curl -fsSL https://tailscale.com/install.sh | sh

# Follow commands to enable ip forwarding
echo 'net.ipv4.ip_forward = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
echo 'net.ipv6.conf.all.forwarding = 1' | sudo tee -a /etc/sysctl.d/99-tailscale.conf
sudo sysctl -p /etc/sysctl.d/99-tailscale.conf

# Advertise the routes to the base, vlan30, vlan40 networks
sudo tailscale up --advertise-routes=10.70.0.0/24,10.70.30.0/24,10.70.40.0/24  --advertise-exit-node --auth-key=tskey-auth-xxxxxxxxxxx-xxxxxxxxxxxxx
```

## Enabling Cert for secure ssl access

In order to get rid of the "site not trusted" warnings, you need to enable the cert in your local machine.

First you need to export then download the certs from the router via WebFig or WinBox


```rsc
/certificate export ssl-web-management export-passphrase=""
```

Once downloaded do the following depending on your operating system:

__MAC OS__
1. Download the certificate to your Mac.
2. Double-click the certificate file to open Keychain Access.
3. In the Keychain Access window, drag the certificate to the System keychain.
4. Set the certificate to Always Trust when prompted.
5. Restart your browser or system.

After restarting, you should be able to access the site securely via https.

## Setting Up Homelab Router
Like the Core Router, the homelab router of the diagram (CR310-8G+2S+in) needs to be manually set up before it is able to be set up via terraform. No default configuration will be saved, but be sure to set a password. To do the setup the file in `./scripts/default_homelab_router_setup.rsc` needs to be uploaded to the router via WebFig after initial setup. Afterwards, to reset the default config and override with our custom implementation using the following command. This router is setup to be a simple bridge to the core router. Therefore most things like dhcp leases, vlans, and firewall rules should be handled by core router. This router should be connected via the `sfp-sfpplus1` port.


```rsc
/system reset-configuration no-defaults=yes keep-users=yes run-after-reset="default_homelab_router_setup.rsc"
```

## Setting up the Homelab Nodes

After all this is manually set up, you can continue to set up the [homelab nodes](./setting_up_nodes.md)
