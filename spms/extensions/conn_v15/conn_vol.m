function V=conn_vol(filename)

load(filename,'V');
V.fname=filename;
V.overwritesoftlink=true;

