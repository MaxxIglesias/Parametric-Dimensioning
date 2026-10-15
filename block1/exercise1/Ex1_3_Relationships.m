%% 280812 - Advanced Ship Design - Assignment 1 / Exercise 1 - Question 3
% Relación entre las salidas (Y_i) y las entradas (X_j), y entre las propias entradas,
% con regresión lineal de una variable. Solo funciones base de MATLAB (sin toolboxes).
clear; clc; close all;

questionName='Ex1_3_Relationships'; % carpeta de resultados de este apartado (dentro de outputs)

boolIndividual=true; % si true, guarda además un PNG por cada relación en la carpeta individuales

%% Database
% Carga la base definida en database_OTB.m:
run database_OTB.m

individualFolder=fullfile(figureFolder,'individuales');
if boolIndividual && ~isfolder(individualFolder), mkdir(individualFolder); end

%% Uniquevariate Linear Regression
% Para cada pareja se ajusta y = beta1*x + beta0 con beta = (X_'*X_)\(X_'*y)  (Ec. 4.3),
% donde X_ = [1, x] lleva la columna de unos que da el término independiente beta0 (Ec. 4.2).
% Cada pareja usa todos los buques que tienen sus dos variables, así que n cambia de una a otra.
% El ajuste y la gráfica los hace ParametricPlot (al final); los resultados se guardan en esta tabla:
relations=table('Size',[0 7],'VariableTypes',{'string','string','double','double','double','double','double'}, ...
    'VariableNames',{'y','x','n','r','R2','beta1','beta0'});

%% Post-process information

%% 1) Outputs vs inputs (Y_i vs X_j)
figure(1);clf;set(gcf,'Color','w','Position',[50 50 380*nXfeatures 270*nYfeatures]);
for iy=1:nYfeatures
for ix=1:nXfeatures

    i=nXfeatures*(iy-1)+ix; % de iterador (iy,ix) a posición del subplot
    ax=subplot(nYfeatures,nXfeatures,i);

    [n,r,beta]=ParametricPlot(X(:,ix),Y(:,iy),XlabelData{ix},YlabelData{iy},complete,boolDefinitive);
    relations(end+1,:)={YfeatureName{iy},XfeatureName{ix},n,r,r^2,beta(2),beta(1)};

    if boolIndividual
        SaveFigure(ax,fullfile(individualFolder,sprintf('ex1_p3_YvsX_%s_vs_%s.png',YfeatureName{iy},XfeatureName{ix})),300);
    end

end
end
if ~boolDefinitive, sgtitle('Relación entre salidas Y_i y entradas X_j'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p3_Y_vs_X.png'),200);

%% 2) Inputs vs inputs (X_i vs X_j)
pairs=nchoosek(1:nXfeatures,2); % todas las parejas de entradas
figure(2);clf;set(gcf,'Color','w','Position',[80 80 380*size(pairs,1) 300]);
for ipair=1:size(pairs,1)

    ix=pairs(ipair,1); iy=pairs(ipair,2);
    ax=subplot(1,size(pairs,1),ipair);

    [n,r,beta]=ParametricPlot(X(:,ix),X(:,iy),XlabelData{ix},XlabelData{iy},complete,boolDefinitive);
    relations(end+1,:)={XfeatureName{iy},XfeatureName{ix},n,r,r^2,beta(2),beta(1)};

    if boolIndividual
        SaveFigure(ax,fullfile(individualFolder,sprintf('ex1_p3_XvsX_%s_vs_%s.png',XfeatureName{iy},XfeatureName{ix})),300);
    end

end
if ~boolDefinitive, sgtitle('Relación entre entradas X_i y X_j'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p3_X_vs_X.png'),200);

%% 3) Outputs vs outputs (Y_i vs Y_j)
% Complementario: ayuda a discutir qué relaciones son lineales
pairs=nchoosek(1:nYfeatures,2); % todas las parejas de salidas
ncolumns=3; nrows=ceil(size(pairs,1)/ncolumns);
figure(3);clf;set(gcf,'Color','w','Position',[110 110 380*ncolumns 270*nrows]);
for ipair=1:size(pairs,1)

    ix=pairs(ipair,1); iy=pairs(ipair,2);
    ax=subplot(nrows,ncolumns,ipair);

    [n,r,beta]=ParametricPlot(Y(:,ix),Y(:,iy),YlabelData{ix},YlabelData{iy},complete,boolDefinitive);
    relations(end+1,:)={YfeatureName{iy},YfeatureName{ix},n,r,r^2,beta(2),beta(1)};

    if boolIndividual
        SaveFigure(ax,fullfile(individualFolder,sprintf('ex1_p3_YvsY_%s_vs_%s.png',YfeatureName{iy},YfeatureName{ix})),300);
    end

end
if ~boolDefinitive, sgtitle('Relación entre salidas Y_i y Y_j'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p3_Y_vs_Y.png'),200);

%% Results
disp(relations)
writetable(relations,fullfile(outputFolder,'ex1_p3_relaciones.csv'));
fprintf('Tabla guardada en %s\nFiguras guardadas en %s\n',outputFolder,figureFolder);

%% Miscellania Functions, no need to be read

%% Parametric Postprocessing Function
% Ajusta y = beta1*x + beta0 con los buques que tienen los dos datos y lo dibuja en los ejes actuales.
% Devuelve n (buques usados), r (correlación) y beta = [beta0; beta1].
function [n,r,beta]=ParametricPlot(x,y,xlabelstr,ylabelstr,complete,boolDefinitive)

    available=~isnan(x)&~isnan(y); % buques que tienen las dos variables
    n=sum(available);

    X_=[ones(n,1),x(available)];  % columna de unos para el término independiente
    beta=(X_'*X_)\(X_'*y(available));
    r=corrcoef(x(available),y(available)); r=r(1,2);

    xx=[min(x(available));max(x(available))]; % extremos de la recta
    hold on
        plot(x(available),y(available),'o','MarkerSize',4,'Color',[0.55 0.72 0.90]) % todos los disponibles
        plot(x(complete),y(complete),'o','MarkerSize',4,'MarkerFaceColor',[0.15 0.35 0.65],'MarkerEdgeColor','none') % los que tienen todas las variables
        plot(xx,beta(1)+beta(2)*xx,'-','LineWidth',1.5,'Color',[0.80 0.25 0.20])
    hold off
    grid on; box on;
    xlabel(xlabelstr); ylabel(ylabelstr);
    if boolDefinitive % informe: en inglés y sin título (los coeficientes están en ex1_p3_relaciones.csv)
        legend({sprintf('available data (n = %d)',n),sprintf('complete records (n = %d)',sum(complete)), ...
            sprintf('linear fit (r = %.3f)',r)},'Location','best','FontSize',7)
    else
        title(sprintf('y = %.3g x %+.3g   (r = %.3f, R^2 = %.3f)',beta(2),beta(1),r,r^2),'FontWeight','normal','FontSize',8)
        legend({sprintf('disponibles (n = %d)',n),sprintf('completos (n = %d)',sum(complete)),'regresión'},'Location','best','FontSize',7)
    end

end
