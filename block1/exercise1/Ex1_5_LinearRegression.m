%% 280812 - Advanced Ship Design - Assignment 1 / Exercise 1 - Question 5
% Regresión lineal multivariable: dimensiones del buque de diseño y error de test
% según el porcentaje de entrenamiento. Solo funciones base de MATLAB (sin toolboxes).
clear; clc; close all;

questionName='Ex1_5_LinearRegression'; % carpeta de resultados de este apartado (dentro de outputs)

designX=[24,120]; % buque de diseño: L_OA = 24 m y GT = 100 (mismo orden que XfeatureName)
vpercent=10:5:90;  % porcentajes de entrenamiento N que se prueban
nrepeat=100;       % veces que se repite el sorteo para cada N
rng(0);            % semilla del sorteo: cada ejecución da los mismos resultados
boolIndividual=true; % si true, guarda además un PNG por cada salida en la carpeta individuales

%% Database
% Carga la base definida en database_OTB.m:
run database_OTB.m

%% Multivariate Linear Regression
% Cada salida Y_i se ajusta con un plano Y_i = beta0 + beta1*L_OA + beta2*GT, con
% beta = (X_'*X_)\(X_'*Y) (Ec. 4.3), usando todos los buques que tienen las entradas y esa salida.
beta=zeros(nXfeatures+1,nYfeatures); % fila 1 = beta0, una fila más por entrada; una columna por salida
nsamplesY=zeros(1,nYfeatures);       % número de buques usados en cada salida
for iy=1:nYfeatures
    available=all(~isnan(X),2) & ~isnan(Y(:,iy));  % buques con las entradas y esta salida
    nsamplesY(iy)=sum(available);
    X_=[ones(nsamplesY(iy),1),X(available,:)];      % columna de unos (X0) + entradas
    beta(:,iy)=(X_'*X_)\(X_'*Y(available,iy));      % Ec. 4.3
end

%% Design Prediction
% Dimensiones del buque de diseño: se sustituye [1, L_OA, GT] en el plano de cada salida.
Ydesign=[1,designX]*beta; % una predicción por salida
designTable=array2table([nsamplesY;Ydesign],'VariableNames',YfeatureName,'RowNames',{'n','design'});
disp(designTable)

%% Training and Testing
% Para cada salida se barajan sus buques: el N % entrena (con él se calcula beta) y el resto es el
% test, que se predice con esa beta para medir el error. Cada N se repite nrepeat veces.
errTrain=nan(numel(vpercent),nYfeatures); % RMSE medio en entrenamiento (fila = N, columna = salida)
errTest=nan(numel(vpercent),nYfeatures);  % RMSE medio en test
mapeTest=nan(numel(vpercent),nYfeatures); % MAPE medio en test [%]
for iy=1:nYfeatures
    idx=find(all(~isnan(X),2) & ~isnan(Y(:,iy))); % posiciones de los buques disponibles para esta salida
    for ip=1:numel(vpercent)
        npercent=vpercent(ip);                     % porcentaje de entrenamiento N
        ntrain=round(npercent/100*numel(idx));     % número de buques de entrenamiento
        if ntrain<=nXfeatures+1 || ntrain==numel(idx), continue, end % más buques que coeficientes y al menos uno de test
        rmseTrain=zeros(nrepeat,1); rmseTest=zeros(nrepeat,1); mape=zeros(nrepeat,1); % errores de cada sorteo
        for irep=1:nrepeat
            shuffled=idx(randperm(numel(idx)));    % baraja los buques
            itrain=shuffled(1:ntrain);             % los ntrain primeros entrenan
            itest=shuffled(ntrain+1:end);          % el resto es el test

            X_=[ones(ntrain,1),X(itrain,:)];                         % columna de unos + entradas del entrenamiento
            b=(X_'*X_)\(X_'*Y(itrain,iy));                           % beta solo con el entrenamiento (Ec. 4.3)
            gTrain=Y(itrain,iy)-X_*b;                                % error en cada buque de entrenamiento
            gTest=Y(itest,iy)-[ones(numel(itest),1),X(itest,:)]*b;   % error en cada buque de test
            rmseTrain(irep)=sqrt(mean(gTrain.^2));                   % RMSE de entrenamiento
            rmseTest(irep)=sqrt(mean(gTest.^2));                     % RMSE de test
            mape(irep)=100*mean(abs(gTest./Y(itest,iy)));            % MAPE de test [%]
        end
        errTrain(ip,iy)=mean(rmseTrain); errTest(ip,iy)=mean(rmseTest); mapeTest(ip,iy)=mean(mape); % media de los sorteos
    end
end

%% Post-process information
% Error medio de entrenamiento y de test frente al porcentaje de entrenamiento N, una gráfica por salida
individualFolder=fullfile(figureFolder,'individuales');
if boolIndividual && ~isfolder(individualFolder), mkdir(individualFolder); end
ncolumns=3; nrows=ceil(nYfeatures/ncolumns);
figure(1);clf;set(gcf,'Color','w','Position',[50 50 380*ncolumns 270*nrows]);
for iy=1:nYfeatures
    ax=subplot(nrows,ncolumns,iy);
    plot(vpercent,errTrain(:,iy),'-o',vpercent,errTest(:,iy),'-s','MarkerSize',4,'LineWidth',1.2)
    grid on; box on;
    ylabel(['RMSE ',YlabelData{iy}]);
    if boolDefinitive % informe: en inglés y sin título
        xlabel('Training set N [%]'); legend({'training','test'},'Location','best','FontSize',7)
    else
        xlabel('Entrenamiento N [%]'); legend({'entrenamiento','test'},'Location','best','FontSize',7)
        title(sprintf('%s (n = %d)',YfeatureName{iy},nsamplesY(iy)),'Interpreter','none','FontWeight','normal','FontSize',8)
    end
    if boolIndividual
        SaveFigure(ax,fullfile(individualFolder,sprintf('ex1_p5_error_%s.png',YfeatureName{iy})),300);
    end
end
if ~boolDefinitive, sgtitle('Error medio de entrenamiento y de test frente al porcentaje de entrenamiento'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p5_error_N.png'),200);

%% Save
% Coeficientes, buques usados y predicción del diseño; y errores frente a N
resultTable=array2table([nsamplesY;beta;Ydesign],'VariableNames',YfeatureName, ...
    'RowNames',[{'n','beta0'},strcat('beta_',XfeatureName),{'design'}]);
errorTable=array2table([vpercent',errTrain,errTest,mapeTest],'VariableNames', ...
    [{'N'},strcat(YfeatureName,'_RMSE_train'),strcat(YfeatureName,'_RMSE_test'),strcat(YfeatureName,'_MAPE_test')]);
writetable(resultTable,fullfile(outputFolder,'ex1_p5_regresion.csv'),'WriteRowNames',true);
writetable(errorTable,fullfile(outputFolder,'ex1_p5_error_N.csv'));
fprintf('Tablas guardadas en %s\nFiguras guardadas en %s\n',outputFolder,figureFolder);
