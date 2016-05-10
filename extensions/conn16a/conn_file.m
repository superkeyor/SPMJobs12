function [out,V]=conn_file(filename)
filename=char(filename);
[V,str,icon,filename]=conn_getinfo(filename);
out={fliplr(deblank(fliplr(deblank(filename)))),str,icon};

