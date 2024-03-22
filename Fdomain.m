% Add these lines at the beginning of your script to include the Signal Processing Toolbox
if ~license('test', 'Signal_Toolbox')
    error('Signal Processing Toolbox is not available.');
end

% Downsampling factor
downsample_factor = 10;

% Load female training files
trainfiles_female = dir('C:\Users\USER\Desktop\matlab assign\Train\Female\*.wav');

% Initialize data array for female features
data_fem = [];

% Loop through female training files
for i = 1:length(trainfiles_female)
    filepath = strcat(trainfiles_female(i).folder, '\', trainfiles_female(i).name);
    [y, fs] = audioread(filepath);

    ZCR_fem1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_fem2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR_fem3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;
    
    % Calculate energy
    energy = sum(sum(y.^2));
    
    % Calculate correlation
    [correlation_fem, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
    correlation_fem = correlation_fem(floor(length(correlation_fem)/2));
    
    % Calculate power spectral density
    [pxx_fem, f] = periodogram(y, rectwin(length(y)), length(y), fs);
    pxx_fem = sum(pxx_fem(f>0));
    
    % Update feature vector
    features_fem = [ZCR_fem1 ZCR_fem2 ZCR_fem3 energy correlation_fem pxx_fem];
    data_fem = [data_fem ;features_fem];
end

% Calculate ZCR for females
ZCR_fem = mean(data_fem);
fprintf('The ZCR of female is\n');
disp(ZCR_fem);

f = abs(fft(y));
index_f = 1:length(f);
index_f = index_f ./ length(f);
index_f = index_f *fs;
figure;
plot(index_f, f);
title('Audio Signal in frequency Domain for Female');
xlabel('freq');
ylabel('Amplitude');

% Load male training files
trainfiles_male = dir('C:\Users\USER\Desktop\matlab assign\Train\Male\*.wav');

% Initialize data array for male features
data_male = [];

% Loop through male training files
for i = 1:length(trainfiles_male)
    filepath = strcat(trainfiles_male(i).folder, '\', trainfiles_male(i).name);
    [y, fs] = audioread(filepath);

    ZCR_male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_male2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR_male3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;
    
    % Calculate energy
    energy = sum(sum(y.^2));
    
    % Calculate correlation
    [correlation_male, lags] = xcorr(y(1:end-1), y(2:end), 'coeff');
    correlation_male = correlation_male(floor(length(correlation_male)/2));
    
    % Calculate power spectral density
    [pxx_male, f] = periodogram(y, rectwin(length(y)), length(y), fs);
    pxx_male = sum(pxx_male(f>0));
    
    % Update feature vector
    features_male = [ZCR_male1 ZCR_male2 ZCR_male3 energy correlation_male pxx_male];
    data_male = [data_male ;features_male];
end

f = abs(fft(y));
index_f = 1:length(f);
index_f = index_f ./ length(f);
index_f = index_f *fs;
figure;
plot(index_f, f);
title('Audio Signal in frequency Domain for Male');
xlabel('freq');
ylabel('Amplitude');

% Calculate ZCR for males
ZCR_male = mean(data_male);
fprintf('The ZCR of male is\n');
disp(ZCR_male);

% Initialize counters
correct_female = 0;
correct_male = 0;

% Load female testing files
testfiles_female = dir('C:\Users\USER\Desktop\matlab assign\Test\Female\*.wav');

% Loop through female testing files
for i = 1:length(testfiles_female)
    filepath = strcat(testfiles_female(i).folder, '\', testfiles_female(i).name);
    [y, fs] = audioread(filepath);
    
    % Calculate ZCR, energy, correlation, and pxx
    ZCR_fem1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_fem2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR_fem3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;
    
    energy = sum(sum(y.^2));
    
    % Downsample the signal for correlation calculation
    y_downsampled = downsample(y, downsample_factor);
    
    % Calculate correlation
    correlation_fem = corr(y_downsampled(1:end-1), y_downsampled(2:end));
    
    % Calculate power spectral density
    [pxx_fem, f] = periodogram(y, rectwin(length(y)), length(y), fs);
    pxx_fem = mean(pxx_fem);
    
    % Update feature vector
    y_ZCR = [ZCR_fem1 ZCR_fem2 ZCR_fem3 energy correlation_fem pxx_fem];
    
    if(pdist([y_ZCR;ZCR_fem],'cosine') < pdist([y_ZCR;ZCR_male],'cosine'))
        fprintf('Test file [female] #%d classified as female \n',i);
        correct_female = correct_female + 1;
    else
        fprintf('Test file [female] #%d classified as male \n',i);
    end
end

% Calculate female accuracy
female_accuracy = correct_female / length(testfiles_female);
fprintf('The accuracy for female classification is %.2f%%\n', female_accuracy*100);

% Load male testing files
testfiles_male = dir('C:\Users\USER\Desktop\matlab assign\Test\Male\*.wav');

% Loop through male testing files
for i = 1:length(testfiles_male)
    filepath = strcat(testfiles_male(i).folder, '\', testfiles_male(i).name);
    [y, fs] = audioread(filepath);
    
    % Calculate ZCR, energy, correlation, and pxx
    ZCR_male1 = mean(abs(diff(sign(y(1:floor(end/3))))))./2;
    ZCR_male2 = mean(abs(diff(sign(y(1:floor(end/3):floor(end*2/3))))))./2;
    ZCR_male3 = mean(abs(diff(sign(y(1:floor(end/3):end)))))./2;
    
    energy = sum(y.^2);
    
    % Downsample the signal for correlation calculation
    y_downsampled = downsample(y, downsample_factor);
    
    % Calculate correlation
    correlation_male = corr(y_downsampled(1:end-1), y_downsampled(2:end));
    
    % Calculate power spectral density
    [pxx_male, f] = periodogram(y, rectwin(length(y)), length(y), fs);
    pxx_male = mean(pxx_male);
    
    % Update feature vector
    y_ZCR = [ZCR_male1 ZCR_male2 ZCR_male3 energy correlation_male pxx_male];
    
    if(pdist([y_ZCR;ZCR_fem],'cosine') < pdist([y_ZCR;ZCR_male],'cosine'))
        fprintf('Test file [male] #%d classified as female \n',i);
    else
        fprintf('Test file [male] #%d classified as male \n',i);
        correct_male = correct_male + 1;
    end
end

% Calculate male accuracy
male_accuracy = correct_male / length(testfiles_male);
fprintf('The accuracy for male classification is %.2f%%\n', male_accuracy*100);

% Calculate overall accuracy
total_tests = length(testfiles_female) + length(testfiles_male);
total_correct = correct_female + correct_male;
overall_accuracy = total_correct / total_tests;

fprintf('The overall accuracy of the system is %.2f%%\n', overall_accuracy*100);
