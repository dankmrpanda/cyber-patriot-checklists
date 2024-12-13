#Removes programs by hands
#!/bin/bash
for i in badthings.txt ; do
if [[ $( grep -ic -e $i $(pwd)/README ) -eq 0 ]]; then
(apt-get remove --purge $i >> RemovingPrograms.txt 2>&1) & #starts deleting in background
fi
done
