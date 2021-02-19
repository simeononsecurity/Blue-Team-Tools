ET OPEN Ruleset Download Instructions
=====================================

To download your OPEN ruleset use the following url format

Suricata: <https://rules.emergingthreats.net/open/suricata-$version/emerging.rules.tar.gz>

Snort: <https://rules.emergingthreats.net/open/snort-$version/emerging.rules.tar.gz>

`$version` above is customer supplied. It is the version of your Suricata or Snort IDS.

Examples:

-   <https://rules.emergingthreats.net/open/suricata-5.0.0/emerging.rules.tar.gz>
-   <https://rules.emergingthreats.net/open/snort-2.9.7.0/emerging.rules.tar.gz>

Changelogs: <http://rules.emergingthreats.net/changelogs/>

Rule Downloaders
----------------

### Suricata-Update

Suricata-Update is the preferred method of managing Suricata rule files.  Please see instructions here:

[https://github.com/OISF/suricata-update](https://github.com/OISF/suricata-update#suricata-update)

### Pulled Pork

If you use Pulled Pork add this to your configuration:

```
rule_url=https://rules.emergingthreats.net/|emerging.rules.tar.gz|open
```

Pulled Pork also has to be told you are running Suricata by using -S

For example, if running Suricata 4.0.3:

```
$ ./pulledpork.pl -S suricata-4.0.3 -c /path/to/pulledpork.conf
```

Note that Pulled Pork `< 0.7.1` doesn't work out of the box with Suricata ET rules.  Please use the latest version here if having issues: <https://github.com/shirkdog/pulledpork>

### Best practices

-   *Updates:*  ET is updated once daily on weekdays, and occasionally with out of band updates.  We recommend that you configure your updater to download the ruleset once daily.  If you want to check more frequently (e.g. hourly), we recommend that you first check the <https://rules.emergingthreats.net/version.txt> file which is incremented each time we publish a new version of the ruleset.  If the version has incremented from you last download, then that is an indication that a new version is available.

-   We do not recommend downloading the ruleset more frequently than once per hour as this introduces significant bandwidth costs and is inefficient.

-   *Different Formats:*  We provide the ET ruleset in a few different formats to make it easily accessible.  These are redundant and updated at the same time, so you do not need to download each version of the ruleset, but instead, pick which approach fits your use case and stick with that. For instance, we publish the rules per category in the `rules` directory, or you can download the full rulesets as either `tar.gz` or `zip`, but they all contain the same content.

-   *Validating Downloads:*  ET provides MD5 hash files for each of the ruleset downloads to validate that the download was successful.  E.g `emerging.rules.zip` has an accompanying file called `emerging.rules.zip.md5` containing the MD5 hash of the zip file.

Supported Engine Versions
-------------------------

Suricata

-   Suricata 6.0.x (leverages Suricata 5 ruleset)
-   Suricata 5.0.x
-   Suricata 4.1.x
-   Suricata 4.0.x

Snort

-   2.9.x

Support
-------

Feedback Tool

To access the Feedback Tool web interface please visit: <https://feedback.emergingthreats.net/>. For instructions on registration and usage for the Feedback Tool API please visit: <https://feedback.emergingthreats.net/help>

Mailing lists

Pro customers can also ask questions on our mailing list: <https://lists.emergingthreats.net/mailman/listinfo/>

Twitter

<https://twitter.com/ET_Labs>

IRC

[#emerging-threats](https://kiwiirc.com/client/irc.freenode.net/?nick=user1%7C?#emerging-threats) on [Freenode](http://freenode.net/)
