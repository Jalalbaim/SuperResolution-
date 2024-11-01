function [xs,ys,val]=MaxSubPixel2(imS,v);
% MaxSubPixel2 .m : Calcul des coordonées "subpixel" du maximum d'une image et de l'amplitude de ce maximum "subpixel" par ajustement polynomial 1D.
% Usage : [xs,ys,val]=MaxSubPixel2(imS,v);
% avec pour paramètres d'entrée : 
%           im : image d'entrée
%           v : voisinage utilisé pour ajuster le polynome   
% avec pour paramètres de sortie :
%           xs,ys : coordonnées "subpixel" du maximum de l'image 
%           val : valeur de ce maximum
% Créé par Corinne Fournier, 11/2011

[vx,x]=max(max(imS)); % Max au pixel pres
[vy,y]=max(max(imS'));
vali(1)=vx;

[P,S]=polyfit(x-v:x+v,imS(y,x-v:x+v),2);
xs=-P(2)/2/P(1);% Max Subpixel
vali(2)=P(1)*xs*xs+P(2)*xs+P(3);

[P,S]=polyfit(y-v:y+v,imS(y-v:y+v,x)',2);
ys=-P(2)/2/P(1);

vali(3)=P(1)*ys*ys+P(2)*ys+P(3);
val=max(vali);
