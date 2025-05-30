#!/bin/bash

function error_exit() {
  echo "$1" 1>&2
  exit 1
}

function check_deps() {
  jq_test=$(which jq)
  curl_test=$(which curl)
  if [[ -z $jq_test ]]; then error_exit "JQ binary not found"; fi
  if [[ -z $curl_test ]]; then error_exit "curl binary not found"; fi
}

function extract_data() {
  latest=$(curl -s https://api.github.com/repos/prometheus-operator/prometheus-operator/releases/latest | jq -cr .tag_name)
  jq -n --arg latest "$latest" '{"latest":"'$latest'"}'
}

check_deps
extract_data
