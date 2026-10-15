%% 280812 - Advanced Ship Design - Assignment 1 / Exercise 1 - Question 6
% Parámetros obtenidos con formulación empírica de la literatura (pesqueros): primero se comprueba
% que el diseño del 1.5 está en magnitud y después se calculan los parámetros que faltan.
% Solo funciones base de MATLAB (sin toolboxes). Hay que ejecutar antes Ex1_5_LinearRegression.
clear; clc; close all;

questionName='Ex1_6_EmpiricalParameters'; % carpeta de resultados de este apartado (dentro de outputs)

rho=1.025;           % densidad del agua de mar [t/m3]
g=9.81;              % gravedad [m/s2]
knot=0.5144;         % 1 nudo en m/s
Nselected=70;        % % de entrenamiento elegido en el 1.5: su RMSE de test es la incertidumbre del diseño
boolIndividual=true; % si true, guarda además un PNG por cada gráfica en la carpeta individuales

%% Database
% Carga la base definida en database_OTB.m:
run database_OTB.m
shipLpp=T.Lpp_m; shipB=T.B_m; shipD=T.D_m; shipT=T.T_m; shipV=T.Velocidad_kn; % buques de la base

%% Design from Question 5
% Dimensiones del buque de diseño y error de test, leídos de las tablas guardadas por Ex1_5
q5Folder=fullfile(baseFolder,'outputs','Ex1_5_LinearRegression');
regression=readtable(fullfile(q5Folder,'ex1_p5_regresion.csv'),'ReadRowNames',true);
errorN=readtable(fullfile(q5Folder,'ex1_p5_error_N.csv'));
design.Lpp=regression{'design','Lpp_m'}; design.B=regression{'design','B_m'};
design.D=regression{'design','D_m'};     design.T=regression{'design','T_m'};
irow=errorN.N==Nselected; % fila del porcentaje de entrenamiento elegido
rmse.B=errorN.B_m_RMSE_test(irow); rmse.D=errorN.D_m_RMSE_test(irow); rmse.T=errorN.T_m_RMSE_test(irow);

%% Literature Formulas
% Papanikolaou (2014), Ship Design, App. A: 637 pesqueros (IHS Fairplay 2011), Lpp de ~20 a 130 m
LBpapa=@(L)1.8006*log(L)-2.367;           % Lpp/B,         fig. A.140, p. 511 (R2 = 0.80)
BTpapa=@(L)0.0002*L.^2-0.0268*L+3.2082;   % B/T,           fig. A.141, p. 511 (R2 = 0.16)
LVpapa=@(L)0.9107*log(L)+0.9635;          % Lpp/vol^(1/3), fig. A.142, p. 511 (R2 = 0.55)
CBpapa=@(L)0.2882*L.^0.1808;              % C_B,           fig. A.144, p. 512 (R2 = 0.33)
Vpapa=@(L)3.7358*L.^0.3102;               % V [kn],        fig. A.145, p. 512 (R2 = 0.77)
% Potencia (fig. A.147) en espera: su base empieza en ~22 m de Lpp y queda fuera de rango
% Capacidad frigorífica [ft3] de 139 pesqueros (Lpp >= ~22 m); sus versiones en "TEU" son en realidad m3 (= ft3/35.31)
HOLDpapa=@(L)7.9873*L.^2.0778;            % frente a Lpp,  fig. A.150, p. 514 (R2 = 0.806, el mayor)
HOLDpapaB=@(B)15.144*B.^3.0943;           % frente a B,    fig. A.152, p. 515 (R2 = 0.800, contraste)
HOLDpapaD=@(D)774.89*D.^1.9626;           % frente a D,    fig. A.154, p. 515 (R2 = 0.656, contraste)
ft3=0.0283168;                            % 1 ft3 en m3
LDpapa=[8.2,9.0];                         % Lpp/D,         tabla 2.5, p. 102
CBtable=[0.53,0.56];                      % C_B de pesqueros, tabla 2.4, p. 102
% Papanikolaou da relaciones; las dimensiones se encadenan a partir de Lpp:
Bpapa=@(L)L./LBpapa(L);                   % B = Lpp/(L/B)
Tpapa=@(L)Bpapa(L)./BTpapa(L);            % T = B/(B/T)
Dpapa=@(L)L/mean(LDpapa);                 % D = Lpp/(Lpp/D), centro del rango
% Watson (1998), Practical Ship Design
CBwatson=@(Fn)0.70+atan((23-100*Fn)/4)/8; % C_B (Townsin), ec. 3.14, p. 76; franja de arrastreros Fn 0.345-0.42 (fig. 3.12)
BDwatson=1.65;                            % B/D de pesqueros, p. 69

%% Design Comparison
% Diseño del 1.5 frente a la literatura evaluada en el mismo Lpp. Se considera "en magnitud"
% si la diferencia es menor que el error de test del 1.5 (RMSE con N = Nselected).
parameter=["B [m]";"T [m]";"D [m] (Papanikolaou)";"D [m] (Watson)"];
designValue=[design.B;design.T;design.D;design.D];
literature=[Bpapa(design.Lpp);Tpapa(design.Lpp);Dpapa(design.Lpp);design.B/BDwatson];
difference=literature-designValue;
rmseTest=[rmse.B;rmse.T;rmse.D;rmse.D];
inMagnitude=abs(difference)<=rmseTest;
designComparison=table(parameter,designValue,literature,difference,rmseTest,inMagnitude);
disp(designComparison)

% Relaciones de dimensiones del diseño frente a las de la literatura
ratio=["Lpp/B";"B/T";"Lpp/D";"B/D"];
ratioDesign=[design.Lpp/design.B;design.B/design.T;design.Lpp/design.D;design.B/design.D];
ratioLiterature=[LBpapa(design.Lpp);BTpapa(design.Lpp);mean(LDpapa);BDwatson];
source=["Papanikolaou fig. A.140";"Papanikolaou fig. A.141";"Papanikolaou tabla 2.5 (8.2-9.0)";"Watson p. 69"];
ratioComparison=table(ratio,ratioDesign,ratioLiterature,source);
disp(ratioComparison)

%% Fleet Check
% Las fórmulas se aplican a los buques de la base y se mide su error (sesgo y RMSE); se compara con
% el de un ajuste lineal propio frente a Lpp con los mismos buques (criterio 3, p. 10 del enunciado).
check=["B (Papanikolaou)";"T (Papanikolaou)";"D (Papanikolaou)";"D (Watson)";"V (Papanikolaou)"];
real={shipB,shipT,shipD,shipD,shipV};
predicted={Bpapa(shipLpp),Tpapa(shipLpp),Dpapa(shipLpp),shipB/BDwatson,Vpapa(shipLpp)};
fleetCheck=table('Size',[numel(check),5],'VariableTypes',{'string','double','double','double','double'}, ...
    'VariableNames',{'check','n','bias','RMSE_literature','RMSE_own'});
for ic=1:numel(check)
    [n,bias,rmseLit,rmseOwn]=FleetError(shipLpp,real{ic},predicted{ic});
    fleetCheck(ic,:)={check(ic),n,bias,rmseLit,rmseOwn};
end
disp(fleetCheck)

%% Derived Parameters
% Parámetros adicionales que la base no tiene: velocidad de servicio y coeficiente de bloque
V=Vpapa(design.Lpp);                         % velocidad de servicio [kn], Papanikolaou fig. A.145
Fn=V*knot/sqrt(g*design.Lpp);                % número de Froude
CB=CBwatson(Fn);                             % C_B adoptado: Watson ec. 3.14 (depende de Fn)
CBcontrast=CBpapa(design.Lpp);               % C_B de Papanikolaou fig. A.144 (solo contraste, R2 = 0.33)
Delta=rho*CB*design.Lpp*design.B*design.T;   % desplazamiento [t]
DeltaPapa=rho*(design.Lpp/LVpapa(design.Lpp))^3; % desplazamiento de Papanikolaou fig. A.142 (contraste)
Vhold=HOLDpapa(design.Lpp)*ft3;              % capacidad frigorífica [m3] con Lpp (mayor R2)
VholdB=HOLDpapaB(design.B)*ft3;              % contraste con B
VholdD=HOLDpapaD(design.D)*ft3;              % contraste con D
holdRatio=Vhold/(design.Lpp*design.B*design.D); % fracción del volumen Lpp*B*D

derived=["V [kn]";"Fn";"C_B adoptado (Watson)";"C_B rango pesqueros (Papanikolaou tabla 2.4)"; ...
    "C_B contraste (Papanikolaou A.144)";"Delta [t]";"Delta [t] contraste (Papanikolaou A.142)"; ...
    "V_hold [m3] (Papanikolaou A.150, Lpp)";"V_hold [m3] contraste (A.152, B)";"V_hold [m3] contraste (A.154, D)"; ...
    "V_hold/(Lpp*B*D)"];
value=[V;Fn;CB;mean(CBtable);CBcontrast;Delta;DeltaPapa;Vhold;VholdB;VholdD;holdRatio];
derivedParameters=table(derived,value);
disp(derivedParameters)

% Validación: Fn dentro de la franja de arrastreros de Watson y C_B dentro del rango de pesqueros
if Fn<0.345 || Fn>0.42, fprintf('Aviso: Fn = %.3f fuera de la franja de arrastreros de Watson (0.345-0.42)\n',Fn); end
if CB<CBtable(1) || CB>CBtable(2)
    fprintf('Aviso: C_B = %.3f fuera del rango de pesqueros de la tabla 2.4 (%.2f-%.2f)\n',CB,CBtable);
else
    fprintf('C_B = %.3f dentro del rango de pesqueros de la tabla 2.4 (%.2f-%.2f)\n',CB,CBtable);
end
fprintf('Aviso: capacidad frigorífica extrapolada, Lpp = %.2f m por debajo del menor buque de las figs. A.149-A.154 (~22 m)\n',design.Lpp);

%% Post-process information
% Buques de la base, ajuste lineal propio y fórmula de la literatura frente a Lpp
individualFolder=fullfile(figureFolder,'individuales');
if boolIndividual && ~isfolder(individualFolder), mkdir(individualFolder); end
LppCurve=linspace(min(shipLpp)-0.5,max(shipLpp)+0.5,50)'; % esloras para dibujar las curvas
plotY={shipB,shipT,shipD,shipV};
plotLiterature={Bpapa(LppCurve),Tpapa(LppCurve),[LppCurve/LDpapa(1),LppCurve/LDpapa(2)],Vpapa(LppCurve)};
plotDesign=[design.B,design.T,design.D,NaN]; % la velocidad no sale del 1.5: sin punto de diseño
plotLabel={'B [m]','T [m]','D [m]','V [kn]'};
plotName={'B','T','D','V'};
figure(1);clf;set(gcf,'Color','w','Position',[50 50 760 540]);
for ip=1:numel(plotY)
    ax=subplot(2,2,ip);
    PlotCheck(shipLpp,plotY{ip},LppCurve,plotLiterature{ip},design.Lpp,plotDesign(ip),plotLabel{ip},boolDefinitive);
    if boolIndividual
        SaveFigure(ax,fullfile(individualFolder,sprintf('ex1_p6_%s_vs_Lpp.png',plotName{ip})),300);
    end
end
if ~boolDefinitive, sgtitle('Base de datos frente a la formulación de Papanikolaou (2014)'); end
SaveFigure(gcf,fullfile(figureFolder,'ex1_p6_literatura.png'),200);

%% Save
writetable(designComparison,fullfile(outputFolder,'ex1_p6_comparacion_diseno.csv'));
writetable(ratioComparison,fullfile(outputFolder,'ex1_p6_relaciones.csv'));
writetable(fleetCheck,fullfile(outputFolder,'ex1_p6_flota.csv'));
writetable(derivedParameters,fullfile(outputFolder,'ex1_p6_parametros.csv'));
fprintf('Tablas guardadas en %s\nFiguras guardadas en %s\n',outputFolder,figureFolder);

%% Miscellania Functions, no need to be read

%% Fleet Error Function
% Error de una fórmula de la literatura en los buques de la base (sesgo medio y RMSE) y RMSE de un
% ajuste lineal propio y = beta0 + beta1*x con los mismos buques.
function [n,bias,rmseLit,rmseOwn]=FleetError(x,y,yLit)
    available=~isnan(x)&~isnan(y)&~isnan(yLit);
    n=sum(available);
    err=yLit(available)-y(available);                  % error de la fórmula en cada buque
    bias=mean(err); rmseLit=sqrt(mean(err.^2));
    X_=[ones(n,1),x(available)];                       % columna de unos + Lpp
    beta=(X_'*X_)\(X_'*y(available));                  % ajuste lineal propio (Ec. 4.3)
    rmseOwn=sqrt(mean((y(available)-X_*beta).^2));
end

%% Comparison Plot Function
% Dibuja los buques, el ajuste lineal propio, la curva de la literatura y el punto de diseño.
function PlotCheck(x,y,xCurve,yCurve,xDesign,yDesign,ylabelstr,boolDefinitive)
    available=~isnan(x)&~isnan(y);
    n=sum(available);
    X_=[ones(n,1),x(available)];
    beta=(X_'*X_)\(X_'*y(available));                  % ajuste lineal propio
    hold on
        h1=plot(x(available),y(available),'o','MarkerSize',4,'MarkerFaceColor',[0.55 0.72 0.90],'MarkerEdgeColor','none');
        h2=plot(xCurve,beta(1)+beta(2)*xCurve,'-','LineWidth',1.5,'Color',[0.15 0.35 0.65]);
        h3=plot(xCurve,yCurve,'--','LineWidth',1.5,'Color',[0.80 0.25 0.20]); % 2 columnas = rango
        handles=[h1,h2,h3(1)];
        if ~isnan(yDesign)
            handles(4)=plot(xDesign,yDesign,'s','MarkerSize',7,'MarkerFaceColor',[0.10 0.10 0.10],'MarkerEdgeColor','k');
        end
    hold off
    grid on; box on; axis tight;
    xlabel('L_{pp} [m]'); ylabel(ylabelstr);
    if boolDefinitive
        text={sprintf('vessels (n = %d)',n),'own linear fit','Papanikolaou (2014)','design'};
    else
        text={sprintf('buques (n = %d)',n),'ajuste lineal propio','Papanikolaou (2014)','diseño'};
    end
    legend(handles,text(1:numel(handles)),'Location','best','FontSize',7)
end
