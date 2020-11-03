**SSH Hardening Script**

Shane Sexton

This is a  script to automate the hardening of SSH servers. It makes
several common changes to sshd_config to make SSH less vulnerable to
attackers. If desired, it backs up the original sshd_conf to the folder the
script is run from. It can also update SELinux and FirewallD rules.

Syntax: "sudo ssh_harden.sh i" for interactive mode or "sudo ssh_harden.sh q"for quick mode

If run in quick mode, this script will do the following:

-Back up sshd_config to current directory

-Disable protocol 1

-Disable PermitRootLogin

-Allow user to change SSH port (and update SELinux/FirewallD to that port)

-Allow user to change maximum authentication attempts

-Disable PermitEmptyPasswords

-Allow user to reduce login gracetime

-Disable PasswordAuthentication *(NOTE: Run in interactive mode and don't disable passwords if you don't have a keypair set up!!)*

-Disable Rhosts

-Set a warning banner
