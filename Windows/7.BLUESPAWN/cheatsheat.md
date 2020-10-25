### Mitigate Mode
4. Run the following from your Administrative Command Prompt to audit your system for the presence of many security settings
```cmd
.\BLUESPAWN-client-x64.exe --mitigate --action=audit
```
![BLUESPAWN in Action-Mitigate](https://user-images.githubusercontent.com/3931697/89669848-25e69900-d8ae-11ea-836d-1618d7377211.png)

### Hunt Mode
5. Run BLUESPAWN from the Administrative Command Prompt to hunt for malicious activity on the system
```cmd
.\BLUESPAWN-client-x64.exe --hunt -a Cursory --log=console,xml
```
![BLUESPAWN in Action-Hunt](https://user-images.githubusercontent.com/3931697/89669912-4878b200-d8ae-11ea-967b-03318468d711.png)

### Monitor Mode
6. Run BLUESPAWN from the Administrative Command Prompt to monitor for malicious activity on the system
```cmd
.\BLUESPAWN-client-x64.exe --monitor -a Cursory --log=console,xml
```
![BLUESPAWN in Action-Monitor](https://user-images.githubusercontent.com/3931697/89670008-752cc980-d8ae-11ea-8490-1e0473d5f3c6.png)
