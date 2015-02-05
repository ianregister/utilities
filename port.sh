#! /bin/bash
lsof -P | grep ':3000' | awk '{print $2}' | xargs kill -9