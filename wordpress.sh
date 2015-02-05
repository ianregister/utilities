#! /bin/bash

# Capture the site host directory name, also is hostname
read -r -p "Enter host directory: " host
read -r -p "Enter theme directory: " theme

# Lil' ol if else loop to prevent accidents (fills up /Server/ and makes a .conf)
if [ "$host" == "" ]; then
	echo "No beer for you!"
	exit
else

	# Check if directory already exists
	if [ -d /Server/$host ]; then
		echo "Host directory exists dude, try again? or..."

		# Move existing to Wordpress theme
		# This is left over from an era creating theme HTML/CSS/JS before integrating with WP
		read -r -p "Move directory to Wordpress themes directory? " move
		
		if [ "$move" == "y" ]; then
			mkdir -p /Server/temp/$host/
			cp -r /Server/$host/ /Server/temp/$host/
		else
			exit
		fi	
	fi
	
	# Check if site is already configured in nginx
	if [ -f /usr/local/etc/nginx/sites-enabled/$host.conf ]; then
		echo "Server already configured, try again"
		
		# Set up new Wordpress only
		read -r -p "New Wordpress site? " new
	
			if [ "$new" == "y" ]; then
				echo "New site, yo!"
			else
				exit
			fi	
	fi

	# Capture remaining details
	read -r -p "Enter db name: " db
	# Capture site name, change bash's IFS to something other than whitespace so, then unset when complete
	IFS=':'
	read -r -p "Enter site name: " name
	# Should really unset I guess, but causes error, assume IFS is not global, but just relates to this script
	# unset IFS
	read -r -p "Enter db prefix: " prefix
	
	# Remove current host directory (backed up remember to temp) 
	if [ "$move" == "y" ]; then
		rm -rf /Server/$host
	fi	

	# Make directory on server
	mkdir -p /Server/$host
	cd /Server/$host
	
	# Get lastest Wordpress
	curl -O https://wordpress.org/latest.tar.gz
	tar --strip-components=1 -xvf latest.tar.gz
	rm latest.tar.gz
		
	# Move current directory to Wordpress themes directory 
	if [ "$move" == "y" ]; then
		cp -r /Server/temp/$host/ /Server/$host/wp-content/themes/$host/
	fi
	
	# Make directory for theme
	mkdir -p wp-content/themes/$theme/
	cd /Server/$host/wp-content/themes/$theme/

	# Get lastest starter theme
	curl -Lk https://api.github.com/repos/ianregister/boilerplate/tarball -o master.tar.gz
	tar --strip-components=1 -xvf master.tar.gz
	rm master.tar.gz
	
	# Move back into site root
	cd /Server/$host/
	
	# Move wp-config & move back to site
	cp -r wp-content/themes/$theme/wp-config-custom.php wp-config-temp.php

	# Make a database (if it exists, will not be overwritten)
	# Including password, but it will give warning
	# Alteratively use sudo to run script (eek), and add script to sudoers to run without password
	mysql -udb -pdb -e "create database "$db";"
	
	# Add our details to the wp-config.php file
	sed -e "s/localhost/"localhost"/" -e "s/host_name_here/"$host"/" -e "s/database_name_here/"$db"/" -e "s/username_here/"db"/" -e "s/password_here/"db"/" -e "s/prefix_here/"$prefix"/" wp-config-temp.php > wp-config.php
	echo ""
	
	# All done with the wp-config.php, so let's get rid of it
	rm /Server/$host/wp-config-temp.php
		
	# Clean up temp directory
	rm -rf /Server/temp
	#rm -l /Server/temp
	
	# Add an .htaccess for that lame-o Apache
	cp /Users/me/Documents/Scripts/Shell/htaccess-wp /Server/$host/.htaccess
	
	# Write hostname to hosts file (/dev/null so no output - improve?)
	echo '127.0.0.1	'$host | sudo tee -a /private/etc/hosts > /dev/null
	
	# And now let's get a site defined in nginx (beer is the dummy string in the conf file being duplicated)
	sed -e "s/beer/"$host"/" /usr/local/etc/nginx/sites-available/default.conf > /usr/local/etc/nginx/sites-enabled/$host.conf
	
	# Restart nginx
	sudo launchctl unload /Library/LaunchDaemons/homebrew.mxcl.nginx.plist
	sudo launchctl load /Library/LaunchDaemons/homebrew.mxcl.nginx.plist

fi
# Get a beer
