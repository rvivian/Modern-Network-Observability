import os
import sys
from netmiko import ConnectHandler

def netmiko_connect(device_type, host):
  """Connect to a device using Netmiko."""
  # Define the device to connect to
  device = {
    "device_type": device_type,
    "host": host,
    # Use environment variables for username and password
    "username": os.getenv("NETWORK_AGENT_USER"),
    "password": os.getenv("NETWORK_AGENT_PASSWORD"),
  }

  # Establish an SSH connection
  net_connect = ConnectHandler(**device)

  # Return the Netmiko connection object
  return net_connect

def influx_line_protocol(measurement, tags, fields):
  """Generate an InfluxDB line protocol string."""

  # Construct tags string
  tags_string = ""
  for key, value in tags.items():
    if value is not None:
      if isinstance(value, str):
        value = value.replace(" ", r"\ ")
      tags_string += f",{key}={value}"

  # Construct fields string
  fields_string = ""
  for key, value in fields.items():
    if fields_string:
      fields_string += ","
    if isinstance(value, bool):
      fields_string += (
        f"{key}=true" if value else f"{key}=false"
      )
    elif isinstance(value, int):
      fields_string += f"{key}={value}i"
    elif isinstance(value, float):
      fields_string += f"{key}={value}"
    elif isinstance(value, str):
      value = value.replace(" ", r"\ ")
      fields_string += f'{key}="{value}"'
    else:
      fields_string += f"{key}={value}"

  return f"{measurement}{tags_string} {fields_string}"

def convert_state(state):
  """Convert the state to a more readable format."""
  state_mapping = {
    "Estab": "ESTABLISHED",
    "Idle(NoIf)": "IDLE",
    "Idle": "IDLE",
    "Connect": "CONNECT",
    "Active": "ACTIVE",
    "opensent": "OPENSENT",
    "openconfirm": "OPENCONFIRM"
  }
  # Return mapped state or original ste in uppercase
  return state_mapping.get(state, state.upper())

def main(device_type, host):
  """BGP neight data in Influx line protocol format."""
  # Connect to device (1)
  net_connect = netmiko_connect(device_type, host)

  # Execute command on device (2)
  output = net_connect.send_command(
    "show ip bgp summary", use_textfsm=True
  )

  # Process BGP neighbors data (3)
  for neighbor in output:
    measurement = "bgp"
    tags = {
      "neighbor": neighbor["bgp_neigh"],
      "neighbor_asn": neighbor["neigh_as"],
      "vrf": neighbor["vrf"],
      "device": host,
    }
    # Get mapped state (4)
    state = convert_state(neighbor["state"])
    fields = {
      "prefixes_received": neighbor["state_pfxrcd"],
      "prefixes_accepted": neighbor["state_pfxacc"],
      "neighbor_state": state,
    }
    # Generate line protocol string (5)
    line_protocol = influx_line_protocol(
      measurement, tags, fields
    )
    # Print line protocol string (6)
    print(line_protocol)

if __name__ == "__main__":
  # Get the device type and host from the command line
  device_type = sys.argv[1]
  host = sys.argv[2]
  # Run your script
  main(device_type, host)