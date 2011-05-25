#!/bin/sh

#set -x
set -e

SOURCE_URL="http://lupin13.venaria.marelli.it/infinoted/"
MIRROR_URL="http://lupin05.venaria.marelli.it/svnrepos/lupin/mirrors/lupin13.venaria.marelli.it/"
LOCALDIR="${HOME}/MYSVN/gobby_lupin13"
#MY_USERNAME=macario
#MY_PASSWORD=xxx

echo "INF: Mirroring from ${SOURCE_URL}"
echo "INF: Mirroring to   ${MIRROR_URL}"
if [ -z "${MY_USERNAME}" ]; then
	echo -n "Username: "
	read MY_USERNAME
fi
if [ -z "${MY_PASSWORD}" ]; then
	echo -n "Password: "
	stty -echo
	read MY_PASSWORD
	stty echo
fi
if [ ! -e "${LOCALDIR}" ]; then
	echo "INF: Checking out ${MIRROR_URL}"
	mkdir -p "${LOCALDIR}"
	cd "${LOCALDIR}" && svn co --username "${MY_USERNAME}" --password "${MY_PASSWORD}" "${MIRROR_URL}" .
else
	echo "INF: Updating working copy from ${SOURCE_URL}"
	cd "${LOCALDIR}"
	svn update
fi

echo "INF: Mirroring ${SOURCE_URL}"
cd "${LOCALDIR}"
wget -nv --mirror --no-parent --no-host-directories \
	--user="${MY_USERNAME}" --password="${MY_PASSWORD}" "${SOURCE_URL}" || true
# --user=USER
# --password=PASS
# --ask-password

# --exclude

# Remove dummy "index.html" (but NOT inside .svn):
find . -path "*/.svn" -prune -o -name "index.html\?*" -exec rm {} \;

echo "INF: Verifying deltas against copy on SVN server"
svn status

# "Look, Mom - No Hands!"
svn status | awk '/^?/ {print $2}' | while read f; do xargs svn add ${f}; done
svn status | awk '/^!/ {print $2}' | while read f; do xargs svn rm ${f};  done

echo "TODO:" svn commit -m "Automatically mirrored from ${SOURCE_URL}"

# === EOF ===
