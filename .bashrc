# ~/.bashrc: executed by bash(1) for non-login shells.
# see /usr/share/doc/bash/examples/startup-files (in the package bash-doc)
# for examples

# If not running interactively, don't do anything
case $- in
    *i*) ;;
      *) return;;
esac

# don't put duplicate lines or lines starting with space in the history.
# See bash(1) for more options
HISTCONTROL=ignoreboth

# append to the history file, don't overwrite it
shopt -s histappend

# for setting history length see HISTSIZE and HISTFILESIZE in bash(1)
HISTSIZE=1000
HISTFILESIZE=2000

# check the window size after each command and, if necessary,
# update the values of LINES and COLUMNS.
shopt -s checkwinsize

# If set, the pattern "**" used in a pathname expansion context will
# match all files and zero or more directories and subdirectories.
#shopt -s globstar

# make less more friendly for non-text input files, see lesspipe(1)
[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

PROMPT_COMMAND='DIR=`pwd|sed -e "s!$HOME!~!"`; if [ ${#DIR} -gt 30 ]; then CurDir=${DIR:0:15}...${DIR:${#DIR}-20}; else CurDir=$DIR; fi'
PS1="\[\033[0;32m\]\u\[\033[0m\] \[\033[1;36m\][\$CurDir]\[\033[m\] \[\033[1;32m\]\$\[\033[m\]"


# enable color support of ls and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
fi

# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'

# Alias definitions.
# You may want to put all your additions into a separate file like
# ~/.bash_aliases, instead of adding them here directly.
# See /usr/share/doc/bash-doc/examples in the bash-doc package.

if [ -f ~/.bash_aliases ]; then
    . ~/.bash_aliases
fi

# enable programmable completion features (you don't need to enable
# this, if it's already enabled in /etc/bash.bashrc and /etc/profile
# sources /etc/bash.bashrc).
if ! shopt -oq posix; then
  if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
  elif [ -f /etc/bash_completion ]; then
    . /etc/bash_completion
  fi
fi

#######################################################################################################
# IoT Lab customizations
#######################################################################################################
#Enable bash command completion
if [ -f /etc/bash_completion ]; then
. /etc/bash_completion
fi

#Frequently used environment variables
export JAVA_HOME=/usr/lib/jvm/java-8-oracle
export GTEST_DIR=/home/tyler/Build_Tools/googletest
export CLASSPATH=/home/tyler/Build_Tools/junit-4.12.jar
export ANDROID_NDK=/home/tyler/Build_Tools/android-ndk-r10e
export ANDROID_SDK=/home/tyler/Android/Sdk
export BIG_UP=../../../../../../../

#Stuff for Python for Android
export ANDROIDSDK=/home/tyler/Android/Sdk/platforms/android-25
export ANDROIDNDK=/home/tyler/Build_Tools/android-ndk-r10e
export ANDROIDAPI=25
export ANDROIDNDKVER=r10e

#Frequently used commands
alias get-id="git rev-parse HEAD | xclip -select c && xclip -selection c -o"
alias refresh="source ~/.bashrc"
alias dirs="dirs -v"

#Functions to speed up testing
        #Quickly find *.so library for test binaries
        #TODO: add failsafes for non-existant/unfindable files
function ajn_lib () {
	unset path
	unset LD_LIBRARY_PATH
	for i in `seq 1 10`;
	do
	if [ "$1" == "" ]; then
		break
	else
	while true
	do
	path="$path../"
	if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then
                echo "$1 not found"
                break
        else
	if [[ $(find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \;) ]]; then
		export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$(dirname `find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec readlink -f {} \; | head -n 1`)
		break
	fi
	fi
	done
	fi
	shift
        echo $LD_LIBRARY_PATH
	done
}
        #Quickly download all testing repositories with specified branch
function pull-all() {
        touch .root.flag
	mkdir core
	mkdir services
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/alljoyn.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/ajtcl.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/alljoyn-js.git -b $1)
	(cd core && git clone https://git.allseenalliance.org/gerrit/core/test.git -b $1)
	(cd services && git clone https://git.allseenalliance.org/gerrit/services/base.git -b $1)
	(cd services && git clone https://git.allseenalliance.org/gerrit/services/base_tcl.git -b $1)
	export ajn_root=$(pwd)
	export base=$(pwd)/core/alljoyn
	export base_bin=$(pwd)/core/alljoyn/build/linux/*/*/dist/cpp/bin
	export tcl=$(pwd)/core/ajtcl
	export js=$(pwd)/core/alljoyn-js
	export js_bin=$(pwd)/core/alljoyn-js/dist/bin
	export js_console=$(pwd)/core/alljoyn-js/console
	export serv_tcl=$(pwd)/services/base_tcl
}
        #Navigate to specified file (fast way to get to test binaries)
        #TODO: add failsafes for non-existant/unfindable files
function moveto() {
	unset path
	unset destination
	for i in `seq 1 10`;
	do
	if [ "$1" == "" ]; then
		break
	else
	while true
	do
	if [[ $(find $path -maxdepth 1 -name ".root.flag" -type f -exec echo "{}" \;) ]]; then
                echo "$1 not found"
                break
        else
	if [[ $(find $path -maxdepth 20 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \;) ]]; then
		cd $(dirname `find $path -maxdepth 10 -name "$1" -type f -not -path "*/obj/*" -exec echo "{}" \; | head -n 1`)
		break
	fi
	fi
	path="$path../"
	done
	fi
	shift
	done
}
        #Go back up to the repository root (whatever directory has the SConstruct file)
function moveup() {
	unset path
	while true
	do
	path="$path../"
	if [[ $(find $path -maxdepth 1 -name ".bashrc" -type f -exec echo "{}" \;) ]]; then
                echo "SConstruct not found in any parent directories"
                break
        else
	if [[ $(find $path -maxdepth 1 -name "SConstruct" -type f -exec echo "{}" \;) ]]; then
		cd $(dirname `find $path -maxdepth 1 -name "SConstruct" -type f -exec echo "{}" \; | head -n 1`)
		break
	fi
	fi
	done
}
        #Return location of PolicyDB configurations
function policyconf() {
    find $POLICY_CONF -name "$1" -type f -exec readlink -f {} \; | head -n 1
}

function swapvar() {
    if [[ $TEST_ROOT ]]; then
    if [[ $(pwd | grep rel) ]]; then
        cd $TEST_ROOT/../test-deb
        echo "Debug Testing"
    else
        cd $TEST_ROOT/../test-rel
        echo "Release Testing"
    fi
    refresh
    else
    echo "Unrecognized testing envionrment."
    fi
}

function logit() {
    $1 2>&1 | tee $2
}

