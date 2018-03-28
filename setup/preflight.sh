# Are we running as root?
if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root. Please re-run like this:"
	echo
	echo "sudo $0"
	echo
	exit
fi

# Check that we are running on Ubuntu 14.04 LTS (or 14.04.xx).
if [ "`lsb_release -d | sed 's/.*:\s*//' | sed 's/14\.04\.[0-9]/14.04/' `" != "Ubuntu 14.04 LTS" ]; then
	echo "Server-in-a-Box only supports being installed on Ubuntu 14.04, sorry. You are running:"
	echo
	lsb_release -d | sed 's/.*:\s*//'
	echo
	echo "We can't write scripts that run on every possible setup, sorry."
	exit
fi

# Check that we have enough memory.
#
# /proc/meminfo reports free memory in kibibytes. Our baseline will be 512 MB,
# which is 500000 kibibytes.
#
# We will display a warning if the memory is below 768 MB which is 750000 kibibytes
#
# Skip the check if we appear to be running inside of Vagrant, because that's really just for testing.
TOTAL_PHYSICAL_MEM=$(head -n 1 /proc/meminfo | awk '{print $2}')
if [ $TOTAL_PHYSICAL_MEM -lt 500000 ]; then
if [ ! -d /vagrant ]; then
	TOTAL_PHYSICAL_MEM=$(expr \( \( $TOTAL_PHYSICAL_MEM \* 1024 \) / 1000 \) / 1000)
	echo "Your Mail-in-a-Box needs more memory (RAM) to function properly."
	echo "Please provision a machine with at least 512 MB, 1 GB recommended."
	echo "This machine has $TOTAL_PHYSICAL_MEM MB memory."
	exit
fi
fi
if [ $TOTAL_PHYSICAL_MEM -lt 750000 ]; then
	echo "WARNING: Your Server-in-a-Box has less than 768 MB of memory."
	echo "         It might run unreliably when under heavy load."
fi

# Check that tempfs is mounted with exec
MOUNTED_TMP_AS_NO_EXEC=$(grep "/tmp.*noexec" /proc/mounts)
if [ -n "$MOUNTED_TMP_AS_NO_EXEC" ]; then
	echo "Server-in-a-Box has to have exec rights on /tmp, please mount /tmp with exec"
	exit
fi

# Check that no .wgetrc exists
if [ -e ~/.wgetrc ]; then
	echo "Server-in-a-Box expects no overrides to wget defaults, ~/.wgetrc exists"
	exit
fi

# Check that we are running on x86_64 or i686, any other architecture is unsupported and
# will fail later in the setup when we try to install the custom build lucene packages.
#
# Set ARM=1 to ignore this check if you have built the packages yourself. If you do this
# you are on your own!
ARCHITECTURE=$(uname -m)
if [ "$ARCHITECTURE" != "x86_64" ] && [ "$ARCHITECTURE" != "i686" ]; then
if [ -z "$ARM" ]; then
	echo "Server-in-a-Box only supports x86_64 or i686 and will not work on any other architecture, like ARM."
	echo "Your architecture is $ARCHITECTURE"
	exit
fi
fi
