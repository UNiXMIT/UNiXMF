#!/bin/bash
/openldap/newpasswd.sh
echo "Executing main command: $@"
exec "$@"