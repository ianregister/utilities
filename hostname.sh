#! /bin/bash

# Capture the site name
read -r -p "Enter host name: " host

# Lil' ol if else loop to prevent accidents (fills up /Server/ and makes a .conf)
if [ "$host" == "" ]; then
	echo "No beer for you!"
	exit
else

# Write hostname to hosts file (/dev/null so no output - improve?)
echo '127.0.0.1	'$host | sudo tee -a /private/etc/hosts > /dev/null

# And now let's get a site defined in nginx
sed -e "s/beer/"$host"/" /usr/local/etc/nginx/sites-available/default.conf > /usr/local/etc/nginx/sites-enabled/$host.conf

# Restart nginx
sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

# End if
fi