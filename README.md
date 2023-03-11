# Forze_Telemetry

## Data files

The raw Wireshark data can be found on [Google Drive](https://drive.google.com/drive/folders/1Cb4pbsrC22HiTNGSSF8P4qDW4SQYZVTE?usp=sharing).

## Data processing

1. `process_pcapng.py` uses the `[python-pcapng](https://pypi.org/project/python-pcapng/)` package to filter the raw Wireshark data. This is meant to be used with the Google Drive data.
2. `process_csv.py` uses the `csv` module to move unique MAC addresses into time-sliced bins.
3. `plot_data.py` plots the data.

## Unused files

- `get_vendor.py` can be used to get the MAC address vendor. This was too slow for us so we opted not to use it.
