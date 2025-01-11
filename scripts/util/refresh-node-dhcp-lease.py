#!/usr/bin/env python3
import json
import argparse
import subprocess
import sys

"""
This script processes a JSON file containing node information from Terraform output.
It identifies nodes where the current DHCP lease does not match the assigned address
and releases the DHCP lease on those nodes via SSH.

Example JSON structure:
{
  "xx:xx:xx:xx:xx:xx": {
    "current_lease": "10.70.30.13",
    "expected_lease": "10.70.30.13"
  },
  "yy:yy:yy:yy:yy:yy": {
    "current_lease": "10.70.30.11",
    "expected_lease": "10.70.30.12"
  }
}
"""

def run_ssh_command(ip, command="dhclient -r"):
    """
    Executes a DHCP release command on a remote node via SSH.

    :param ip: IP address of the remote node
    :param command: Command to execute (default is 'dhclient -r')
    :return: Tuple of (stdout, stderr)
    """
    ssh_command = ["ssh", f"root@{ip}", command]
    try:
        result = subprocess.run(
            ssh_command,
            check=True,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True
        )
        return result.stdout, result.stderr
    except subprocess.CalledProcessError as e:
        return e.stdout, e.stderr

def parse_args():
    parser = argparse.ArgumentParser(
        prog='refresh-node-dhcp-lease',
        description='Uses Terraform output to refresh DHCP leases on nodes where necessary.'
    )
    parser.add_argument("terraform_output_file", type=str, help="Path to the Terraform output JSON file.")
    return parser.parse_args()

def main():
    args = parse_args()
    terraform_file_path = args.terraform_output_file

    try:
        with open(terraform_file_path, 'r', encoding="utf-8") as f:
            node_leases_map = json.load(f)
    except FileNotFoundError:
        print(f"Error: File '{terraform_file_path}' not found.", file=sys.stderr)
        sys.exit(1)
    except json.JSONDecodeError as e:
        print(f"Error: Failed to parse JSON file. {e}", file=sys.stderr)
        sys.exit(1)

    expired_node_ips = []
    for node, details in node_leases_map.items():
        expected_lease = details.get("expected_lease")
        current_lease = details.get("current_lease")
        if expected_lease != current_lease:
            expired_node_ips.append(current_lease)
            print(f"Node '{node}' has mismatched lease: {current_lease} != {expected_lease}")

    if not expired_node_ips:
        print("No nodes require DHCP lease renewal.")
        sys.exit(0)

    for ip in expired_node_ips:
        print(f"Releasing DHCP lease on {ip}...")
        stdout, stderr = run_ssh_command(ip, "dhclient -r && dhclient")

        if stdout:
            print(f"Output from {ip}:\n{stdout}")
        if stderr:
            print(f"Error from {ip}:\n{stderr}")

if __name__ == "__main__":
    main()

