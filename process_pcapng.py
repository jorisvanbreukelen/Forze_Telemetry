from pcapng import FileScanner
from pcapng.exceptions import TruncatedFile
from datetime import datetime
from typing import List, Tuple, FrozenSet
import urllib.request;
import urllib.error;
import numpy as np;
import csv;
import os;

from time import sleep;


CSV_FILE_NAME = "data"


def format_mac(mac: bytes) -> str:
    """Formats MAC address into xx:xx:xx:xx:xx.

    Args:
        mac (bytes): MAC address in bytes.

    Returns:
        str: Formatted MAC address.
    """
    mac_hex = mac.hex()
    n = 2

    return ':'.join([mac_hex[i:i+n] for i in range(0, len(mac_hex), n)])


def process_file(file_name: str) -> List[Tuple[str, float, int, int]]:
    """Process a single file and return filtered entries

    Args:
        file_name (str): Name of the file.

    Returns:
        List[Tuple[str, float, int, int]]: Entry containing MAC, timestamp, signal quality and channel frequency.
    """
    entries = []

    # Open the file.
    with open(file_name, 'rb') as fp:
        scanner = FileScanner(fp)
        print("Processing", file_name)
        try:
            # Iterate over pcap-ng blocks.
            for block in scanner:
                # Not all blocks have packet data, so check here.
                if hasattr(block, "packet_data"):
                    # Check if it is a Probe Request
                    if block.packet_data[26:28] == b'\x40\x00':
                        # Get mac address.
                        mac_address = block.packet_data[36:42]

                        # Check if it is not the raspberry pi.
                        if mac_address != b'\xb8\x27\xeb\xac\xea\xef':
                            # Get signal quality.
                            signal_quality = int.from_bytes(block.packet_data[20:22], "little")
                            # Get channel frequency.
                            channel_frequency = int.from_bytes(block.packet_data[14:16], "little")

                            # Append information to entries list.
                            entries.append((format_mac(mac_address), block.timestamp, signal_quality, channel_frequency))
        except ValueError:
            print("corrupt file:", file_name)
        except TruncatedFile:
            print("corrupt file:", file_name)
    return entries


def main():
    """Entry point of program.
    """
    # Loop over all files and process them.
    main_directory = '/content/drive/MyDrive/Wireshark data'

    # iterate over directories in that main directory
    for j, d in enumerate(os.listdir(main_directory)):
      directory = os.path.join(main_directory, d)
      if j < 2:
        continue
      # Write upper row in CSV.
      csv_file_name = CSV_FILE_NAME + "_" + d + ".csv"
      with open(csv_file_name, 'w', newline='') as file:
        writer = csv.writer(file)
        writer.writerow(["MAC", "Timestamp", "Signal Quality", "Channel Frequency"])

      # iterate over files in that directory
      for i, f in enumerate(sorted(os.listdir(directory), key=lambda t: os.stat(os.path.join(directory, t)).st_mtime)):
        filename = os.path.join(directory, f)

        # checking if it is a file
        if os.path.isfile(filename):
          # Process file (filter data).
          entries = process_file(filename)

          # Write data to csv for later processing.
          with open(csv_file_name, 'a', newline='') as file:
            writer = csv.writer(file)

            for (m, t, s, c) in sorted(entries, key=lambda entry: entry[1]):
              writer.writerow([m, t, s, c])


if __name__ == "__main__":
    main()