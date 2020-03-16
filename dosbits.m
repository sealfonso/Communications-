clearvars
clc

%% Transformación RGB  a Datos binarios
Tb=5e-8; %tiempo de bit

ima=imread('foto-pixelada.jpg'); %importar imagen
imagen=imresize(ima,[20 20]); %reescalamiento de bits de la imagen importada

binario=dec2bin(imagen); %matriz en binario que guarda los elementos de la matriz RGB'imagen'
L=[]; %inicialización de vector que guarda los elementos binarios de la matriz RGB.

[x y]=size(binario); %x=número de elementos y y=cantidad de bit por elemento

contador=0;

% arreglo que guarda cada posición de la matriz RGB binaria en una posición del
% vector L
for i=1:x
    for j=1:y
        contador=contador+1;
        L(contador)=str2num(binario(i,j));
    end
end

%% buffer
%generación de dos señales con el mismo tamaño del vector L, que guardan
%la mitad de la información de L, cada una.

y1=zeros(1,length(L));
y2=zeros(1,length(L));
k=1;
l=2;
for i=1:1:length(L)
    if k<=length(L) && l<=length(L)
        y1(k:k+1)=[L(k) L(k)];
        y2(k:k+1)=[L(l) L(l)];
        k=k+2;
        l=l+2;
    end
end

%generación de estructuras con tiempo de los vectores y1 y y2, para ser
%importados a simulink

for i=1:length(L)
    t(i)=i*Tb; %creación del vector tiempo, con tamaño y1=y2 a espacios de Tb
end

%estructura con tiempo del vector y1
var1.time=[t'];
var1.signals.values=[y1'];
var1.signals.dimensions=[1];

%estructura con tiempo del vector y1
var2.time=[t'];
var2.signals.values=[y2'];
var2.signals.dimensions=[1];

%% simulink
%llama el código de simulink que realiza modulación digital 4QAM
errores = zeros(1,10);
for m = 1:10
%inicialización de variables
fs=5e6; %Frecuencia de Muestreo
No2=2.5059e-06:1e-6:11.5059e-6; %Potencia del Ruido
No=No2(m);
sim('QAM4.slx')

%unbuffer
%recontrucción de la señal L a partir de los datos del demodulador 4QAM del
%código de simmulink.

x1=zeros(1,length(sal1)); %inicialización del vector de reconstrucción
k=1;
for i=1:2:length(sal1)
    x1(k:k+1)=[sal1(i) sal2(i)];
    k=k+2;
end

%conteo de errores
%comparación entre vector reconstruido x1 y vector L

NumErrores=4;%inicialización de número de errores en 4 debido al corrimiento de 4 bits de la señal x1.

L1 = [x1(5:length(x1)) 0 0]; %concatenación del vector reconstruido y 0 0 0 para que el tamaño del vector sea múltiplo de 8 bits

for i=1:(length(L))
    if L(i)~=L1(i)
        errores(m)=errores(m)+1;%conteo de errores
    end
end
NumErrores = NumErrores+errores;
end

%% reconstrucción de matriz RGB
%
recon=zeros(size(imagen));%inicialización de matrizreconstruida RGB

[e p]=size(imagen);
Npixel=1:8:length(L); %Vector que indica el número de pixeles existentes en el vector L1
pixel=zeros(1,length(Npixel)); %vector del tamaño del número de pixeles

contador1=0;
for v=1:p
    for u=1:e
        for w=1:length(Npixel)
            
            im_rec=num2str(L1(Npixel(w):Npixel(w)+7)); %asignación de 8 bits del vector L1 a variable im_rec
            
            pixel(w)=bin2dec(im_rec);%asignación de 8bits binarios a número decimal 
            
        end
        contador1=contador1+1;
        recon(u,v)=pixel(contador1);%asignación de número decimal a estructura RGB
    end
end
recon=uint8(recon);%cambio de formato double de la matriz recon a uint8 (RGB)

%% visualización imagenes
%ilustración imagen original 'imagen' e imagen reconstruida 'recon'
figure(1)
image(imagen);
title('Imagen Original')
figure(2)
image(recon);
title('Imagen Recuperada - 4QAM')
%%
figure(3)
plot(No2,errores);
title('Errores vs Potencia del ruido - 4QAM')
xlabel('Potencia del ruido')
ylabel('Errores')