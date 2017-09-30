
clear;
clc;
close all

train_log_file = '../log.txt';

[~, string_output] = dos(['cat ', train_log_file, ' | grep "avg," | awk ''{print $3}''']);
train_loss = str2num(string_output);
n = 1:length(train_loss);
idx_train = (n-1);

figure;plot(idx_train, train_loss);

grid on;
legend('Train Loss');
xlabel('iterations');
ylabel('avg loss');
title('Train Loss Curve')