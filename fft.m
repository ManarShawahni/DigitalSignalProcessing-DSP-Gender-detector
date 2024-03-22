[y, fs] = audioread('Test/Female/fzero1.wav');
plot(y);
f = abs(fft(y));
index_f = 1:length(f);
index_f = index_f ./ length(f);
index_f = index_f *fs;
figure;
plot(index_f, f);