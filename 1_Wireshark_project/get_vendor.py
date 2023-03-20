import urllib.request
import urllib.error
from time import sleep

def get_vendor_from_mac(mac: bytes) -> str:
    """Get vendor from MAC address.

    Args:
        mac (bytes): MAC address.

    Returns:
        str: Vendor.
    """
    retry = True
    vendor = b''

    # Try getting the data.
    while retry:
        try:
            vendor = urllib.request.urlopen("https://api.macvendors.com/" + mac.hex()).read()
        except urllib.error.HTTPError as e:
            # If the error code is 429 (too many requests), retry after a while.
            if e.getcode() == 429:
                retry = True
                sleep(2)
            else:
                retry = False
        else:
            retry = False

    # Return decoded vendor as string.
    return vendor.decode("utf-8")
