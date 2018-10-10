clc,clear
close all
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
clssname = {'Insulator';
'Rotary\_double\_ear';
'Binaural\_sleeve';
'Brace\_sleeve';
'Steady\_arm\_base';
'Bracing\_wire\_hook';
'Double\_sleeve\_connector';
'Messenger\_wire\_base';
'Windproof\_wire\_ring';
'Insulator\_base';
'Isoelectric\_line';
'Brace\_sleeve\_screw'};
draw = true;
VOCopts = VOCinit();
con_sumy=[];
for clsn=1:length(clss)
    %clsn=1;
    cls = clss{clsn};
    % load test set
    fid = fopen(sprintf(VOCopts.imgsetpath,VOCopts.testset),'r');
    [gtids,t]=textscan(fid,'%s');
    gtids = cellstr(char(gtids{1}));
    % load ground truth objects
    tic;
    npos=0;

    % load results 
    fid = fopen(sprintf(VOCopts.detrespath,strcat('voc.txt',cls)),'r');  %ce shi kuang
    fid = fopen(sprintf(VOCopts.detrespath,cls),'r');  %ce shi kuang
    [content,t]=textscan(fid,'%s %f %f %f %f %f');
    confidence = double(content{2});

    % sort detections by decreasing confidence
    [sc,si]=sort(-confidence);

    % assign detections to ground truth objects
    n = length(confidence);
    x = [1:n];
    if draw
        % plot precision/recall
        h = figure,
        plot(x,confidence,'-');
        grid on;
        xlabel 'precision'
        ylabel 'confidence'
        title(sprintf('confidence distribution class: %s, subset: %s,',clssname{clsn},VOCopts.testset));
        saveas(h,strcat('output/',cls,'confidence_distribution.jpg'))
    end
    ii=0;
    con_sum=[];

    sum=0;
    for thresh = 0:0.05:1
        if ii>0
            index = find(confidence<thresh);
            con_sum(ii)=length(index)-sum;
            sum=sum+con_sum(ii);
            label{ii} = num2str(thresh);
            labelx(ii) = thresh;
        end
        ii=ii+1;
    end
        h = figure,
%         plot([1:length(con_sum)],con_sum,'-');
        bar(labelx,con_sum);
%         set(gca,'XTickLabel',label)
        grid on;
        xlabel 'precision'
        ylabel 'confidence'
        title(sprintf('confidence distribution class: %s, subset: %s,',clssname{clsn},VOCopts.testset));
        saveas(h,strcat('output/',cls,'confidence_distribution.jpg'))
    % record average precision
    save(sprintf('output/%s_confidence.mat',cls),'confidence');
    con_sumy = [con_sumy;con_sum];
    
end
con_labelx=[];
 h = figure
    con_labelx=ones(12,1)*labelx;
     bar(labelx,con_sumy');
    grid on;
    xlabel 'precision'
    ylabel 'confidence'
    title(sprintf('confidence distribution'));
    legend(clss)
    saveas(h,strcat('output/confidence_distribution.jpg'))
    save(sprintf('output/confidence_distribution.mat'),'labelx','con_sumy');