#!/usr/bin/env bash

repeat() {
  local char="${1}"
  local times="${2}"
  local counter=0
  
  while (( counter < times )); do
      (( counter++ ))
      echo -n "${char}"
  done
  echo ""
}
