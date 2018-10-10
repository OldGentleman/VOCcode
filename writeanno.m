%writeanno.m
%path_image='threechannels/JPEGImages/';
%path_label='threechannels/labels/';%txt�ļ����·��
path_image='../scripts/VOCdevkit/JPEGImages/';%jpg�ļ����·��
path_label='../scripts/VOCdevkit/ImageSets/';%txt�ļ����·��
path_xml='../scripts/VOCdevkit/Annotations/';%xml�ļ����·��
files_all=dir(path_label);

for i = 4:length(files_all)
    try 
        msg = textread(strcat(path_label, '/',files_all(i).name(1:end-4),'.txt'),'%s');
    catch
        continue
    end
    clear rec;
    path = [path_xml files_all(i).name(1:end-4) '.xml'];
    fid=fopen(path,'w');
    rec.folder = 'VOC2007';%��ݼ���

    rec.filename = [files_all(i).name(1:end-4),'.jpg'];%ͼƬ��

    rec.source.database = 'The VOC2007 Database';%���д
    rec.source.annotation = 'PASCAL VOC2007';%���д
    rec.source.image = 'flickr';%���д
    rec.source.flickrid = '0';%���д

    rec.owner.flickrid = 'Masaaaki';%���д
    rec.owner.name = 'Masaaki';%���д

  %  img = imread(['./JPEGImages/' files_all(i).name]);
    img = imread([path_image, files_all(i).name]);
    rec.size.width = int2str(size(img,2));
    rec.size.height = int2str(size(img,1));
    rec.size.depth = int2str(size(img,3));
    
    rec.segmented = '0';%�����ڷָ�
    %writexml(fid,rec,0);
%     for j = 1:num_obj
%         rec.annotation.object.name = msg{num};%�����
%         rec.annotation.object.pose = 'Unspecified';%��ָ����̬
%         rec.annotation.object.truncated = '0';%û�б�ɾ��
%         rec.annotation.object.difficult = '0';%��������ʶ���Ŀ��
%         rec.annotation.object.bndbox.xmin = msg{num+1};%���x1
%         rec.annotation.object.bndbox.ymin = msg{num+2};%���y1
%         rec.annotation.object.bndbox.xmax = msg{num+3};%���x2
%         rec.annotation.object.bndbox.ymax = msg{num+4};%���y2
%         num = num + 5;
%         writexml(fid,rec,0);
%     end
    fprintf(fid,'<%s>\n','annotation');
    writexml(fid,rec,1);
        
    num = 2;
    num_obj = str2num(msg{1});
    for j = 1:num_obj
        rec1.object.name = msg{num};%�����
        rec1.object.pose = 'Unspecified';%��ָ����̬
        rec1.object.truncated = '0';%û�б�ɾ��
        rec1.object.difficult = '0';%��������ʶ���Ŀ��
        rec1.object.bndbox.xmin = msg{num+1};%���x1
        rec1.object.bndbox.ymin = msg{num+2};%���y1
        rec1.object.bndbox.xmax = msg{num+3};%���x2
        rec1.object.bndbox.ymax = msg{num+4};%���y2
        num = num + 5;
        writexml(fid,rec1,1);
    end
    %rec.annotation.object = rec1.annotation.object;
    %writexml(fid,rec,0);
    fprintf(fid,'</%s>\n','annotation');
    fclose(fid);
end