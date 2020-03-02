# build-tool
Build Tool to clone/pull/run from a specific repo

# Instructions
`bash build-tool.sh -w <workspace> [-t] [-c] [-p] [-b]`
> -w : workspace of the repository e.g.: bash build-tool.sh -d /c/data/repo/  -- default workspace is /c/data/repo

> -t : it runs maven with tests enabled

> -p : this command will pull the project(s) to the branch used on the option -b (or master branch as default)

> -c : this command will clones the project(s)

> -b : used to checkout for a new branch in the workspace

> -i : informations about running the script


# Examples
## First Run
To run the project for the first time you can run as
`bash build-tool.sh`

## Running for a new branch
To run in order to checkout for a new branch, pull from the remote repository and run maven with tests
`bash build-tool.sh -p -b release/1.0.0 -t`
