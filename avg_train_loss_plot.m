
clear;
clc;
close all
namelist = {'yolov2','fasterrcnn','ssd','rfcn'};
modulename = namelist{1}
train_log_file = sprintf('../results/%s/log.txt', modulename);
draw = 0;
switch modulename
    case 'yolov2'
        [~, string_output] = dos(['cat ', train_log_file, ' | grep "avg," | awk ''{print $1, $3}''']); % yolo
        index = find(string_output==':');
        string_output(index(:))=[];
        train_data = str2num(string_output);
        genaration = train_data(:,1);
        loss = train_data(:,2);
    case 'fasterrcnn'
        [~, string_output] = dos(['cat ', train_log_file, ' | grep " loss = " | awk ''{print $6 $9}''']); % fasterrcnn
        train_data = str2num(string_output);
        genaration = train_data(:,1);
        loss = train_data(:,2);
        
    case 'rfcn'
        [~, string_output] = dos(['cat ', train_log_file, ' | grep " loss = " | awk ''{print $6 $9}''']); % fasterrcnn
        train_data = str2num(string_output);
        genaration = train_data(:,1);
        loss = train_data(:,2);
        
    case 'ssd'
        [~, string_output] = dos(['cat ', train_log_file, ' | grep " loss = " | awk ''{print $6 $9}''']); % fasterrcnn
        train_data = str2num(string_output);
        genaration = train_data(:,1);
        loss = train_data(:,2);
end

%n = 1:length(train_loss);
%idx_train = (n-1);

h=figure;
plot(genaration, loss);
xlabel 'genaration'
ylabel 'loss(%)'
title('Loss-Genaration Curve');
saveas(h,strcat('output/train_loss.jpg'))
save('output/train_loss.mat','genaration','loss');
grid on;
legend('Train Loss');
xlabel('iterations');
ylabel('avg loss');
title('Train Loss Curve');
% axis([1,20000,2,20])
dos('cd output/')
dos('chmod -R 777 *')


%%
% draw loss figure together
if draw
    namelist = {'yolov2','fasterrcnn','ssd','rfcn'};
    h = figure;
    for i = 1:length(namelist);
        modulename = namelist{i}
        train_mat_file = sprintf('../results/%s/train_loss.mat', modulename);
        load(train_mat_file);

        plot(genaration, loss);
        hold on
    end
    grid on;
    legend(namelist);
    xlabel('iterations');
    ylabel('avg loss');
    title('Train Loss Curve');
    axis([1,15000,0,50])
    saveas(h,strcat('output/train_loss_sum.jpg'))
end
