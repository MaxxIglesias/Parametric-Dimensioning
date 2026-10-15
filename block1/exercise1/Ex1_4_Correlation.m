%% 280812 - Advanced Ship Design - Assignment 1 / Exercise 1 - Question 4
% Matriz de correlación de D = [Y, X]. Solo funciones base de MATLAB (sin toolboxes).
clear; clc; close all;

questionName='Ex1_4_Correlation'; % carpeta de resultados de este apartado (dentro de outputs)

tolerance=0.8; % se considera buena correlación de +0.8 a +1 y de -0.8 a -1

%% Database
% Carga la base definida en database_OTB.m:
run database_OTB.m

%% Correlation Matrix
% rho_ij = cov(D_i,D_j)/(sigma_i*sigma_j)  (Ec. 4.7). Cada celda se calcula con los buques que
% tienen sus dos variables ('pairwise'); N dice cuántos son en cada celda.
R=corrcoef(DB,'Rows','pairwise');
N=double(~isnan(DB))'*double(~isnan(DB));

Rtable=array2table(R,'VariableNames',DBfeatureName,'RowNames',DBfeatureName);
Ntable=array2table(N,'VariableNames',DBfeatureName,'RowNames',DBfeatureName);
disp('Matriz de correlación [Y, X]:'); disp(Rtable)
disp('Número de buques en cada celda:'); disp(Ntable)

%% Post-process information
% Correlación con signo
figure(1);clf;set(gcf,'Color','w');
heatmap(DBlabelData,DBlabelData,R,'Colormap',DivergingColormap(256),'ColorLimits',[-1,1]);
if ~boolDefinitive, title('Correlación con signo'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p4_correlacion.png'),200);

% Número de buques con el que se ha calculado cada celda
figure(2);clf;set(gcf,'Color','w');
heatmap(DBlabelData,DBlabelData,N);
if ~boolDefinitive, title('Número de buques en cada celda'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p4_n_buques.png'),200);

% Correlación absoluta
figure(3);clf;set(gcf,'Color','w');
heatmap(DBlabelData,DBlabelData,abs(R),'ColorLimits',[0,1]);
if ~boolDefinitive, title('Correlación absoluta'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p4_correlacion_absoluta.png'),200);

% Correlación al cuadrado
figure(4);clf;set(gcf,'Color','w');
heatmap(DBlabelData,DBlabelData,R.^2,'ColorLimits',[0,1]);
if ~boolDefinitive, title('Correlación al cuadrado'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p4_correlacion_cuadrado.png'),200);

%% Set a boolean matrix according to certain criteria
% Celdas cuya correlación absoluta es mayor o igual que la tolerancia
figure(5);clf;set(gcf,'Color','w');
heatmap(DBlabelData,DBlabelData,double(abs(R)>=tolerance),'ColorLimits',[0,1]);
if ~boolDefinitive, title(sprintf('Criterio de correlación absoluta (|r| >= %g)',tolerance)); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p4_correlacion_criterio.png'),200);

%% Save
writetable(Rtable,fullfile(outputFolder,'ex1_p4_correlacion.csv'),'WriteRowNames',true);
writetable(Ntable,fullfile(outputFolder,'ex1_p4_n_buques.csv'),'WriteRowNames',true);
fprintf('Tablas guardadas en %s\nFiguras guardadas en %s\n',outputFolder,figureFolder);

%% Miscellania Functions, no need to be read

%% Diverging Colormap
% Azul (-1) - blanco (0) - rojo (+1), con m colores
function cmap=DivergingColormap(m)
    h=floor(m/2);
    blue=[linspace(0.15,1,h)',linspace(0.35,1,h)',linspace(0.70,1,h)'];
    red=[linspace(1,0.70,m-h)',linspace(1,0.15,m-h)',linspace(1,0.15,m-h)'];
    cmap=[blue;red];
end
