# Envy
Envy is a [POSIX-compliant](https://www.shellcheck.net) shell script for exporting files as environment variables.

## Getting Started
To get started create the following directory structure:

```shell
$ mkdir -p $HOME/.myvars/ldap/tls
```

Next, write some files into the directories from above:

```shell
$ cat <<EOF > $HOME/.myvars/ldap/ldif.gzip64
dn: cn=akutz,{{ LDAP_USERS_DN }}
cn: akutz
displayName: Andrew Kutz
givenName: Andrew
sn: Kutz
objectClass: inetOrgPerson
userPassword: password
mail: akutz@vmware.com
EOF
```

```shell
$ cat <<EOF > $HOME/.myvars/ldap/tls/crt.gzip64
-----BEGIN CERTIFICATE-----
MIIElzCCA3+gAwIBAgIJAJbHyAC6EqRoMA0GCSqGSIb3DQEBBQUAMIGdMQswCQYD
VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTESMBAGA1UEBwwJUGFsbyBBbHRv
MQ8wDQYDVQQKDAZWTXdhcmUxDDAKBgNVBAsMA0NOWDElMCMGA1UEAwwcbGRhcC5j
aWNkLmNueC5jbmEudm13YXJlLnJ1bjEfMB0GCSqGSIb3DQEJARYQYWt1dHpAdm13
YXJlLmNvbTAeFw0xODA3MDMyMDQ0MjlaFw0xODA4MDIyMDQ0MjlaMIGdMQswCQYD
VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTESMBAGA1UEBwwJUGFsbyBBbHRv
MQ8wDQYDVQQKDAZWTXdhcmUxDDAKBgNVBAsMA0NOWDElMCMGA1UEAwwcbGRhcC5j
aWNkLmNueC5jbmEudm13YXJlLnJ1bjEfMB0GCSqGSIb3DQEJARYQYWt1dHpAdm13
YXJlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM/c8dG2VuiT
+/YjnHQLazPhwVNFYZby8tLpZOcKfYBoZCqfBapQa5ILkJjcW73xp4L4uTpEsQmQ
84TH/eIxOBudVxaPBKOcWexFvjVOsCvhcaag6R5GIyR0yPr2tixf8rfiJSeNvcox
MLsGNFOcKTQz+KIZZ3V27pCylTac2STxRB3t5yuouLVLie+XUdG8AvZSy7M3ZKWI
HUQ4wN0grx0WbUNeg0CKw1EO/6ZdclFkxLpKKZFGL3234d8Op2ZepOmmo0EjsZ7N
igJhFh8OCiWH5Il8zuARP19OTPc+nDFN8Owcx/VYc5gKwLLQMQAMxGVhuDzbkrjr
gH1YG6jWcCcCAwEAAaOB1zCB1DAJBgNVHRMEAjAAMAsGA1UdDwQEAwICBDATBgNV
HSUEDDAKBggrBgEFBQcDATAdBgNVHQ4EFgQUWUX00zLIkqWL3OY/GdCUvcZ7xdQw
gYUGA1UdEQR+MHyCHGxkYXAuY2ljZC5jbnguY25hLnZtd2FyZS5ydW6CCmxkYXAu
bG9jYWyCPnZtdy1jbngtY2ljZC1sZGFwLTA0ODA2MjMxOTYxMDcwM2MuZWxiLnVz
LXdlc3QtMi5hbWF6b25hd3MuY29thwR/AAABhwQ29TPIhwTAqAICMA0GCSqGSIb3
DQEBBQUAA4IBAQBj8cZrYYXei+2eWDEJS0Gw/xqpHDf4XToj/r4ryQK+Afo3NTHm
elzkml5Vxp1LeWRg0sgTYkyAxkyM81BibPH9LRwdeBTVe6TODeesA14sasesgCK5
xFoHHmKbldGHI7MHS+7uPr3XtNw6iS4jE37EHJ2ah34rSWZbX3uV4P/+lzKDJNpa
ywVRISBOsxqaFbF5wVnEYQMI40rAyxMvf8bWFINod0DZYtXIJ6gdxb+c1jrY+ULC
iHnH/PNR2r0+uwwZz9g92BsTqetnO8ebfJpBoal7X2biD2m22poUeGRx01wPf+jY
kq4FS5OztypZC37QENAiGKOoh3pmdeMwQCcx
-----END CERTIFICATE-----
EOF
```

Finally, set `ENVY_HOME` and source `envy.sh` into the current shell:

```shell
ENVY_HOME="${HOME}/.myvars" . envy.sh
```

The script does not produce any output. However, if successful, it's now possible to execute the following (on macOS):

**Note: On Linux the** `-D` **flag for the** `base64` **command is lowercase** `-d`.

```shell
$ echo $LDAP_LDIF | base64 -D | gzip -d
dn: cn=akutz,{{ LDAP_USERS_DN }}
cn: akutz
displayName: Andrew Kutz
givenName: Andrew
sn: Kutz
objectClass: inetOrgPerson
userPassword: password
mail: akutz@vmware.com
```


```shell
$ echo $LDAP_TLS_CRT | base64 -D | gzip -d
-----BEGIN CERTIFICATE-----
MIIElzCCA3+gAwIBAgIJAJbHyAC6EqRoMA0GCSqGSIb3DQEBBQUAMIGdMQswCQYD
VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTESMBAGA1UEBwwJUGFsbyBBbHRv
MQ8wDQYDVQQKDAZWTXdhcmUxDDAKBgNVBAsMA0NOWDElMCMGA1UEAwwcbGRhcC5j
aWNkLmNueC5jbmEudm13YXJlLnJ1bjEfMB0GCSqGSIb3DQEJARYQYWt1dHpAdm13
YXJlLmNvbTAeFw0xODA3MDMyMDQ0MjlaFw0xODA4MDIyMDQ0MjlaMIGdMQswCQYD
VQQGEwJVUzETMBEGA1UECAwKQ2FsaWZvcm5pYTESMBAGA1UEBwwJUGFsbyBBbHRv
MQ8wDQYDVQQKDAZWTXdhcmUxDDAKBgNVBAsMA0NOWDElMCMGA1UEAwwcbGRhcC5j
aWNkLmNueC5jbmEudm13YXJlLnJ1bjEfMB0GCSqGSIb3DQEJARYQYWt1dHpAdm13
YXJlLmNvbTCCASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAM/c8dG2VuiT
+/YjnHQLazPhwVNFYZby8tLpZOcKfYBoZCqfBapQa5ILkJjcW73xp4L4uTpEsQmQ
84TH/eIxOBudVxaPBKOcWexFvjVOsCvhcaag6R5GIyR0yPr2tixf8rfiJSeNvcox
MLsGNFOcKTQz+KIZZ3V27pCylTac2STxRB3t5yuouLVLie+XUdG8AvZSy7M3ZKWI
HUQ4wN0grx0WbUNeg0CKw1EO/6ZdclFkxLpKKZFGL3234d8Op2ZepOmmo0EjsZ7N
igJhFh8OCiWH5Il8zuARP19OTPc+nDFN8Owcx/VYc5gKwLLQMQAMxGVhuDzbkrjr
gH1YG6jWcCcCAwEAAaOB1zCB1DAJBgNVHRMEAjAAMAsGA1UdDwQEAwICBDATBgNV
HSUEDDAKBggrBgEFBQcDATAdBgNVHQ4EFgQUWUX00zLIkqWL3OY/GdCUvcZ7xdQw
gYUGA1UdEQR+MHyCHGxkYXAuY2ljZC5jbnguY25hLnZtd2FyZS5ydW6CCmxkYXAu
bG9jYWyCPnZtdy1jbngtY2ljZC1sZGFwLTA0ODA2MjMxOTYxMDcwM2MuZWxiLnVz
LXdlc3QtMi5hbWF6b25hd3MuY29thwR/AAABhwQ29TPIhwTAqAICMA0GCSqGSIb3
DQEBBQUAA4IBAQBj8cZrYYXei+2eWDEJS0Gw/xqpHDf4XToj/r4ryQK+Afo3NTHm
elzkml5Vxp1LeWRg0sgTYkyAxkyM81BibPH9LRwdeBTVe6TODeesA14sasesgCK5
xFoHHmKbldGHI7MHS+7uPr3XtNw6iS4jE37EHJ2ah34rSWZbX3uV4P/+lzKDJNpa
ywVRISBOsxqaFbF5wVnEYQMI40rAyxMvf8bWFINod0DZYtXIJ6gdxb+c1jrY+ULC
iHnH/PNR2r0+uwwZz9g92BsTqetnO8ebfJpBoal7X2biD2m22poUeGRx01wPf+jY
kq4FS5OztypZC37QENAiGKOoh3pmdeMwQCcx
-----END CERTIFICATE-----
```

## Configuration
Envy is configured with environment variables:

| Name | Description |
|----------------|-------------|
| `ENVY_HOME` | The path to the root of the directory scanned by the script. |
| `ENVY_PREFIX` | One or more (space-delimited) prefixes to add to every environment variable created by the script. For example, in the [Getting Started](#getting-started) section above, if `ENVY_PREFIX=TEST_` were set, then `TEST_LDAP_LDIF` and `TEST_LDAP_TLS_CRT` would have been defined as well. |
| `ENVY_DRYRUN` | Set to `true` to have the `export` commands echoed instead of executed. |

### Supported file extensions
Files in an `ENVY_HOME` path may end with one of the following extensions:

| File Extension | Description |
|----------------|-------------|
| | No file extension means the file's contents are assigned to the environment variable(s) *as is*. |
| `base64` | The file's contents are encoded with `base64` before being assigned to the environment variable(s). |
| `gzip64` | The file's contents are compressed with `gzip -c9` and then encoded with `base64` before being assigned to the environment variable(s). |