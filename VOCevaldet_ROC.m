%function [rec,prec,ap] = VOCevaldet(VOCopts,id,cls,draw)
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
draw = true;
VOCopts = VOCinit();
aplist=zeros(length(clss),1);
dos(['mkdir ./output'])
dos(['chmod -R 777 *'])


%for clsn=1:length(clss)
    clsn=1;
    cls = clss{clsn};
%%
    % load test set
    fid = fopen(sprintf(VOCopts.imgsetpath,VOCopts.testset),'r');
    [gtids,t]=textscan(fid,'%s');
    gtids = cellstr(char(gtids{1}));
    % load ground truth objects
    tic;
    Npos=0; % positive
    Ncor=0; % correct
    N=0;
    gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
    for i=1:length(gtids)
        % display progress
        if toc>2
            fprintf('%s: pr: load: %d/%d\n',cls,i,length(gtids));
            drawnow;
            tic;
        end

        % read annotation
        rec=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));  % zhen shi kuang

        % extract objects of 'class' -> gt
        clsinds=strmatch(cls,{rec.objects(:).class},'exact');
        gt(i).BB=cat(1,rec.objects(clsinds).bbox)';
        gt(i).diff=[rec.objects(clsinds).difficult];
        gt(i).det=false(length(clsinds),1);
        
        N = N + sum(~gt(i).diff);  % total ground truth target
    end
%%
    % load results 
    fid = fopen(sprintf(VOCopts.detrespath,strcat('voc.txt',cls)),'r');  %ce shi kuang
    fid = fopen(sprintf(VOCopts.detrespath,strcat(cls)),'r');  %ce shi kuang
    %fid = fopen(sprintf('wangliyou/%s.txt',cls));
    [content,t]=textscan(fid,'%s %f %f %f %f %f');
    ids = cellstr(char(content{1}));
    confidence = double(content{2});
    b1 = double(content{3});
    b2 = double(content{4});
    b3 = double(content{5});
    b4 = double(content{6});
    BB=[b1 b2 b3 b4]';
%%
Rec=[];
Prec=[];
numconfi=1;
    Npro=zeros(1,101);
    
for confidence_thresh=0:0.1:1
    % assign detections to ground truth objects
    nd=length(confidence);
    tp=zeros(nd,1);
    fp=zeros(nd,1);
    confidence_thresh

    tic;
    for d=1:nd % ceshi suoyin
        % display progress
        if toc>1
            fprintf('%s: pr: compute: %d/%d\n',cls,d,nd);
            drawnow;
            tic;
        end

        % find ground truth image
        i=strmatch(ids{d},gtids,'exact'); % zhenshi suoyin
        if isempty(i)
            error('unrecognized image "%s"',ids{d});
        elseif length(i)>1
            error('multiple image "%s"',ids{d});
        end

        % assign detection to ground truth o==bject if any
        bb=BB(:,d); % ceshi kuang  
        ovmax=-inf;
        if d==1
            num=1;% di m zhang tupian
            jmax=[];
        elseif strcmp(ids{d},ids{d-1}) && d~=nd
            num=num+1;
        else
            % 每张图只匹配对应或小于ground truth数量
            uni_jmax=unique(jmax);
            uni_jmax(find(uni_jmax==0))=[];
            % jmax
            uni_ovmaxx=[];
            for jj = 1:length(uni_jmax)
                index = find(jmax==uni_jmax(jj));
                uni_ovmaxx(jj) = max(ovmaxx(index(:)));
            end
            % assign detection as true positive/don't care/false positive
            for jj =1:length(uni_jmax)

                if uni_ovmaxx(jj)>=VOCopts.minoverlap  %I O U gtyuzhi
                   tp(d-1)=tp(d-1)+1;            % true positive
                else
                   fp(d-1)=fp(d-1)+1;            % false positive
                end
            end
            num=1;
            jmax=[];
        end
        if confidence(d) > confidence_thresh
            Npro(numconfi)=Npro(numconfi)+1;
            for j=1:size(gt(i).BB,2)
                bbgt=gt(i).BB(:,j); % zhenshi kuang
                bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
                iw=bi(3)-bi(1)+1;
                ih=bi(4)-bi(2)+1;
                if iw>0 && ih>0                
                    % compute overlap as area of intersection / area of union
                    ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                       (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                       iw*ih;
                    ov=iw*ih/ua; % I O U
                    % 每行标签只匹配一个ground truth
                    if ov>ovmax
                        ovmaxx(num)=ov; % MAX I O U
                        jmax(num)=j; % index of MAX I O U
                    end
                end
            end

        end
        
    end
    Npos(numconfi)=sum(fp);
    Ncor(numconfi)=sum(tp);
    numconfi=numconfi+1;
end
%%
% tp\Ncor->TP N->TP+FN Npro->TP+FP nd->FN+TN+TP+FP
% TPR=TP/ (TP+ FN) FPR= FP / (FP + TN)
    Rec=Ncor./N;
    Prec=Ncor./Npro;
    TP=Ncor;
    FN=N-Ncor;
    FP=Npro-Ncor;
    TN=nd-Npro-FN;
    TPR = TP./(TP+FN);
    FPR = FP./(FP+TN);
    % compute precision/recall
    index=find(isnan(Prec));
    Prec0=Prec
    Prec0(index(:))=0;
    ap = sum(Prec0)/length(Prec);
    if draw
        % plot precision/recall
        h = figure,
        plot(FPR,TPR,'-');
        grid;
        xlabel 'false positive rate'
        ylabel 'true positive rate'
        title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
        saveas(h,strcat('output/',cls,'ROC.jpg'))
    end

    % record average precision
    %aplist(clsn) = ap;
    %save(sprintf('output/%s_P-R.mat',cls),'rec','prec','ap');
%end
%saveas(h1,strcat('output/','IOU.jpg'))
saveas(h,strcat('output/','ROC.jpg'))
map = sum(aplist)/length(clss)
dos('cd output/')
dos('chmod -R 777 *')