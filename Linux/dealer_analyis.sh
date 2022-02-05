#!/bin/bash

grep -i '05:00:00 AM\|08:00:00 AM\|02:00:00 PM\|08:00:00 PM\|11:00:00 PM' * | awk '{print $1, $2, $5, $6 }' > Dealers_Working_During_Losses


