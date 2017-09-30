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


for clsn=1:length(clss)
        cls = clss{clsn}
    % load test set
    fid = fopen(sprintf(VOCopts.imgsetpath,VOCopts.testset),'r');
    [gtids,t]=textscan(fid,'%s');
    gtids = cellstr(char(gtids{1}));
    % load ground truth objects
    tic;
    npos=0;
    gt(length(gtids))=struct('BB',[],'diff',[],'det',[]);
    for i=1:length(gtids)
        % display progress
        if toc>1
            fprintf('%s: pr: load: %d/%d\n',cls,i,length(gtids));
            drawnow;
            tic;
        end

        % read annotation
        rec=PASreadrecord(sprintf(VOCopts.annopath,gtids{i}));  % zhen shi kuang

        % extract objects of class
        clsinds=strmatch(cls,{rec.objects(:).class},'exact');
        gt(i).BB=cat(1,rec.objects(clsinds).bbox)';
        gt(i).diff=[rec.objects(clsinds).difficult];
        gt(i).det=false(length(clsinds),1);
        npos=npos+sum(~gt(i).diff);
    end

    % load results 
    fid = fopen(sprintf(VOCopts.detrespath,strcat('voc.txt',cls)),'r');  %ce shi kuang
    [content,t]=textscan(fid,'%s %f %f %f %f %f');
    ids = cellstr(char(content{1}));
    confidence = double(content{2});
    b1 = double(content{3});
    b2 = double(content{4});
    b3 = double(content{5});
    b4 = double(content{6});

    BB=[b1 b2 b3 b4]';

    % sort detections by decreasing confidence
    [sc,si]=sort(-confidence);
    ids=ids(si);
    BB=BB(:,si);

    % assign detections to ground truth objects
    nd=length(confidence);
    tp=zeros(nd,1);
    fp=zeros(nd,1);
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

        % assign detection to ground truth object if any
        bb=BB(:,d); % ceshi kuang
        ovmax=-inf;
        for j=1:size(gt(i).BB,2)
            bbgt=gt(i).BB(:,j); % zhenshi kuang
            bi=[max(bb(1),bbgt(1)) ; max(bb(2),bbgt(2)) ; min(bb(3),bbgt(3)) ; min(bb(4),bbgt(4))];
            iw=bi(3)-bi(1)+1;
            ih=bi(4)-bi(2)+1;
            if iw>0 & ih>0                
                % compute overlap as area of intersection / area of union
                ua=(bb(3)-bb(1)+1)*(bb(4)-bb(2)+1)+...
                   (bbgt(3)-bbgt(1)+1)*(bbgt(4)-bbgt(2)+1)-...
                   iw*ih;
                ov=iw*ih/ua; % I O U
                if ov>ovmax
                    ovmax=ov; % MAX I O U
                    jmax=j;
                end
            end
        end
        % assign detection as true positive/don't care/false positive
        if ovmax>=VOCopts.minoverlap  %I O U yuzhi
            if ~gt(i).diff(jmax)
                if ~gt(i).det(jmax)
                    tp(d)=1;            % true positive
            gt(i).det(jmax)=true;
                else
                    fp(d)=1;            % false positive (multiple detection)
                end
            end
        else
            fp(d)=1;                    % false positive  对于同一个gt,找到多个目标,则后续目标设为fp
        end
    end

    % compute precision/recall
    fp=cumsum(fp);
    tp=cumsum(tp);
    rec=tp/npos;
    prec=tp./(fp+tp);

    % compute average precision

    ap=0;
    for t=0:0.1:1  % THRESH *
        p=max(prec(rec>=t));  % dayu yuzhide prec
        if isempty(p)
            p=0;
        end
        ap=ap+p/11; % average precision
    end

    if draw
        % plot precision/recall
        h = figure,
        plot(rec,prec,'-');
        grid;
        xlabel 'recall'
        ylabel 'precision'
        title(sprintf('class: %s, subset: %s, AP = %.3f',cls,VOCopts.testset,ap));
        saveas(h,strcat('output/',cls,'P-R.jpg'))
    end

    % record average precision
    aplist(clsn) = ap;
    save(sprintf('output/%s_P-R.mat',cls),'rec','prec','ap');
end  
map = sum(aplist)/length(clss)
dos('cd output/')
dos('chmod -R 777 *')