function Write(G,filename,format)


switch format
    case 'off'
        fid = fopen(filename,'wt');
        if( fid==-1 )
            error('Can''t open the file.');
        end
        
        % header
        fprintf(fid, 'OFF\n');
        fprintf(fid, '%d %d 0\n', length(G.V), length(G.F));
        
        % write the points & faces
        fprintf(fid, '%f %f %f\n', G.V);
        fprintf(fid, '%d %d %d\n', G.F);
        
        fclose(fid);
    case 'obj'
        fid = fopen(filename,'wt');
        if( fid==-1 )
            error('Can''t open the file.');
        end
        
        % vertex coordinates
        fprintf(fid, 'v %f %f %f\n', G.V);
        
        % Texture coordinates
        if isfield(options, 'Texture')
            fprintf(fid, 'vt %f %f\n', options.Texture.Coordinates(1:2,:));
            fprintf(fid, 'f %d/%d %d/%d %d/%d\n', kron(G.F',[1,1])');
        else
            fprintf(fid, 'f %d %d %d\n', G.F');
        end
        fclose(fid);
end