#! /bin/bash

# Use /dev/random to generate passwords (if not working, then use /dev/urandom)

# Clear the clipboard
echo '' | pbcopy
# pbcopy < /dev/null

# Generate random string, with no special characters
prefix=`LC_CTYPE=C < /dev/urandom tr -dc A-Za-z0-9 | head -c13`

# Generate random string, with special characters
# prefix=`LC_CTYPE=C < /dev/random tr -dc 'a-zA-Z0-9-_!@#$%^&*()_+{}|:<>?=' | head -c13`

echo -n $prefix | pbcopy
