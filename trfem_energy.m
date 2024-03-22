trainfiles_female = dir('C:\Users\USER\Desktop\matlab assign\Train\Female\*.wav');
testfiles_female = dir('C:\Users\USER\Desktop\matlab assign\Test\Female\*.wav');
trainfiles_male = dir('C:\Users\USER\Desktop\matlab assign\Train\Male\*.wav');
testfiles_male = dir('C:\Users\USER\Desktop\matlab assign\Test\Male\*.wav');

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
correct_female = 0;
correct_male = 0;

data_fem = [];
for i = 1:length(trainfiles_female)
   filepath = strcat(trainfiles_female(i).folder,'\',trainfiles_female(i).name);
   [y,fs] = audioread(filepath);
   
   energyfemale = sum(y.^2);
   data_fem = [data_fem energyfemale];
end
energyfemale = mean(data_fem);
fprintf('The energy of zero females is \n');
disp(energyfemale);

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

data_male = [];
for i = 1:length(trainfiles_male)
   filepath = strcat(trainfiles_male(i).folder,'\',trainfiles_male(i).name);
   [y,fs] = audioread(filepath);
   
   energymale = sum(y.^2);
   data_male = [data_male energymale];
end
energymale = mean(data_male);
fprintf('The energy of zero males is \n');
disp(energymale);

%-------------------------------------------%

for i = 1:length(testfiles_male)
   filepath = strcat(testfiles_male(i).folder,'\',testfiles_male(i).name);
   [y,fs] = audioread(filepath);
   
   energy = sum(y.^2);
if(abs(energy-energyfemale)) < abs(energy-energymale)
   fprintf('Test file male classified as female, Energy = %d\n',energy);
else
   fprintf('Test file male classified as male, Energy = %d\n',energy');
   correct_male = correct_male + 1;
end

end

%----------------------------------------------%

for i = 1:length(testfiles_female)
   filepath = strcat(testfiles_female(i).folder,'\',testfiles_female(i).name);
   [y,fs] = audioread(filepath);
   
   energy = sum(y.^2);
if(abs(energy-energyfemale)) < abs(energy-energymale)
   fprintf('Test file fem classified as female, Energy = %d\n',energy);
   correct_female = correct_female + 1;
else
   fprintf('Test file fem classified as male, Energy = %d\n',energy');
end

end

% Calculate female accuracy
female_accuracy = correct_female / length(testfiles_female);
fprintf('The accuracy for female classification is %.2f%%\n', female_accuracy*100);

% Calculate male accuracy
male_accuracy = correct_male / length(testfiles_male);
fprintf('The accuracy for male classification is %.2f%%\n', male_accuracy*100);

% Calculate overall accuracy
total_tests = length(testfiles_female) + length(testfiles_male);
total_correct = correct_female + correct_male;
overall_accuracy = total_correct / total_tests;
fprintf('The overall accuracy of the system is %.2f%%\n', overall_accuracy*100);
