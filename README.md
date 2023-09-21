# aws-vpn-keepalive  
Keepalive script for AWS site-to-site VPNs  
  
  
Usage:  
Arg 1 is VPN ID  
Arg 2 is the outside IP of the tunnel you want to keep Up.  
`./vpn.sh vpn-00008a111111e 69.169.269.69`  

Many VPNs in Parallel:  
```
parallel --ungroup ./vpn.sh ::: "vpn-00008a111111e" "vpn-111118a222222e" :::+ "69.169.269.69" "69.1.2.69"
or
parallel -J10 --ungroup ./vpn.sh ::: `cat vpns.txt`
or
parallel -J20 --ungroup ./vpn.sh ::: < vpns.txt
```  

where vpns.txt contains:  
```
vpn-00008a111111e
vpn-111118a222222e
:::+
69.169.269.69
69.1.2.69
```

By default, Parallel will run 1 job per CPU core, so if you have 4 CPU cores and 10 VPNs to keepalive, only 4 will be processed unless you specify `-j10` or a number higher than the number of VPNs.

`:::+` as the separator between the two sets of arguments tells Parallel to match up the first ID with the first IP, second ID with second IP and so on.. This behavior can be changed if you need to keep both tunnels up and match 1 ID with 2 IPs. More info: https://www.gnu.org/software/parallel/parallel_tutorial.html#input-sources
