# Node Version Manager
# Implemented as a bash function
# To use source this file from your bash profile
#
# Implemented by Tim Caswell <tim@creationix.com>
# with much bash help from Matthew Ranney

NVM_DIR=$HOME/.nvm

nvm()
{
	START=`pwd`
	if [ $# -lt 1 ]; then
		nvm help
		return
	fi
	case $1 in
		"help" )
			echo
			echo "Node Version Manager"
			echo "Usage:"
			echo "    nvm install version"
			echo "    nvm use version"
			echo
		;;
		"install" )
			if [ $# -lt 2 ]; then
				nvm help
				return;
			fi
			echo $START
			mkdir -p "$NVM_DIR/src" && \
			cd "$NVM_DIR/src" && \
			wget "http://nodejs.org/dist/node-$2.tar.gz" -N && \
			tar -xzf "node-$2.tar.gz" && \
			cd "node-$2" && \
			./configure --prefix="$NVM_DIR/$2" && \
			make && \
			make install && \
			nvm use $2
			cd $START
		;;
		"use" )
			if [ $# -lt 2 ]; then
				nvm help
				return;
			fi
			# TODO: Remove old nvm paths before adding this one
			PATH="$NVM_DIR/$2/bin:$PATH"
			echo "Now using node $2"
		;;
		* )
			nvm help
		;;
	esac
}