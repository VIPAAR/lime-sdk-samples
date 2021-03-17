Help Lightning - Android

# INTRODUCTION

Help Lightning is an Android application developed by Vipaar for
allowing people in remote applications to work on problems together in
real time in a mixed reality environment.

# SETUP

You will first need to make sure you are running the sample python
integration server. Please see the instructions in the
`../hlserver/README.md` file.

In the gradle.properties, add in the following lines to the end:

```
GALDR_HOST=http://192.168.1.55:8777
GALDR_API_KEY=your-api-key
```
Replace the `192.168.1.55` with the IP address of the machine running
the python server. Replace the `your-api-key` with an actual API Key
generated from the Developer section on https://helplightning.net/

# QUESTIONS

If you have questions about this application, please contact:

* Scott Wehby <scott.wehby@helplightning.com>
