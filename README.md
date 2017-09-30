# VOCcode
it's for drawing&amp;calculate P-R curve/LOSS curve/AP/mAP and store data as .mat for further use<br>
please clone the reposity in your model folders
```
# Make sure to clone with --recursive
git clone --recursive https://github.com/rbgirshick/py-faster-rcnn.git
```
## Avg training loss curve

this is a really small part code for training loss curve especially in yolo<br>
#### step 1 
To rercord the log during training your model, please run the code<br>
```
cd $darknet(your model file)
script -R log.txt
```
#### step 2
Once your traning has been done, please don't forget to stop the log by `^c` or `exit()`<br>
Open your matlab with `sudo matlab` and change the `train_log_file`(it don't need to change usually)
#### step 3
It's important to change the code `[~, string_output] = dos(['cat ', train_log_file, ' | grep "avg," | awk ''{print $3}'''])`so that it can read your own model (if you are using yolo, please don't change it). This is used for extracting the `loss` output with `dos` command. But in the first version, the genaration is not extracted.<br>
After normalized the code, this script can be `run` to plot

## AP mAP P-R
