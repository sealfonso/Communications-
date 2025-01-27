clearvars
clc

%% Transformaci�n RGB  a Datos binarios
Tb=5e-8; %tiempo de bit

ima=imread('foto-pixelada.jpg'); %importar imagen
imagen=imresize(ima,[20 20]); %reescalamiento de bits de la imagen importada

binario=dec2bin(imagen); %matriz en binario que guarda los elementos de la matriz RGB'imagen'
L=[]; %inicializaci�n de vector que guarda los elementos binarios de la matriz RGB.

[x y]=size(binario); %x=n�mero de elementos y y=cantidad de bit por elemento

contador=0;

% arreglo que guarda cada posici�n de la matriz RGB binaria en una posici�n del
% vector L
for i=1:x
    for j=1:y
        contador=contador+1;
        L(contador)=str2num(binario(i,j));
    end
end

%% buffer
%generaci�n de dos se�ales con el mismo tama�o del vector L, que guardan
%la mitad de la informaci�n de L, cada una.

y1=zeros(1,length(L));
y2=zeros(1,length(L));
y3=zeros(1,length(L));
y4=zeros(1,length(L));
y5=zeros(1,length(L));
y6=zeros(1,length(L));
k=1;
l=2;
p=3;
a=4;
b=5;
c=6;
for i=1:1:length(L)
    if k<=length(L) && l<=length(L) && p<=length(L) && a<=length(L) && b<=length(L) && c<=length(L)
        y1(k:k+5)=[L(k) L(k) L(k) L(k) L(k) L(k)];
        y2(k:k+5)=[L(l) L(l) L(l) L(l) L(l) L(l)];
        y3(k:k+5)=[L(p) L(p) L(p) L(p) L(p) L(p)];
        y4(k:k+5)=[L(a) L(a) L(a) L(a) L(a) L(a)];
        y5(k:k+5)=[L(b) L(b) L(b) L(b) L(b) L(b)];
        y6(k:k+5)=[L(c) L(c) L(c) L(c) L(c) L(c)];
        k=k+6;
        l=l+6;
        p=p+6;
        a=a+6;
        b=b+6;
        c=c+6;
    end
end

%generaci�n de estructuras con tiempo de los vectores y1 y y2, para ser
%importados a simulink

for i=1:length(L)
    t(i)=i*Tb; %creaci�n del vector tiempo, con tama�o y1=y2 a espacios de Tb
end

%estructura con tiempo del vector y1
var1.time=[t'];
var1.signals.values=[y1]';
var1.signals.dimensions=[1];

%estructura con tiempo del vector y2
var2.time=[t'];
var2.signals.values=[y2'];
var2.signals.dimensions=[1];

%estructura con tiempo del vector y3
var3.time=[t'];
var3.signals.values=[y3'];
var3.signals.dimensions=[1];

%estructura con tiempo del vector y4
var4.time=[t'];
var4.signals.values=[y4'];
var4.signals.dimensions=[1];

%estructura con tiempo del vector y5
var5.time=[t'];
var5.signals.values=[y5'];
var5.signals.dimensions=[1];

%estructura con tiempo del vector y6
var6.time=[t'];
var6.signals.values=[y6'];
var6.signals.dimensions=[1];
%% simulink
%llama el c�digo de simulink que realiza modulaci�n digital 4QAM
errores = zeros(1,10);
for m = 1:10
%inicializaci�n de variables
fs=5e6; %Frecuencia de Muestreo
No2=2.5059e-06:1e-6:11.5059e-6; %Potencia del Ruido
No=No2(m);
sim('QAM64.slx')

%unbuffer
%recontrucci�n de la se�al L a partir de los datos del demodulador 4QAM del
%c�digo de simmulink.

x1=zeros(1,length(sal1)); %inicializaci�n del vector de reconstrucci�n
k=1;
for i=1:6:length(sal1)
    x1(k:k+5)=[sal1(i) sal2(i) sal3(i) sal4(i) sal5(i) sal6(i)];
    k=k+6;
end

%conteo de errores
%comparaci�n entre vector reconstruido x1 y vector L

NumErrores=6;%inicializaci�n de n�mero de errores en 4 debido al corrimiento de 4 bits de la se�al x1.

L1=x1(7:length(x1)); %concatenaci�n del vector reconstruido y 0 0 0 para que el tama�o del vector sea m�ltiplo de 8 bits

for i=1:(length(L))
    if L(i)~= L1(i)
        errores(m)=errores(m)+1;%conteo de errores
    end
end

NumErrores = NumErrores+errores;

end

%% reconstrucci�n de matriz RGB
%

recon=zeros(size(imagen));%inicializaci�n de matrizreconstruida RGB

[e p]=size(imagen);
Npixel=1:8:length(L); %Vector que indica el n�mero de pixeles existentes en el vector L1
pixel=zeros(1,length(Npixel)); %vector del tama�o del n�mero de pixeles

contador1=0;
for v=1:p
    for u=1:e
        for w=1:length(Npixel)
            
            im_rec=num2str(L1(Npixel(w):Npixel(w)+7)); %asignaci�n de 8 bits del vector L1 a variable im_rec
            
            pixel(w)=bin2dec(im_rec);%asignaci�n de 8bits binarios a n�mero decimal 
            
        end
        contador1=contador1+1;
        recon(u,v)=pixel(contador1);%asignaci�n de n�mero decimal a estructura RGB
    end
end
recon=uint8(recon);%cambio de formato double de la matriz recon a uint8 (RGB)

%% visualizaci�n imagenes
%ilustraci�n imagen original 'imagen' e imagen reconstruida 'recon'
figure(1)
image(imagen);
title('Imagen Original')
figure(2)
image(recon);
title('Imagen Recuperada - 64QAM')
%%
figure(3)
plot(No2,errores);
title('Errores vs Potencia del ruido - 64QAM')
xlabel('Potencia del ruido')
ylabel('Errores')