# Windows Cheat Sheet

## Useful Windows variables

```
echo %LOGONSERVER%
echo %USERDOMAIN%
```

## WMIC Remote
WMIC commands can be run on a remote computer with `/node:SERVERNAME`, like so:

```
wmic /node:FILESERVER1 computersystem get domain
```

I (think) multiple servers can be put in as a comma-delimited list, up to eight.

## WMIC formatting output
WMIC formats with the `/format`:

```
wmic useraccount /format:list
```

Valid formats are `list`, `csv`, `htable` for HTML, `xml`, and `xsl` for.. XSL?.
WMIC outputs to a file with `/output`:

```
wmic /output:C:\\outfile.csv useraccount /format:csv 
```

It looks like often there is an error if the order of arguments is changed, ie
if `/output` is not in front with `/format` following the command. I don't know,
play around with it.

## Command Cheat Sheet
Get all users:
```wmic useraccount```

Get domain:
```wmic computersystem get domain```

Get startup programs:
```wmic startup```

For more, see [this page][wmic].

## Using `clip`
`clip` can easily copy to the clipboard:

```
C:\\> tasklist.exe | clip
```

## Firewall 

Network Discovery

* LLMR
* SSDP
* UPnP
* WSD EventsSecure

Remote Assistance

PNRP-Out

Disable:

* Windows Media Player
* Remote Assistance
* nslookup

## Important Programs
lusrmgr.msc
services.msc
msconfig

IIS Manager C:\\inetpub

[net-ref]: https://technet.microsoft.com/en-us/library/bb490949.aspx
[env]: http://environmentvariables.org/
[wmic]: https://projectzme.wordpress.com/2013/03/14/windows-tip-wmic-command-cheat-sheet/
[win-RA]: https://www.urtech.ca/2011/05/everything-i-know-about-windows-remote-assistance-easy-assist-and-pnrp-peer-name-resolution-protocol/
