function pip-install() {
    packages=()
    dev_dependency=0
    requirements_file=
    while [ $# -gt 0 ]
    do
        case "$1" in
            -h|--help)
                echo "Usage: pip-install [-d|--dev] [-r|--req <file>] <package1> <package2> ..." 1>&2
                echo ""
                echo "This function installs provided Python packages using pip"
                echo "and adds this dependency to the file listing requirements."
                echo "The name of the package is added to the file without"
                echo "concreate version only if it is absent there." 
                echo ""
                echo "-h|--help        - prints this message and exits."
                echo "-d|--dev         - if the dependency is development."
                echo "-r|--req <file>  - in which file write the dependency."
                echo "    If the filename is not provided by default the function"
                echo "    writes this information to requirements.txt or to"
                echo "    requirements-dev.txt if -d parameter is provided."
                echo "<package1> <package2> ..."
                return 0
                ;;
            -d|--dev)
                shift
                dev_dependency=1
                ;;
            -r|--req)
                shift
                requirements_file="$1"
                echo "Requirements file specified: $requirements_file"
                shift
                ;;
            *)
                packages+=( "$1" )
                echo "$1"
                shift
                ;;
        esac
    done

    if ! [ -x "$(command -v pip)" ]; then
        echo "Cannot find pip tool. Aborting!"
        exit 1
    fi

    echo "Requirements file: $requirements_file"
    echo "Development dependencies: $dev_dependency"
    echo "Packages: ${packages[@]}"

    if [ -z "$requirements_file" ]; then
        if [ $dev_dependency -eq 0 ]; then
            requirements_file="requirements.txt"
        else
            requirements_file="requirements-dev.txt"
        fi
    fi

    for p in "${packages[@]}"
    do
        echo "Installing package: $p"
        pip install $p
        if [ $? -eq 0 ]; then
            echo "Package installed successfully"
            echo "$p" >> $requirements_file
            if [ $(grep -Ec "^$p([~=!<>]|$)" "$requirements_file") -eq 0 ]; then
                echo "$p" >> $requirements_file
            else
                echo "Package $p is already in $requirements_file"
            fi
        else
            echo "Cannot install package: $p"
        fi
    done
}


function pip-freeze() {
    dump_all=0
    dev_dependency=0
    requirements_file=
    while [ $# -gt 0 ]
    do
        case "$1" in
            -h|--help)
                echo "Usage: pip-freeze [-a|--all] [-d|--dev] [-r|--req <file>]" 1>&2
                echo ""
                echo "This function freezes only the top-level dependencies listed"
                echo "in the <file> and writes the results to the <file>.lock file."
                echo "Later, the data from this file can be used to install all"
                echo "top-level dependencies." 
                echo ""
                echo "-h|--help        - prints this message and exits."
                echo "-d|--dev         - if the dependency is development."
                echo "-a|--all         - if we should freeze all dependencies"
                echo "  (not only top-level)."
                echo "-r|--req <file>  - what file to use to look for the list of"
                echo "    top-level dependencies. The results will be written to"
                echo "    the \"<file>.lock\" file." 
                echo "    If the <file> is not provided by default the function"
                echo "    uses \"requirements.txt\" or \"requirements-dev.txt\""
                echo "    if -d parameter is provided and writes the results to the"
                echo "    \"requirements.txt.lock\" or \"requirements-dev.txt.lock\""
                echo "    correspondingly."
                return 0
                ;;
            -d|--dev)
                shift
                echo "Development dependency"
                dev_dependency=1
                ;;
            -a|--all)
                shift
                dump_all=1 
                ;;
            -r|--req)
                shift
                requirements_file="$1"
                echo "Requirements file specified: $requirements_file"
                shift
                ;;
        esac
    done

    if ! [ -x "$(command -v pip)" ]; then
        echo "Cannot find pip tool. Aborting!"
        exit 1
    fi

    if [ -z "$requirements_file" ]; then
        if [ $dev_dependency -eq 0 ]; then
            requirements_file="requirements.txt"
        else
            requirements_file="requirements-dev.txt"
        fi
    fi

    lock_file="$requirements_file.lock"
    if [ $dump_all -eq 1 ] 
    then
        pip freeze > "$lock_file"
        if [ $? -eq 0 ]; then
            echo "Locked all dependencies to: $lock_file"
        else
            echo "Error happened while locking all dependencies"
        fi
    else
        cmd_output=$(pip freeze -r "$requirements_file")
        if [ $? -eq 0 ]; then
            > "$lock_file"
            while IFS= read -r line; do
                if [ "$line" = "## The following requirements were added by pip freeze:" ]; then
                    break
                fi
                echo "$line" >> "$lock_file"
            done <<< "$cmd_output"
        fi
    fi
}
