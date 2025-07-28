#!/bin/bash

background_process() {
  sleep 5
  echo "Process Complete!"
}

background_process &
pid=$!
wait $pid

echo "After the Process"
