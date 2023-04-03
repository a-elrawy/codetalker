clear all
%% preprocess dataset for our method (spectral)

addpath('data_preprocess/Utils/');

% read adequate files
sourcepath = 'rigid_scans/';  %data path
targetpath = 'BIWI_Process/template/'; % Define your own targetpath for outputs
filetype = 'obj';
datafolder = [sourcepath];
filename = fullfile([datafolder ''], ['*.' filetype]);
files = dir(filename);
n_files = length(files);


% start pre-processing
for pts = 1:n_files
    sourcename = split(files(pts).name, '.'); % split to get rid of file extension
    sourcename = sourcename{1} ; % print the name
    Vname = [datafolder files(pts).name];
    
    savefolder_off = [targetpath 'off/'];
    savename_off = strcat(savefolder_off, sourcename, '.off');  % build off file (not really necessary, but needed to build matlab shape object)
    % savename_off = strcat(savefolder_off, sourcename, '.ply');
    savename_off_dir = savefolder_off;

    if ~exist(savename_off_dir, 'dir')
       mkdir(savename_off_dir);
    end
    
    [xxx, yyy,V_template,T_template] = readObj_my(Vname);
    T = T_template;
    V = V_template;
  
    %scatter3(V(1,:),V(2,:),V(3,:))
    
    % the case (here setup for BIWI)
    theta = pi;
    c = cos(theta);
    s = sin(theta);
    rotx = [1 0 0; 0 c -s; 0 s c];
    V = V * rotx;
    
   
    %trisurf(T,V(:,1),V(:,2),V(:,3))
    
        
    % rotate shapes if needed so that they are y-aligned if this is not yet
    % the case (here setup for SHREC)
    %%%%%%%%%%%%%%%%%%%%%%%%%%
    %if ismember(str2num(sourcename), [1,16,17,22,23,24,25,29,30,31,32,33,34,35,36,37,38,39])  % SHREC
    %{
    if ismember(str2num(sourcename), [16,17,22,23,24,25,29,30,31,32,33,34,35,36,37,38,39])  %SHREC_r
        ['ROTATING' sourcename]
        theta = (1/2) * pi;
        c = cos(theta);
        s = sin(theta);
        rotx = [1 0 0; 0 c -s; 0 s c];
        V = V * rotx;
    end
    
    if ismember(str2num(sourcename), [28])
        ['ROTATING' sourcename]
        theta = pi;
        c = cos(theta);
        s = sin(theta);
        rotx = [1 0 0; 0 c -s; 0 s c];
        V = V * rotx;
    end
    %}
    %%%%%%%%%%%
    %(here setup for SCAPE -- no need of setup for FAUST)
%     theta = (-1/2) * pi;
%     c = cos(theta);
%     s = sin(theta);
%     rotz = [c -s 0; s c 0; 0 0 1];
%     V = V * rotz;
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    
    writeOFF(savename_off, V - mean(V, 1), T); % if we choose to center the shape (can be useful but then do not forget to center training shapes)

    S1 = read_off_shape(savename_off);
    
    % BE CAREFUL to rescale with total surface parameter and save again if needed
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    S1 = MESH.compute_normalize(S1);
    s = S1.sqrt_area;
    disp(['total area :' num2str(s)])
    S1.surface.VERT = S1.surface.VERT/s;
    
    writeOFF(savename_off, S1.surface.VERT, S1.surface.TRIV);

    VERT = S1.surface.VERT;
    TRIV = S1.surface.TRIV;
    X = VERT(:,1); Y = VERT(:,2); Z = VERT(:,3);
    savefolder_vert = [targetpath 'vert/'];
    savename_vert = strcat(savefolder_vert,sourcename, '.mat');  % build off file (not really necessary, but needed to build matlab shape object)
    savename_vert_dir = savefolder_vert;
    if ~exist(savename_vert_dir, 'dir')
       mkdir(savename_vert_dir);
    end
    
    save(savename_vert,'VERT','TRIV','X','Y','Z');
    
    %%%%%%%%%%%%%%%%%%%%%%%
    
    
end

