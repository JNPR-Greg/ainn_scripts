# AINN Scripts
This is a repo for setting up the initial conditions for Apstra when running
Juniper's _AI Native Now_ Test Drive sessions.  Currently, this includes a
shell script that deploys the following components in Apstra via the REST API:
- Logical Device:  4x100GE (represents a storage host)
- Device Profile: Arista DCS-7060DX5-64S (notional only)
- Interface Map:  AOS-64x400-2 to DCS-7060DX5-64S
- Interface Map:  AOS-64x400-2 to QFX5230-64CD
- Rack Type:  36-host compute rack
- Rack Type:  12-host storage rack
- Rack Type:  Open services rack (2x switches, no hosts)

All componets can be found in the `./templates` subdirectory.

To use this script, grab the `ainn-scripts.tar` file and extract it on your
Apstra server.  Then run the command `bash ./add-ainn-components.sh` from the
directory where you placed the .tar file.