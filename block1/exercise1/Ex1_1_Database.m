%% 280812 - Advanced Ship Design - Assignment 1 / Exercise 1 - Question 1
% Descripción de la base de datos. Solo funciones base de MATLAB (sin toolboxes).
clear; clc; close all;

questionName='Ex1_1_Database'; % carpeta de resultados de este apartado (dentro de outputs)

%% Database
% Carga la base definida en database_OTB.m:
run database_OTB.m
fprintf('Base de datos: %d buques, %d columnas\n\n',nsamples,width(T));

%% Available data
% Cuántos buques tienen cada variable. Cada relación (preguntas 3 y 4) se calcula con los
% buques que tienen sus dos variables; las filas completas hacen falta para la regresión multivariable.
navailable=sum(~isnan(DB));
disp(table(DBfeatureName',navailable','VariableNames',{'Feature','Nships'}))
fprintf('Buques con todas las variables: %d\n\n',sum(complete));

%% Descriptive statistics
stats=[navailable; mean(DB,'omitnan'); std(DB,'omitnan'); min(DB); median(DB,'omitnan'); max(DB)];
stats=array2table(stats,'VariableNames',DBfeatureName,'RowNames',{'n','media','desv_tipica','min','mediana','max'});
disp(stats)

%% Labels
% Reparto de los buques por etiqueta, en toda la base y en las filas completas (para el ejercicio 2)
LabelName={'CA_puerto_base','Censo_modalidad'};
for ilabel=1:numel(LabelName)
    [category,~,idx]=unique(string(T.(LabelName{ilabel})));
    count=table(category,accumarray(idx,1),accumarray(idx,double(complete)),'VariableNames',{LabelName{ilabel},'Nships','Ncomplete'});
    disp(sortrows(count,'Nships','descend'))
end

%% Save
writetable(stats,fullfile(outputFolder,'ex1_p1_descriptiva.csv'),'WriteRowNames',true);
fprintf('Tabla guardada en %s\n',outputFolder);
