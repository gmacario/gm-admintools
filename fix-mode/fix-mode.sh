#!/bin/bash -e

find . -type d -exec chmod 755 {} \;
find . -type f ! -regex ".*.sh" ! -regex "./.git/.*" -exec chmod 644 {} \;

# EOF
