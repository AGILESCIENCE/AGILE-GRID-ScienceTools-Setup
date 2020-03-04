#!/bin/bash

if [ "$#" -ne 1 ]; then
    printf "Illegal number of parameters.\n\n > bash start_build.sh BUILD26\n"
    return;
fi

science_tools_tag="$1"

cp meta.yaml.template meta.yaml
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

sed 's/{{package_version}}/'"$science_tools_tag"'/' -i meta.yaml
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi

sed 's/{{package_version}}/'"$science_tools_tag"'/' -i meta.yaml
rc=$?; if [[ $rc != 0 ]]; then exit $rc; fi


conda-build .

# cleanup
rm meta.yaml
