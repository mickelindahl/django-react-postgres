#!/bin/bash

echo $(tr -dc 'a-z0-9!@#$%^&*(-_=+)' < /dev/urandom | head -c50)