Linkedin2.0
===========

Linkedin with OAuth 2.0

This is a simple project to use LinkedIn with OAuth 2.0.
To use it, you will have to add the following constants:

<pre>
#define LK_API_KEY (@"API KEY")
#define LK_API_SECRET (@"API SECRET")
#define LK_API_STATE (@"RANDOM")
#define LK_API_REDIRECT (@"REDIRECT URL")
#define LK_API_URL (@"https://www.linkedin.com/uas/oauth2/")
</pre>

The API KEY and API SECRET can be found at the following address: https://www.linkedin.com/secure/developer. You will need to create a new application.
The API STATE is a random string. You can put capital letters, numbers, or anything you like.
The REDIRECT URL is actually pretty useless on an iDevice. For example, you can put: https://github.com/ and it will work.

You are free to use this code however you want.
Have fun. :)
