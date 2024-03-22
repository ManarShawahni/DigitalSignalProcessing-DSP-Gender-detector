%Manar Shawahni 1201086 
recObj = audiorecorder(44100, 24, 1);
%for i = 1:2
fprintf('Please Start speak say Zero #%d\n');
recordblocking(recObj, 2); % for two seconds
fprintf('Audio #%d ended\n',i);
 
y = getaudiodata(recObj);
y = y - mean(y);
file_name = sprintf('Test/Male/mzero9.wav');
audiowrite(file_name, y, recObj.SampleRate)
%figure
%plot(y);
%end