clc,clear
close all
%%

dir={'/yolov2','/ssd','/fasterrcnn','/fasterrcnnzf','/CSCNET'};
model = {'yolov2','ssd','fasterrcnn-vgg','fasterrcnn-zf','CSCNET'};
diroutput = '/ap/';
data = 'train_loss.mat';
draw=0;
clss = {'Insulator';
'Rotary_double_ear';
'Binaural_sleeve';
'Brace_sleeve';
'Steady_arm_base';
'Bracing_wire_hook';
'Double_sleeve_connector';
'Messenger_wire_base';
'Windproof_wire_ring';
'Insulator_base';
'Isoelectric_line';
'Brace_sleeve_screw'};
clssn = {'Insulator';
'Rotary double ear';
'Binaural sleeve';
'Brace sleeve';
'Steady arm_base';
'Bracing wire_hook';
'Double sleeve connector';
'Messenger wire base';
'Windproof wire ring';
'Insulator base';
'Isoelectric line';
'Brace sleeve screw'};

%%
% plot 3 log train loss
% if draw
%     for i = 1:3
%         dir_mat = strcat(dir{i},diroutput,data)
%         load(dir_mat)
%         if i == 1
%             yolo_train_y = train_loss;
%             yolo_train_x = idx_train;
%         end
%         if i == 2
%             ssd_y = index;
%             ssd_x = index_ite;
%         end
%         if i == 3
%             faster_y = index;
%             faster_x = index_ite;
%         end
% 
%     end
%     h=figure,
%     plot(yolo_train_x,yolo_train_y,'b','LineWidth',1, 'LineSmoothing', 'on')
%     hold on
%     plot(ssd_x(1:length(ssd_y)),ssd_y,'g','LineWidth',1, 'LineSmoothing', 'on')
%     hold on 
%     plot(faster_x,faster_y(1:length(faster_x)),'r','LineWidth',1, 'LineSmoothing', 'on')
%     grid on
%     legend('Yolov2','SSD','Faster r-cnn')
%     axis([1 8000 0 50])
%     title('Train Loss'),xlabel('Iteration'),ylabel('loss')
%     saveas(h,strcat('train_loss_sum.jpg'))
% end
%%
for clssname = 1:length(clss)

    for i =1 : length(dir)
        dir_mat = strcat('../results',dir{i},diroutput,clss{clssname},'_P-R.mat')
        load(dir_mat)
%         eval([clss{clssname} '_rec{' num2str(i) '}=rec']);
%         eval([clss{clssname} '_prec{' num2str(i) '}=prec']);
%         eval([clss{clssname} '_ap{' num2str(i) '}=ap']);
        recsum{i}=FPR;
        precsum{i}=TPR;
       
    end
    h=figure,
    plot(recsum{1},precsum{1},'b-','LineWidth',1, 'LineSmoothing', 'on');
    hold on
    plot(recsum{2},precsum{2},'g-','LineWidth',1, 'LineSmoothing', 'on');
    hold on
    plot(recsum{3},precsum{3},'r-','LineWidth',1, 'LineSmoothing', 'on');
    hold on
    plot(recsum{4},precsum{4},'k-','LineWidth',1, 'LineSmoothing', 'on');
    hold on
    plot(recsum{5},precsum{5},'m-','LineWidth',1, 'LineSmoothing', 'on');
    grid on
    xlabel 'false positive rate'
    ylabel 'true positive rate'
    axis([0,1,0,1])
    title(sprintf('class: %s, PR curve',clssn{clssname}));
%     if (isempty(recsum{2})&&~isempty(recsum{3}))
%         legend('Yolov2','Faster r-cnn')
%     elseif (isempty(recsum{3})&&~isempty(recsum{2}))||clssname==11
%         legend('Yolov2','SSD')
%     else
        legend(model{1},model{2},model{3},model{4},model{5})
%     end
%     if clssname==12
%         legend('Yolov2')
%     end
    saveas(h,strcat('output/',clss{clssname},'PRsum.jpg'))
    hold off
    clear recsum precsum
end
        
        
        
        
        
        
        
        