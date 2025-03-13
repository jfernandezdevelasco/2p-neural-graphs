% Dictonary with state and depth
an = 'Anesthetized'; aw = 'Awake';
d1 = '60';d2 = '150';d3 = '500';
d_s_d = containers.Map();

%% Example experiment conducted on the 23/02/25 with acquisitions taken at 3 cortical depths and 2 different states

% anesthetized
d_s_d('250223_001') = {an,d1};d_s_d('250223_002') = {an,d2};d_s_d('250223_003') = {an,d3};

%awake
d_s_d('250223_004') = {aw,d3};d_s_d('250223_005') = {aw,d2};d_s_d('250223_006') = {aw,d1};

save('d_s_d.mat', 'd_s_d');