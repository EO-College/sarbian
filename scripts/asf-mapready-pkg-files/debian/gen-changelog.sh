#!/bin/bash

function main() {
    # bash cannot create arrays by splitting on \n by default
    local IFS=$'\n'
    declare -ra taglist=($(git tag -l --format='%(creatordate:iso8601) %(refname)' | sort -r | cut -d'/' -f3))
    unset IFS

    declare -r changes_file="changelog"
    echo "ASF MapReady - Changelog" > "$changes_file"
    echo "========================" >> "$changes_file"

    for index in $(seq 0 $(( ${#taglist[@]} - 2 )) ); do
        local tag1="${taglist[$index]}"
        local tag2="${taglist[$(( $index + 1 ))]}"

        echo ">>> Getting changes between '$tag1' and '$tag2'..."

        echo "" >> "$changes_file"
        echo "Changes from $tag1 and $tag2:" >> "$changes_file"
        echo "" >> "$changes_file"
        git log "$tag1"..."$tag2" --pretty=format:'- %s' | grep -v "^- Merge" >> "$changes_file"
    done

    echo ">>> Finished generating changelog for ASF MapReady."
}

main
