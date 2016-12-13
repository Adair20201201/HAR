There are total 67 sets (1-67) of data collected by the host PC

*.txt is raw PIR signal received by host PC from 5 sensor nodes.
Each row of *.txt: Time(s) + Received data

The data frame of each message sent from the sensor node:
1.255; 2.255; 3.Sensor Node number(1-5); 4.PIR1; 5.PIR2; 6.PIR3; 7.PIR4; 8.PIR5; 9.PIR6; 10.PIR7; 11. PIR8; 12.PIR9; 13.transition ID(+1)

*.csv is the label of ground truth for each data set
Each row of *.csv: Sample(#) + Moving speed + Ground Truth Action Label
Action Label: 1. lying; 2. sitting; 3. standing; 4. walking; 5. transitional activities.