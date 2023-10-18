#!/bin/bash

workflow_runs=$(curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $INPUT_TOKEN" https://api.github.com/repos/$INPUT_OWNER/$INPUT_REPO/actions/runs?status=in_progress)
num=$(echo $workflow_runs | jq -r .total_count)
if [ "$num" -eq 0 ]; then
  echo "in_progress=false" >> $GITHUB_OUTPUT
else
    for ((i=0; i<$num; i++)); do
        name=$(echo $workflow_runs | jq -r .workflow_runs[$i].name)
        jobs_url=$(echo $workflow_runs | jq -r .workflow_runs[$i].jobs_url)
        if [[ "$name" == "$INPUT_NAME" ]]; then
            jobs=$(curl -H "Accept: application/vnd.github.v3+json" -H "Authorization: token $INPUT_TOKEN" $jobs_url)
            num_job=$(echo $jobs | jq -r .total_count)
            for ((i_job=0; i_job<$num_job; i_job++)); do
                echo $jobs | jq -r .jobs[$i_job].name
                echo $jobs | jq -r .jobs[$i_job].steps[$(($INPUT_NUM_STEP - 1))]
                echo $INPUT_NAME_STEP
                name_step=$(echo $jobs | jq -r .jobs[$i_job].name)
                steps=$(echo $jobs | jq -r .jobs[$i_job].steps[$(($INPUT_NUM_STEP - 1))])
                if [[ "$name_step" == "$INPUT_NAME_STEP" ]]; then
                    if [[ "$(echo $steps | jq -r .status)" != "completed" ]]; then
                        echo $steps | jq -r .status
                        echo "in_progress=true" >> $GITHUB_OUTPUT
                    else
                        echo "in_progress=false" >> $GITHUB_OUTPUT
                    fi
                fi
            done
        fi
    done
fi