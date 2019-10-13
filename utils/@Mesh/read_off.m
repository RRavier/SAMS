function [V,F,Fs] = read_off(filename)

fid = fopen(filename,'r');
if( fid==-1 )
    error('Can''t open the file.');
    return;
end

str = fgets(fid);   % -1 if eof
% if ~strcmp(str(end-3:end), 'OFF')
if ~findstr(str,'OFF')
    error('The file is not a valid OFF one.');    
end

str = fgets(fid);
[a,str] = strtok(str); Nv= str2num(a);
[a,str] = strtok(str); Nf= str2num(a);



[A,cnt] = fscanf(fid,'%f %f %f', 3*Nv);

if cnt~=3*Nv
    warning('Problem in reading vertices.');
end
V = reshape(A, 3, round(cnt/3));

% read Face 1  1088 480 1022
[A,cnt] = fscanf(fid,'%d %d %d\n', 3*Nf);
if cnt~=3*Nf
    warning('Problem in reading faces.');
end
F = reshape(A,3,round(cnt/3));
if min(min(F)) < 1
    F = F+1;
end
fclose(fid);


end

