#!/bin/bash
# tool to manage MC-Claim projects

clear

###########################
#functions
instructions() {
	echo 
	echo '################################################################################################################'
	echo 'bash build-tool.sh -w <workspace> [-t] [-c] [-p] [-b]'
	echo "-w : workspace of the repository e.g.: bash build-tool.sh -d /c/data/repo/  -- default workspace is $default_repo"
	echo '-t : it runs maven with tests enabled'
	echo '-p : this command will pull the project(s) to the branch used on the option -b (or master branch as default)'
	echo '-c : this command will clones the project(s)'
	echo '-b : used to checkout for a new branch in the workspace'
	echo '-i : informations about running the script'
	echo
	echo '-----------------------------'
	echo 'To run the project for the first time you can run as'
	echo 'bash build-tool.sh'
	echo
	echo 'To run in order to checkout for a new branch, pull from the remote repository and run maven with tests'
	echo 'bash build-tool.sh -p -b release/1.0.0 -t'
	echo '################################################################################################################'
}

clone_project() {
	echo
	echo '###########################'
	echo "Cloning project $1"
	echo '###########################'
	
	git clone $2
}

pull_project() {
	echo
	echo '###########################'
	echo "Pulling project $1 to branch $2"
	echo '###########################'
	
	git pull --rebase origin $2
	
	if [ $? -ne 0 ]; then
		echo "#######################################"
		echo "Error pulling branch $2 of the project $1"
		echo 'Exiting the script'
		echo "#######################################"
		exit 1
	fi
	
	echo
}

checkout_project() {
	current_branch=$(git rev-parse --abbrev-ref HEAD)
	
	echo
	
	# check if the current branch is the same as the argument
	if [[ $current_branch != $2 ]]; then
		echo "Changing $1 to branch $2"
	
		git fetch origin
	
		branch_exists=$(git branch -l | grep $2)
	
	
		if  [[ -z $branch_exists ]]; then
			#since the local branch does not exists, it will check if the remote branch exists
			remote_branch=$(git branch -a | grep "remotes/origin/$2$")
			
			if [[ -n $remote_branch ]]; then
				git checkout -b $2
			fi
		else
			git checkout $2
		fi
	fi
	
	echo
}


start_process() {
	typeset folder
	typeset gitrepo
	
	folder=$1
	gitrepo=$2
	
	echo
	echo '################'
	echo "Starting process to project $1"
	echo '################'
	echo
	
	echo $folder
	if [[ to_clone -eq 0 || ! -d $folder ]]
	then
		clone_project $folder $gitrepo
	fi
	
	cd $folder
	pwd
	
	if [[ to_checkout -eq 0 ]]
	then
		checkout_project $folder $to_checkout_folder
	fi
	
	if [[ to_pull -eq 0 ]]
	then
		pull_project $folder $to_checkout_folder
	fi
	
	#sleep 3
	
	echo
	echo '################'
	
	if [[ to_run_tests -eq 0 ]]
	then
		echo 'Running with tests'
		run_test_command=""
	else
		echo 'Skipping tests'
		run_test_command="-DskipTests=true"
	fi
	
	echo '################'
	
	echo
	echo 'Running Maven'
	echo
	
	mvn -T 2C clean install -U $run_test_command
	
	echo '-----------------------------------'
	echo "ALL DONE FOR $1"
	echo '-----------------------------------'
}

###########################

# variables: values as false!
to_pull=1
to_clone=1
to_run_tests=1
to_checkout=1
to_checkout_folder="master"

default_repo='/c/data/repo'
gitrepo='https://github.com/marcelsamaruga/build-tool.git'


#print instructions
echo "You can find some instructions to run:"
instructions
echo


#getting options from command line
while getopts "w:itpcb:" option; do
    case "${option}" in
        w)  workspace=${OPTARG};;
        p)  to_pull=0;;
        c)  to_clone=0;;
        b)  to_checkout_folder=${OPTARG};to_checkout=0;;
        t)  to_run_tests=0;;
	i)  exit 0;;
    esac
done

###########################
#select the project
echo "Please select the project(s) you want to run:"
projects=("Build Tool" "All")

buildtool=1

COLUMNS=0

select opt in "${projects[@]}"; do
	case $opt in
		"Build Tool")
			buildtool=0; break;;
		"All")
			buildtool=0; break;;
		*) echo "Invalid option $REPLY. Try another one."; continue;;
	esac
done

# it validates the workspace
if [ -z $workspace ]; then
	echo "Using default path $default_repo, to use custom path use -d option (-d <path>)"

	if [[ ! -d $default_repo ]]; then
		echo "Cannot find path $default_repo"
		echo "Creating new folder $default_repo"
		mkdir $default_repo
		to_clone=0
	fi

	workspace=$default_repo
fi

# replace C:\workspace to /c/workspace
workspace=$(echo $(echo $workspace | sed 's/\\/\//g') | sed 's/C:/\/c/g' | sed 's/c:/\/c/g')

echo "workspace is: $workspace"

#move to the working directory
cd $workspace


if [[ $buildtool -eq 0 ]]
then
	start_process 'build-tool' $gitrepo $to_checkout
fi

