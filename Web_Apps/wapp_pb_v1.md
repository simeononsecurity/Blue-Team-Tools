_To Do_

- Check out: https://cheatsheetseries.owasp.org/ and narrow down list of potential actions

XSS or cross site scripting vulnerabilities allow an attacker to inject a payload into a webpage, usually by
accepting input from users without any validation.
Basic XSS Test:
<alert> 42 </alert>
This can be used as a basic way of testing a website's input fields. Will not identify more complex xss vulns
Remember, the website's url can sometimes be an input field.

CSRF or cross site request forgery is what happens when an attacker tricks an end user into performing certain
actions this could be as simple as crafting a link to a webpage where the user has an open session and when the
maliscious link is clicked, the user's browser is tricked into performing somehting using that session.
