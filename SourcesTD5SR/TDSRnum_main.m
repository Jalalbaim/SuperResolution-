%% BAIM Mohamed : TD Super Resolution Numerique

clear;close all;clc
%%
I=double(imread('barbara.png')); 
figure('Name','I');imshow(I,[],'InitialMagnification','fit');colorbar;axis on;title('I');
f=4; % doit etre paire % f repr�sente le facteur de r�solution
aff=1; % booleen d'affichage si aff=1 alors affichage des images de la pile

%% I.Simulation d'une pile d'images translat�es et sous �chantillonn�es
Nim=10; % Nim repr�sente le nbr d'image de la pile
I1=zeros(size(I,1),size(I,2),Nim);
I2=zeros(round(size(I,1)/f),round(size(I,2)/f),Nim);
txty=f*rand(2,Nim)-(f/2); %% txty repr�sente le d�calage ajouter � chaque image
txty(:,1)=[0,0];
if aff==1 ,figure('Name','pile d''images'),end
for c=1:Nim
    xform = [ 1  0  0;        0  1  0;   txty(1,c) txty(2,c)  1 ]; %Matrice de translation
    tform_translate = maketform('affine',xform); 
    I1(:,:,c)= imtransform(I, tform_translate,'XData',[1 size(I,2)],'YData',[1 size(I,1)],'FillValues',mean(I(:)));%??
    I2(:,:,c)=I1(1:f:end,1:f:end,c);%on tranque les pixels de bords
    if aff==1,    imshow(I2(:,:,c),[],'InitialMagnification','fit');colorbar;axis on;title(sprintf('image n� %d',c));pause(0.1),end
	save('pile.mat','I2','txty');
	
end
% Les artefacts qui apparaissent sur le pontalon sont l'origine du
% ph�nom�ne de moir�
%% II.Super-r�solution de la pile d images, connaissant les d�calages entre images
NimSR = Nim;
% Creation d'une grille d'interpolation
[X,Y]=meshgrid(1:f:size(I,2),1:f:size(I,1)); 
[Xi,Yi]=meshgrid(1:size(I,2),1:size(I,1));
% Recalage 
Xt=zeros(size(X,1),size(X,2)*NimSR);
Yt=Xt;
datat=Xt;
% les lignes suivantes servent � faire le recalage de la pile d'image
for c=1:NimSR % NimSR est le nombre d�images de la pile que l�on traite
    % pour obtenir l�image super-r�solue
    Xt(:,(size(X,2)*(c-1)+1):(size(X,2)*(c)))=X-txty(1,c);
    Yt(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=Y-txty(2,c);
    datat(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=I2(:,:,c);
end
% la ligne suivante sert � faire l'interpolation
ISR = griddata(Xt,Yt,datat,Xi,Yi,'cubic');
figure;
imshow(ISR,[]);title("Image Super r�solue");colorbar;axis on;
%% Estimation de l'Erreur Quadratique Moyenne
Err = I(5:end-4,5:end-4)-ISR(5:end-4,5:end-4);
MSE = norm(Err.^2)/(504*504);
disp(MSE)
% Pour Nim = 10: MSE = 0.81
% Pour Nim = 20: MSE = 0.42
% Pour Nim = 40: MSE = 0.18
% Pour Nim = 50: MSE = 0.15
%% III. Super-r�solution d une pile d�images bruit�es, connaissant les d�calages exacts entre les images
% Ss Echantillonage
Nim=10; % Nim repr�sente le nbr d'image de la pile
I1=zeros(size(I,1),size(I,2),Nim);
I2=zeros(round(size(I,1)/f),round(size(I,2)/f),Nim);
txty=f*rand(2,Nim)-(f/2); %% txty repr�sente le d�calage ajouter � chaque image
txty(:,1)=[0,0];
if aff==1 ,figure('Name','pile d''images'),end
for c=1:Nim
    xform = [ 1  0  0;        0  1  0;   txty(1,c) txty(2,c)  1 ]; %Matrice de translation
    tform_translate = maketform('affine',xform); 
    I1(:,:,c)= imtransform(I, tform_translate,'XData',[1 size(I,2)],'YData',[1 size(I,1)],'FillValues',mean(I(:)));
    noise = 10*randn(128);
    I2(:,:,c)=I1(1:f:end,1:f:end,c)+noise; %on tranque les pixels de bords + noise
    if aff==1,    imshow(I2(:,:,c),[],'InitialMagnification','fit');colorbar;axis on;title(sprintf('image n� %d',c));pause(0.1),end
	save('pile.mat','I2','txty');
end
% Interpolation 
NimSR = Nim;
% Creation d'une grille d'interpolation
[X,Y]=meshgrid(1:f:size(I,2),1:f:size(I,1)); 
[Xi,Yi]=meshgrid(1:size(I,2),1:size(I,1));
% Recalage 
Xt=zeros(size(X,1),size(X,2)*NimSR);
Yt=Xt;
datat=Xt;
% les lignes suivantes servent � faire le recalage de la pile d'image
for c=1:NimSR % NimSR est le nombre d�images de la pile que l�on traite
    % pour obtenir l�image super-r�solue
    Xt(:,(size(X,2)*(c-1)+1):(size(X,2)*(c)))=X-txty(1,c);
    Yt(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=Y-txty(2,c);
    datat(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=I2(:,:,c);
end
% la ligne suivante sert � faire l'interpolation
ISRnoise = griddata(Xt,Yt,datat,Xi,Yi,'cubic');
% Affichage 
figure; colorbar; axis on;
subplot(1,2,1);
imshow(ISR,[]);title("Image Super r�solue");
subplot(1,2,2);
imshow(ISRnoise,[]);title("Image Super r�solue + noise");
% Err quadratique
Errnoise = I(5:end-4,5:end-4)-ISRnoise(5:end-4,5:end-4);
MSE_noise = norm(Errnoise.^2)/(504*504);
disp(MSE_noise)
% L'erreur quadratique a diminu�e 
%% IV. Super-r�solution de la pile d images, connaissant les d�calages approximatifs entre les images
% SS ech et pile
Nim=10; % Nim repr�sente le nbr d'image de la pile
alpha = 10;
I1=zeros(size(I,1),size(I,2),Nim);
I2=zeros(round(size(I,1)/f),round(size(I,2)/f),Nim);
txty=f*rand(2,Nim)-(f/2)+alpha*randn(size(txty)); %% txty repr�sente le d�calage ajouter � chaque image
txty(:,1)=[0,0];
if aff==1 ,figure('Name','pile d''images'),end
for c=1:Nim
    xform = [ 1  0  0;        0  1  0;   txty(1,c) txty(2,c)  1 ]; %Matrice de translation
    tform_translate = maketform('affine',xform); 
    I1(:,:,c)= imtransform(I, tform_translate,'XData',[1 size(I,2)],'YData',[1 size(I,1)],'FillValues',mean(I(:)));%??
    I2(:,:,c)=I1(1:f:end,1:f:end,c);%on tranque les pixels de bords
    if aff==1,    imshow(I2(:,:,c),[],'InitialMagnification','fit');colorbar;axis on;title(sprintf('image n� %d',c));pause(0.1),end
	save('pile.mat','I2','txty');
	
end
% Interpolation et recalage
NimSR = Nim;
% Creation d'une grille d'interpolation
[X,Y]=meshgrid(1:f:size(I,2),1:f:size(I,1)); 
[Xi,Yi]=meshgrid(1:size(I,2),1:size(I,1));
% Recalage 
Xt=zeros(size(X,1),size(X,2)*NimSR);
Yt=Xt;
datat=Xt;
% les lignes suivantes servent � faire le recalage de la pile d'image
for c=1:NimSR % NimSR est le nombre d�images de la pile que l�on traite
    % pour obtenir l�image super-r�solue
    Xt(:,(size(X,2)*(c-1)+1):(size(X,2)*(c)))=X-txty(1,c);
    Yt(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=Y-txty(2,c);
    datat(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=I2(:,:,c);
end
% la ligne suivante sert � faire l'interpolation
ISR_alpha = griddata(Xt,Yt,datat,Xi,Yi,'cubic');
figure;
imshow(ISR_alpha,[]);title("Image Super r�solue + alpha");colorbar;axis on;
% Err quadratique
Erralpha = I(5:end-4,5:end-4)-ISR_alpha(5:end-4,5:end-4);
MSE_alpha = norm(Erralpha.^2)/(504*504);
disp(MSE_alpha)
%% V. Influence de l�int�gration sur le pixel sur la Super-r�solution
% SS ech+ integration sur pixel
Nim=10; % Nim repr�sente le nbr d'image de la pile
alpha = 10;
I1=zeros(size(I,1),size(I,2),Nim);
I2=zeros(round(size(I,1)/f),round(size(I,2)/f),Nim);
txty=f*rand(2,Nim)-(f/2)+alpha*randn(size(txty)); %% txty repr�sente le d�calage ajouter � chaque image
txty(:,1)=[0,0];
h = fspecial("average",[4 4]);
if aff==1 ,figure('Name','pile d''images'),end
for c=1:Nim
    xform = [ 1  0  0;        0  1  0;   txty(1,c) txty(2,c)  1 ]; %Matrice de translation
    tform_translate = maketform('affine',xform); 
    I1(:,:,c)= imtransform(I, tform_translate,'XData',[1 size(I,2)],'YData',[1 size(I,1)],'FillValues',mean(I(:)));%??
    I2(:,:,c)=I1(1:f:end,1:f:end,c);%on tranque les pixels de bords
    I2(:,:,c)= imfilter(I2(:,:,c),h);
    if aff==1,    imshow(I2(:,:,c),[],'InitialMagnification','fit');colorbar;axis on;title(sprintf('image n� %d',c));pause(0.1),end
	save('pile.mat','I2','txty');
end
% Super res 
% Interpolation et recalage
NimSR = Nim;
% Creation d'une grille d'interpolation
[X,Y]=meshgrid(1:f:size(I,2),1:f:size(I,1)); 
[Xi,Yi]=meshgrid(1:size(I,2),1:size(I,1));
% Recalage 
Xt=zeros(size(X,1),size(X,2)*NimSR);
Yt=Xt;
datat=Xt;
% les lignes suivantes servent � faire le recalage de la pile d'image
for c=1:NimSR % NimSR est le nombre d�images de la pile que l�on traite
    % pour obtenir l�image super-r�solue
    Xt(:,(size(X,2)*(c-1)+1):(size(X,2)*(c)))=X-txty(1,c);
    Yt(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=Y-txty(2,c);
    datat(:,(size(Y,2)*(c-1)+1):(size(Y,2)*(c)))=I2(:,:,c);
end
% la ligne suivante sert � faire l'interpolation
ISR_integ = griddata(Xt,Yt,datat,Xi,Yi,'cubic');
figure;
imshow(ISR_integ,[]);title("Image Super r�solue + integrationSurPixel");colorbar;axis on;
% L'integration sur le pixel r�duit la qualit� de l'image 
%% VI.Estimation des d�calages entre images sous-r�solues
dbtype("MaxSubPixel2.m");

