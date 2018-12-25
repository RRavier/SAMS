  function [V,F,Fs] = read_obj( filename )
% function [V,F] = read_obj( filename )
%
% Loads a mesh in Wavefront OBJ format.

   fp = fopen( filename, 'r' );
   if( fp == -1 )
      disp( sprintf( 'Error: could not read mesh file "%s"\n', filename ));
      return;
   end

   V = [];
   F = [];
   %dumb fix to read object files from Doug, need something to stick
   line = fgets(fp); line = fgets(fp); line = fgets(fp); line = fgets(fp);     %skip down to relevant part
   while( ~feof( fp ))
       line = fgets(fp);
       line = strsplit(line);           %edit to fix problems with reading texture coordinates
       
        if strcmp(line{1},'v') % vertex
              V = [V str2double(line{2}) str2double(line{3}) str2double(line{4})];
        elseif strcmp(line{1},'f')
           if( line{1}== 'f' ) % face
              F = [F str2double(line{2}) str2double(line{3}) str2double(line{4})];
           end
       end
   end
   fclose( fp );
   Fs = [];
end

