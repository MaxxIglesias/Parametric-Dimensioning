%% Database
% Arrastreros de fondo (OTB) españoles de 21-27 m de eslora: cruce de RGFP + EU Fleet
% Register + Sea-web (BBDD Fishing Vessels 21-27m, por número IMO). Una fila por buque.
% Este archivo solo define la base de datos; los demás lo cargan con "run database_OTB.m".
filename='Cruce_RGFP_FV21-27m_OTB.csv';

% Carpeta de este archivo: el csv se lee de aquí y los resultados se guardan aquí dentro
% (en "outputs"), sea cual sea la carpeta actual de MATLAB.
baseFolder=fileparts(which('database_OTB.m'));

%% Input and Output Features
% Entradas (X): lo que fija el requisito de diseño (buque de ~24 m).
% Salidas (Y): dimensiones a obtener.
% Cada variable lleva el nombre de su columna en el csv y su texto para las gráficas
% (misma cantidad y mismo orden en las dos listas).
XfeatureName={'LOA_m','GT'};
XlabelData={'L_{OA} [m]','GT'};

YfeatureName={'Lpp_m','B_m','D_m','T_m','Potencia_kW'};
YlabelData={'L_{pp} [m]','B [m]','D [m]','T [m]','P_B [kW]'};
% B_m, D_m y T_m vienen de Sea-web: D_m es el puntal (Depth) y T_m el calado (Draught)

%% Figures
% true  = versión definitiva para el informe: texto en inglés y sin títulos, en outputs/outputs_def
% false = versión de trabajo: texto en español y con títulos, en outputs
boolDefinitive=true;

%% Load the database
opts=detectImportOptions(fullfile(baseFolder,filename),'Encoding','UTF-8');
opts.VariableNamingRule='preserve';
T=readtable(fullfile(baseFolder,filename),opts); % tabla completa, con todas las columnas del csv (etiquetas incluidas)

X=T{:,XfeatureName}; % matriz de entradas, NaN donde falta el dato
Y=T{:,YfeatureName}; % matriz de salidas, NaN donde falta el dato
DB=[Y,X];            % D := [Y, X]  (Ec. 4.7)
DBfeatureName=[YfeatureName,XfeatureName];
DBlabelData=[YlabelData,XlabelData];

nsamples=size(DB,1);        % número de buques
nXfeatures=size(X,2);       % número de entradas
nYfeatures=size(Y,2);       % número de salidas
complete=all(~isnan(DB),2); % buques que tienen todas las variables de X e Y

% Cada apartado guarda en su propia carpeta outputs/<questionName> (questionName lo define el script)
if ~exist('questionName','var'), questionName=''; end
outputFolder=fullfile(baseFolder,'outputs',questionName); % carpeta de las tablas (csv) del apartado
if boolDefinitive
    figureFolder=fullfile(outputFolder,'outputs_def');     % carpeta de las figuras
else
    figureFolder=outputFolder;
end
if ~isfolder(outputFolder), mkdir(outputFolder); end

clear opts % variable temporal
