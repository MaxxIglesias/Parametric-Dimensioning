function SaveFigure(obj,filename,resolution)
% Guarda una figura (o unos ejes) como PNG con la resolución indicada; crea la carpeta si no existe.
% Si el archivo está ocupado un instante (pasa en carpetas de OneDrive al sobrescribirlo),
% espera un segundo y lo reintenta.
    folder=fileparts(filename);
    if ~isfolder(folder), mkdir(folder); end
    for itry=1:5
        try
            exportgraphics(obj,filename,'Resolution',resolution);
            return
        catch
            pause(1)
        end
    end
    exportgraphics(obj,filename,'Resolution',resolution); % último intento: si falla, muestra el error
end
