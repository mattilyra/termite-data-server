#!/bin/bash

EXTERNALS_PATH=externals
TOOLS_PATH=tools

if [ ! -d "server_src" ] || [ ! -d "landing_src" ]
then
	echo "Usage: bin/setup_gensim.sh"
	echo "    Download and set up gensim."
	echo "    This script should be run from the root of the git repo."
	echo
	echo "    Gensim is not downloaded by default."
	echo "    This script assumes that easy_install is available,"
	echo "    and that SciPy and NumPy are already installed."
	echo
	exit -1
fi

function __create_folder__ {
	FOLDER=$1
	if [ ! -d $FOLDER ]
	then
		echo "    Creating folder: $FOLDER"
		mkdir $FOLDER
	fi
}

function __setup_gensim__ {
	EXTERNALS_SUBPATH=$EXTERNALS_PATH/gensim-0.8.9
	TOOLS_SUBPATH=$TOOLS_PATH/gensim-0.8.9
	SYMLINK_SUBPATH=$TOOLS_PATH/gensim
	SYMLINK=gensim-0.8.9

	echo "# Setting up gensim..."
	if [ ! -d "$TOOLS_SUBPATH" ]
	then

		if [ ! -d "$EXTERNALS_SUBPATH" ]
		then
			__create_folder__ $EXTERNALS_PATH
			__create_folder__ $EXTERNALS_SUBPATH
			echo "    Downloading..."
			curl --insecure --location http://pypi.python.org/packages/source/g/gensim/gensim-0.8.9.tar.gz > $EXTERNALS_SUBPATH/gensim-0.8.9.tar.gz
			echo "    Extracting readme..."
			tar -zxf $EXTERNALS_SUBPATH/gensim-0.8.9.tar.gz gensim-0.8.9/README.rst &&\
				mv gensim-0.8.9/README.rst $EXTERNALS_SUBPATH &&\
				rmdir gensim-0.8.9
			echo "You may delete downloaded files in this folder without affecting the topic model server." > $EXTERNALS_SUBPATH/safe-to-delete.txt
		else
			echo "    Already downloaded: $EXTERNALS_SUBPATH/gensim-0.8.9.tar.gz"
		fi
		
		__create_folder__ $TOOLS_PATH
		__create_folder__ $TOOLS_SUBPATH
		echo "    Uncompressing..."
		tar -zxf $EXTERNALS_SUBPATH/gensim-0.8.9.tar.gz gensim-0.8.9 &&\
			mv gensim-0.8.9/* $TOOLS_SUBPATH &&\
			rmdir gensim-0.8.9 &&\
			ln -s $SYMLINK $SYMLINK_SUBPATH

		echo "    Running self tests..."
		echo "python $TOOLS_SUBPATH/setup.py test"
		python $TOOLS_SUBPATH/setup.py test
		
		echo "    Installing..."
		echo "sudo python $TOOLS_SUBPATH/setup.py install"
		sudo python $TOOLS_SUBPATH/setup.py install
		
		echo "    Cleaning up..."
		echo "sudo rm -rf build/"
		sudo rm -rf build/
		echo "sudo rm -rf gensim.egg-info/"
		sudo rm -rf gensim.egg-info/
		echo "sudo rm -rf dist/"
		sudo rm -rf dist/
	else
		echo "    Already available: $TOOLS_SUBPATH"
	fi
	echo
}

__setup_gensim__
