
num_channels = 1;
fp = fopen('220309_008_FilteredData2.dat');
fseek(fp, 0, 'eof');
filesize = ftell(fp);
fclose(fp);
fp = fopen('220309_008_FilteredData2.dat');
num_timepoints = filesize / num_channels;
FilteredData008 = fread(fp, [num_channels, num_timepoints], 'int16');
fclose(fp);