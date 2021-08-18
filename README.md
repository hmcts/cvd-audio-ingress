# CVP Audio Ingress
## Deploys the CVP audio only ingress platform

This project is a tactical solution to provide audio recordings for online hearings. The project has been expedited due
to the Covid-19 outbreak and as such the design and implementation is subject to change in the future.

The main solution consists of 2 active-active loadbalanced Linux VMs running Wowza Streaming Engine 4.7.7 which then 
store the audio output in Azure Blob Storage. 

## Environments

The project can be deployed to the following 3 environments:

* Shared Services Sandbox - Used for dev work
* Shared Services Staging - Used as a pre-prod type environment and for end-to-end/load testing
* Shared Services Production

## Pipeline
There are some post deployment tests that run, which should clearly state what is wrong and be easy to know how to fix.
Below are some instructions for some of the tests.

1. `Check Blob Mounted` - If this failed then restart the VM or run the commands at the bottom of the `cloudconfig.tpl` file.

## Testing
Before starting testing, make sure the client IP(s) for the machines you are testing from is added to the 
`dev_source_address_prefixes` variable. This can be found in a variable group in Azure DevOps called `cvp-<env>`.

### Terraform Testing
You can run the plan command from your local by running the PowerShell command in `test/tf-plan.ps1`

This will generate a plan against the remote state file.

### Functional tests

1. Check that port 443 is responding with a valid SSL cert by opening the endpoint in your browser. (Smoke test candidate)

2. The following command streams a single file to Wowza and should get persisted to a folder in Azure Blob Storage called 
audiostream5.
```shell script
ffmpeg -re -i ./<local audio file> -c copy -f flv "rtmps://<host name for your wowza engine instance or the lb>:443/audiostream1 flashver=FMLE/3.0\20(compatible;\20FMSc/1.0) live=true pubUser=wowza playpath=<target filename>"
``` 

3. Load testing can be conducted on a Windows VM on Azure (Standard DS11 v2). It will require dotnet core installing on it.
Once installed you can download, build and run from this project: 
[https://github.com/hmcts/vh-performance-wowza](https://github.com/hmcts/vh-performance-wowza)

### End to End testing
You will require your own Virtual Meetin Room from Kinly to test with. The Staging environment should be used for testing 
and has their Dev environment IPs whitelisted already.

## Known issues
* The Wowza Engine Management UI doesn't seem to work when the Wowza Engine is configured with TLS (which this project 
is).
* Occasionally cloud-init will not complete properly. The quickest solution seems to be to reboot the VM to trigger cloud-init to run again.