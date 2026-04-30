global logger FUNKY_CHANNEL MOUSE_ID depthDuringRecording dateOfRecording KS_FOLDER DART_SORTED_FOLDER CatGT_FOLDER CatGT_FOLDER_filtered KS_FILTERED_FOLDER KS_FILTERED UNIT_OF_INTEREST UNIT_OF_INTEREST2 UNIT_OF_INTEREST_SLAVE UNIT_OF_INTEREST_SLAVES UNIT_OF_INTEREST_MASTER UNIT_OF_INTEREST_MASTERS UNIT_OF_INTEREST_CS ARR_DO_ANALYSES ANALYSIS_STEP_0 ANALYSIS_STEP_10 ANALYSIS_STEP_1 ANALYSIS_STEP_11 ANALYSIS_STEP_2 ANALYSIS_STEP_21 ANALYSIS_STEP_22 ANALYSIS_STEP_3 ANALYSIS_STEP_31 ANALYSIS_STEP_4 ANALYSIS_STEP_40 ANALYSIS_STEP_41 ANALYSIS_STEP_42 ANALYSIS_STEP_43 ANALYSIS_STEP_5 ANALYSIS_STEP_6 ANALYSIS_STEP_7 ANALYSIS_STEP_8 ANALYSIS_STEP_9 ANALYSIS_STEP_97 ANALYSIS_STEP_98 ANALYSIS_STEP_99 ANALYSIS_STEP_100 ANALYSIS_STEP_101...
        pathToParentRec pathToRecFolder pathToUnitsDataFolder pathToFigureFolder pathToCurationHelperFolder pathToWaveFormWithOtherUnits pathToRawVSFilteredWaveFormAlignedToLaser pathToGroupedWaveFormWithOtherUnits pathToRasterPSTH pathToCollaboratorsFolder pathToCCGs pathToCCGWRasterPSTH UNITS_AND_VARS_FILE_NAME UNITS_AND_VARS_FILE_NAME_KS_SORTED UNITS_FILE_NAME UNIT_CCG_PAIRS_FILE_NAME UNITS_AND_VARS_FILE_NAME_DART_SORTED pathKS pathDartSorted pathCatGT pathCatGT_filtered pathNpyxFiltered pathTPrime pathToFilteredRec tipLength ...
        NEURON_TYPE_MFB NEURON_TYPE_SS NEURON_TYPE_CS NEURON_TYPE_MLI NEURON_TYPE_GoC NEURON_TYPE_DCN NEURON_TYPE_OTHER NEURON_TYPES NEURON_TYPE_MLI1 NEURON_TYPE_MLI2 ...
        RAW_PRE_SPIKE RAW_POST_SPIKE RAW_PRE_SPIKE_WOTHERS RAW_POST_SPIKE_WOTHERS PRE_TIME_RASTER POST_TIME_RASTER MASTER_SLAVE_SPIKE_DISTANCE PRE_MASTER_SLAVE_SPIKE_DISTANCE EDGES_MASTER_SLAVE_SPIKE_DISTANCE EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE EDGES_PRE_PSTH EDGES_POST_PSTH BIN_SIZE_PSTH BIN_SIZE_LASER EDGES_PSTH_LASER EXCLUDE_PRE_LASER_EFFECT_DUR EXCLUDE_POST_LASER_EFFECT_DUR RAW_RANDOM_N globalX globalY globalW globalH SMALL_PLOT_FONT_SIZE PLOT_FONT_SIZE PRINT_FONT_SIZE ...
        PLOT_MATRIX_COLUMNS PLOT_MATRIX_ROWS CHANNEL_ROW_DISTANCE UNDEFINED MAX_CHANNELS NUM_OF_CHANNELS...
        COLOR_CODE_MF COLOR_CODE_SS COLOR_CODE_CS COLOR_CODE_MLI COLOR_CODE_GoC COLOR_CODE_UNKNOWN COLOR_CODE_DCN COLOR_CODES...
        GAIN_CHANGE_MOMENTS_BASELINE GAIN_CHANGE_MOMENTS_1 GAIN_CHANGE_MOMENTS_2 CLASSIC BASELINE FIRST_DRUG SECOND_DRUG ...
        COINCIDENCE_BSLN NONCOINCIDENCE_BSLN COINCIDENCE_FIRST_DRUG NONCOINCIDENCE_FIRST_DRUG COINCIDENCE_SECOND_DRUG NONCOINCIDENCE_SECOND_DRUG ...
        SOME_UNITS_OF_INTEREST MOMENT_OF_1ST_DRUG_PUT_IN MOMENT_OF_1ST_DRUG_WASH_IN MOMENT_OF_2ND_DRUG_PUT_IN MOMENT_OF_2ND_DRUG_WASH_IN SPIKE_SPAN SMOOTH_TYPE_L SMOOTH_TYPE_R...
        PAIR_TYPE_ACG PAIR_TYPE_CS_SS PAIR_TYPE_MF_SS PAIR_TYPE_MF_GO PAIR_TYPE_GO_SS PAIR_TYPE_SS_MLI PAIR_TYPE_SS_SS PAIR_TYPE_MLI_MLI PAIR_TYPE_GO_GO PAIR_TYPE_SS_DCN ...
        PAIR_TYPE_OTHER_SS PAIR_TYPE_OTHER_CS PAIR_TYPE_OTHER_MF PAIR_TYPE_OTHER_GO PAIR_TYPE_OTHER_MLI PAIR_TYPE_OTHER_OTHER...
        PAIR_TYPE_MF_OTHER...
        ACG SS_CS MF_SS MF_GO GO_SS SS_MLI SS_DCN SS_SS MLI_MLI GO_GO OTHER_SS OTHER_CS OTHER_MF OTHER_GO OTHER_MLI OTHER_OTHER...
        MF_OTHER ...
        X_MAX_ACG BIN_SIZE_ACG X_MAX_CCG X_MAX_CCG_SSCS BIN_SIZE_CCG BIN_SIZE_CCG_SSCS REFRACTORY_RANGE REFRACTORY_RANGE_MF CCG_DEVIATION_RANGE CCG_DEVIATION_CRITERION...
        MLI_SS_SUPPRESSION_RANGE MLI_MLI_SUPPRESSION_RANGE CS_SS_SUPPRESSION_RANGE MLI_SS_BASELINE_RANGE MLI_MLI_BASELINE_RANGE...
        SIZE_OF_SINGLE SIZE_OF_INT16 READ_RAW_OR_FILTERED_SIGNAL...
        NUM_OF_ROWS_IN_PROBE NUM_OF_COLUMNS_IN_PROBE DEPTH_PER_ROW ANALYSES_OUTPUT_FOLDER CHANNEL_ORGANIZATION CHANNEL_ORGANIZATION_NP_1 MAX_ARRAY_LENGTH MAX_ARRAY_LENGTH_ACG...
        FILE_NAME_WAVEFORM FILE_NAME_WAVEFORM_BASELINE FILE_NAME_WAVEFORM_FIRST_DRUG FILE_NAME_WAVEFORM_SECOND_DRUG FILE_NAME_MULTI_WAVEFORM FILE_NAME_AMPLITUDE_HEAT_MAP ...
        DEPTH_OF_CEREBELLAR_CORTEX DEPTH_OF_DCN X_MAX_CORRELOGRAM BIN_SIZE_CORRELOGRAM REFRACTORY_VIOLATION_LIMIT REFRACTORY_VIOLATION_LIMIT_MF ...
        BIN_SIZE_CONTINUITY UNIT_GROUP_GOOD UNIT_GROUP_MUA UNIT_GROUP_NOISE HARD_CUT...
        NUM_COLUMNS NUM_ROWS PAIR_SS_MLI_MAX_LAYER_DISTANCE PAIR_SS_SS_MAX_LAYER_DISTANCE PAIR_MLI_MLI_MAX_LAYER_DISTANCE PAIR_CS_SS_MAX_LAYER_DISTANCE PAIRED_SS_MLI PAIRED_CS_SS POSSIBLE_MLIs POSSIBLE_SSs IDENTIFY_MLI2_MIN_SS_DISTANCE IDENTIFY_MLI2_MAX_SS_DISTANCE...
        ROT_ENC_A_ON_TXT ROT_ENC_A_OFF_TXT ROT_ENC_B_ON_TXT ROT_ENC_B_OFF_TXT MIN_PULSE_THRESHOLD ALPHA_LIGHT...
        PRE_TIME_RAW_DATA_TRACE POST_TIME_RAW_DATA_TRACE FLAG_SAVE_FIG MIN_ISI MIN_ISI_CS REF_DURATION REF_DURATION_CS FLAG_STATIONARY_VS_RUNNING

localPath = fileparts(which(matlab.desktop.editor.getActiveFilename));
% if ispc % If the OS is Windows
%     pattern = '\';
% else
%     pattern = '/';
% end
% inds = strfind(localPath,pattern);
addpath(genpath(localPath))

MOMENT_OF_1ST_DRUG_PUT_IN = [];
MOMENT_OF_2ND_DRUG_PUT_IN = [];
MOMENT_OF_2ND_DRUG_WASH_IN = [];

DEPTH_OF_CEREBELLAR_CORTEX = -2500; %-2200;
DEPTH_OF_DCN = -3250;
X_MAX_CORRELOGRAM = 25; % ms
BIN_SIZE_CORRELOGRAM = 0.25; % ms
BIN_SIZE_CONTINUITY = 20; % sec
UNIT_GROUP_GOOD = 'good ';
UNIT_GROUP_MUA = 'mua  ';
UNIT_GROUP_NOISE = 'noise';

NUM_OF_CHANNELS = 385;
MAX_CHANNELS = 384; % 0-384 in Phyllum
NUM_COLUMNS = 2; % for NP 1.0
NUM_ROWS = 192;  % for NP 1.0
CHANNEL_ORGANIZATION_NP_1 = reshape([0:MAX_CHANNELS-1], [NUM_COLUMNS, NUM_ROWS])';

% For plotting a matrix of channels
PLOT_MATRIX_COLUMNS = 1; %2; % for NP 1.0
PLOT_MATRIX_ROWS = 1; %10;  % for NP 1.0

tipLength = 175;
HARD_CUT = Inf;

%%% DEFAULTS %%%%
PAIRED_SS_MLI = []; % Compare MF vs SS in CCG to see if any interaction
PAIRED_CS_SS = [];
FUNKY_CHANNEL = -1; %365; % Our Type 3 UHD Neuropixel probe had crazy channel no 365 (In Pyllum ordering 0-384)
POSSIBLE_MLIs = [];
POSSIBLE_SSs = [];
UNIT_OF_INTEREST = -1;
UNIT_OF_INTEREST2 = -1;
UNIT_OF_INTEREST_SLAVE = -1;
UNIT_OF_INTEREST_MASTER = -1;
UNIT_OF_INTEREST_CS = -1;
CHANNEL_ORGANIZATION = CHANNEL_ORGANIZATION_NP_1;
CLASSIC = 'Classic'; % Classic CCG captures whole duration of recording
BASELINE = 'Baseline';
FIRST_DRUG = 'GABAZINE';
SECOND_DRUG = '';
COINCIDENCE_BSLN = 'Coincidence_Bsln';
NONCOINCIDENCE_BSLN = 'NonCoincidence_Bsln';
COINCIDENCE_FIRST_DRUG = 'Coincidence_FirstDrug';
NONCOINCIDENCE_FIRST_DRUG = 'NonCoincidence_FirstDrug';
COINCIDENCE_SECOND_DRUG = 'Coincidence_SecondDrug';
NONCOINCIDENCE_SECOND_DRUG = 'NonCoincidence_SecondDrug';

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3603';
% depthDuringRecording = 2000;
% dateOfRecording = '20241108_ephaptic_3603_g0';
% % UNIT_OF_INTEREST_SLAVE = 314; 
% % UNIT_OF_INTEREST_MASTER = 312;
% SOME_UNITS_OF_INTEREST = []; %[24,29,31,25]; % 24 29, 31,25 % Dart Sorted units that look like Gr Cells % KS units DartSort compared [44, 45, 50, 23, 16, 12, 15, 20];
% MOMENT_OF_1ST_DRUG_PUT_IN = 1920; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3120; %GAIN_CHANGE_MOMENTS_1(1,3); % firstDrugWashIn
% HARD_CUT = 4320; % [0-4320] sec.
% PAIRED_SS_MLI = []; % Compare SS vs MLI in CCG to see if any interaction
% POSSIBLE_MLIs = [365];
% POSSIBLE_SSs = [321, 347, 366];
% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3603';
% depthDuringRecording = 2000;
% dateOfRecording = '20241126_ephaptic_3603_g0';
% UNIT_OF_INTEREST = -1;
% UNIT_OF_INTEREST2 = -1;
% SOME_UNITS_OF_INTEREST = []; %[24,29,31,25]; % 24 29, 31,25 % Dart Sorted units that look like Gr Cells % KS units DartSort compared [44, 45, 50, 23, 16, 12, 15, 20];
% MOMENT_OF_1ST_DRUG_PUT_IN = 1874; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3074; %GAIN_CHANGE_MOMENTS_1(1,3); % firstDrugWashIn
% HARD_CUT = 4300;
% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3601';
% depthDuringRecording = 2100;
% dateOfRecording = '20241209_ephaptic_3601_g0';
% UNIT_OF_INTEREST = -1;
% UNIT_OF_INTEREST2 = -1;
% SOME_UNITS_OF_INTEREST = []; %[24,29,31,25]; % 24 29, 31,25 % Dart Sorted units that look like Gr Cells % KS units DartSort compared [44, 45, 50, 23, 16, 12, 15, 20];
% MOMENT_OF_1ST_DRUG_PUT_IN = 1929; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3129; %GAIN_CHANGE_MOMENTS_1(1,3); % firstDrugWashIn
%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3602';
% depthDuringRecording = 2000;
% dateOfRecording = '20241210_ephaptic_3602_g0';
% UNIT_OF_INTEREST = -1;
% UNIT_OF_INTEREST2 = -1;
% SOME_UNITS_OF_INTEREST = []; %[24,29,31,25]; % 24 29, 31,25 % Dart Sorted units that look like Gr Cells % KS units DartSort compared [44, 45, 50, 23, 16, 12, 15, 20];
% MOMENT_OF_1ST_DRUG_PUT_IN = 1935; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3135; %GAIN_CHANGE_MOMENTS_1(1,3); % firstDrugWashIn
%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3601';
% depthDuringRecording = 3000;
% dateOfRecording = '20241211_ephaptic_3601_g1';
% UNIT_OF_INTEREST = -1;
% UNIT_OF_INTEREST2 = -1;
% SOME_UNITS_OF_INTEREST = [];
% MOMENT_OF_1ST_DRUG_PUT_IN = 1930; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3130; % sec
%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3605';
% depthDuringRecording = 2322;
% dateOfRecording = '20250114_ephaptic_3605_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1936; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3136; % sec

%%%%%%%%%%%%%%%%% ASTN RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '1';
% depthDuringRecording = 3000;
% dateOfRecording = '20250207_ASTN_1_g0';
% MOMENT_OF_1ST_DRUG_WASH_IN = -1;
% UNIT_OF_INTEREST_SLAVE = 338; 
% UNIT_OF_INTEREST_CS = 323;
% % UNIT_OF_INTEREST = 323;

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3606';
% depthDuringRecording = 2222;
% dateOfRecording = '20250220_ephaptic_3606_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1936; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3136; % sec
% % UNIT_OF_INTEREST_SLAVE = 307; %315; 
% % UNIT_OF_INTEREST_MASTER = 317;
% FIRST_DRUG = 'ALL-BLOCKERS';
% UNIT_OF_INTEREST_MASTERS = [317, 338, 317, 338, 317]; %, 317]; % MLIs
% UNIT_OF_INTEREST_SLAVES =  [307, 307, 315, 315, 316]; %, 307]; % SSs
% % SOME_UNITS_OF_INTEREST = [93, 315, 316, 317, 338];

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3607';
% depthDuringRecording = 3500;
% dateOfRecording = '20250225_ephaptic_3607_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1960; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3160; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3606';
% depthDuringRecording = 3300;
% dateOfRecording = '20250226_ephaptic_3606_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1925; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3125; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';
% % UNIT_OF_INTEREST = 863;
% % SOME_UNITS_OF_INTEREST = [699, 716, 736, 743, 758, 831];
% %SOME_UNITS_OF_INTEREST = [699 736 743 758 831 846 850 286 315 333 338 343 348 360 358 680 701 710 711 716 735 863 866 882 877 893];
% % [716 735 736 711 743 758 863 831]; 
% % UNIT_OF_INTEREST_MASTER = 846;
% % UNIT_OF_INTEREST_SLAVE = 866;
% % UNIT_OF_INTEREST_MASTERS = [699, 736, 736, 736, 736, 743, 743, 743, 743, 743, 743, 743, 743, 743, 758, 758, 758, 758, 770, 770, 770, 770, 770, 774, 774, 774, 780, 776, 776, 776, 820, 820, 820, 829, 829, 829, 831, 831, 831, 831, 846, 846, 846, 846, 846, 846, 846, 846, 850, 850, 850, 850];
% % UNIT_OF_INTEREST_SLAVES =  [701, 716, 735, 743, 758, 716, 735, 736, 758, 770, 701, 711, 716, 735, 735, 736, 743, 770, 743, 758, 774, 780, 776, 770, 780, 776, 770, 770, 780, 774, 829, 831, 850, 820, 831, 866, 863, 866, 820, 829, 877, 863, 866, 882, 893, 776, 831, 850, 863, 866, 820, 846];
% UNIT_OF_INTEREST_MASTERS = [699, 736, 736, 758, 750, 758, 750, 758, 829, 846, 829, 820, 831, 743, 743, 736, 743, 736, 743, 736, 743, 750, 758, 820, 831, 820, 831, 846, 831, 820, 846, 846, 846, 846];
% UNIT_OF_INTEREST_SLAVES = [701, 701, 710, 710, 711, 711, 716, 716, 862, 862, 863, 882, 882, 701, 710, 711, 711, 716, 716, 735, 735, 735, 735, 862, 862, 863, 863, 863, 866, 866, 866, 877, 882, 893];

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3608';
% depthDuringRecording = 3000;
% dateOfRecording = '202500306_ephaptic_3608_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1925; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3125; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3609';
% depthDuringRecording = 2400;
% dateOfRecording = '202500307_ephaptic_3609_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1952; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3152; % sec
% MOMENT_OF_2ND_DRUG_PUT_IN = 4440;
% MOMENT_OF_2ND_DRUG_WASH_IN = 5640;
% FIRST_DRUG = 'EXC-BLOCKERS';
% SECOND_DRUG = 'ALL-BLOCKERS';

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3606';
% depthDuringRecording = 2400;
% dateOfRecording = '202503013_ephaptic_3606_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1320; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 2520; % sec
% MOMENT_OF_2ND_DRUG_PUT_IN = 3840;
% MOMENT_OF_2ND_DRUG_WASH_IN = 5040;
% FIRST_DRUG = 'EXC-BLOCKERS';
% SECOND_DRUG = 'ALL-BLOCKERS';

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3610';
% depthDuringRecording = 2355;
% dateOfRecording = '202503014_ephaptic_3610_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1349; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 2549; % sec
% MOMENT_OF_2ND_DRUG_PUT_IN = 3868;
% MOMENT_OF_2ND_DRUG_WASH_IN = 5068;
% FIRST_DRUG = 'EXC-BLOCKERS';
% SECOND_DRUG = 'ALL-BLOCKERS';

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3610';
% depthDuringRecording = 2200;
% dateOfRecording = '20250320_ephaptic_3610_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1328; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 2528; % sec
% MOMENT_OF_2ND_DRUG_PUT_IN = 3856;
% MOMENT_OF_2ND_DRUG_WASH_IN = 5056;
% FIRST_DRUG = 'EXC-BLOCKERS';
% SECOND_DRUG = 'ALL-BLOCKERS';
% % UNIT_OF_INTEREST_SLAVE = 304;
% % UNIT_OF_INTEREST_MASTER = 298;
% % SOME_UNITS_OF_INTEREST = [213, 262, 293, 298, 285, 286, 294, 279];
% UNIT_OF_INTEREST_MASTERS = [262, 262, 293, 293, 293, 293, 232, 248];
% UNIT_OF_INTEREST_SLAVES = [265, 279, 285, 286, 294, 304, 238, 238];

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3611';
% depthDuringRecording = 2300;
% dateOfRecording = '20250612_ephaptic_3611_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 1612; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 2812; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';
% % SOME_UNITS_OF_INTEREST = [514, 515, 517, 527, 529, 555, 560];
% % UNIT_OF_INTEREST = 582;
% % UNIT_OF_INTEREST_SLAVE = 529;
% % UNIT_OF_INTEREST_MASTER = 527;
% UNIT_OF_INTEREST_MASTERS = [514, 514, 514, 527, 555];
% UNIT_OF_INTEREST_SLAVES = [515, 517, 529, 529, 529];

% % %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3613';
% depthDuringRecording = 2300;
% dateOfRecording = '20250613_ephaptic_3613_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 2100; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3300; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';
% % SOME_UNITS_OF_INTEREST = [541, 599, 538, 594, 610, 848, 849];
% UNIT_OF_INTEREST_MASTERS = [541, 541, 541, 541, 599, 599, 599, 599, 599, 599, 599, 599, 599]; % MLIs
% UNIT_OF_INTEREST_SLAVES =  [538, 848, 849, 573, 848, 573, 849, 594, 610, 615, 588, 636, 652]; % SSs

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3611';
% depthDuringRecording = 2100;
% dateOfRecording = '20250617_ephaptic_3611_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 2026; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3226; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3613';
% depthDuringRecording = 2628.6;
% dateOfRecording = '20250620_ephaptic_3613_g0_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 2083; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3283; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';
% % SOME_UNITS_OF_INTEREST = [440, 475, 515, 147, 442, 434, 441];

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
% MOUSE_ID = '3614';
% depthDuringRecording = 1500;
% dateOfRecording = '20250624_ephaptic_3614_g0';
% MOMENT_OF_1ST_DRUG_PUT_IN = 2078; % sec
% MOMENT_OF_1ST_DRUG_WASH_IN = 3278; % sec
% FIRST_DRUG = 'ALL-BLOCKERS';

% %%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%
MOUSE_ID = '3615';
depthDuringRecording = 1800;
dateOfRecording = '20250625_ephaptic_3615_g0';
MOMENT_OF_1ST_DRUG_PUT_IN = 1302; % sec
MOMENT_OF_1ST_DRUG_WASH_IN = 2502; % sec
FIRST_DRUG = 'ALL-BLOCKERS';
UNIT_OF_INTEREST_MASTERS = [108, 112]; % MLIs
UNIT_OF_INTEREST_SLAVES =  [122, 122]; % SSs

%%%%%%%%%%%%%%%%% CHANGE THESE FOR EACH RECORDING %%%%%%%%%%%%%%%%%%%%%

KS_FOLDER = 'KS_OUT/';
CatGT_FOLDER = ['CatGT_OUT/catgt_' dateOfRecording '/']; % use CatGT demuxed (tshifted) version to find spike times in raw data
ANALYSES_OUTPUT_FOLDER = 'analysis_OUT/';

globalX = 1800; % 4000
globalY = 150;
globalW = 2100; 
globalH = 2100;

SMALL_PLOT_FONT_SIZE = 10;
PLOT_FONT_SIZE = 15;
PRINT_FONT_SIZE = 30;
PLOT_FONT_SIZE = PRINT_FONT_SIZE;

SIZE_OF_SINGLE = 4; % Matlab stores single data type 4 bytes
SIZE_OF_INT16 = 2; % Matlab stores int16 data type 2 bytes

UNDEFINED = -99;

RAW_PRE_SPIKE = 0.003; % 5 ms before spike peak while reading raw data
RAW_POST_SPIKE = 0.003; % 10 ms after spike peak while reading raw data

RAW_PRE_SPIKE_WOTHERS = 0.003; % 5 ms before spike peak while reading raw data
RAW_POST_SPIKE_WOTHERS = 0.01; % 10 ms after spike peak while reading raw data

PRE_TIME_RASTER = .03; %50 ms
POST_TIME_RASTER = .03; %50 ms
RAW_RANDOM_N = 300; % 3000

MASTER_SLAVE_SPIKE_DISTANCE = .04; % (sec) search distance between master and slave spike
PRE_MASTER_SLAVE_SPIKE_DISTANCE = .04; % (sec) search distance between master and slave spike
EDGES_MASTER_SLAVE_SPIKE_DISTANCE = 0:BIN_SIZE_PSTH:MASTER_SLAVE_SPIKE_DISTANCE;
EDGES_PRE_MASTER_SLAVE_SPIKE_DISTANCE = -PRE_MASTER_SLAVE_SPIKE_DISTANCE:BIN_SIZE_PSTH:0;

% PRE_TIME_LASER = .03; %sec
% POST_TIME_LASER = .05; %sec
% BIN_SIZE_LASER = 0.0015; % 1.5 ms
% EDGES_PSTH_LASER = -PRE_TIME_LASER-BIN_SIZE_LASER:BIN_SIZE_LASER:POST_TIME_LASER+BIN_SIZE_LASER;
% EXCLUDE_POST_LASER_EFFECT_DUR = 2; % (sec.) get only the spikes 200 ms after a laser stimulation ends
% EXCLUDE_PRE_LASER_EFFECT_DUR = .02; % (sec.) get only the spikes 20 ms before a laser stimulation starts

MAX_ARRAY_LENGTH = 100000; %150000; % Since it generates this error in correlogram() : Requested 333249x333249 (827.4GB) array exceeds maximum array size preference (503.5GB). This might cause MATLAB to become unresponsive
MAX_ARRAY_LENGTH_ACG = 10000;

ROT_ENC_A_ON_TXT = 'rotEnc6_ON.txt';
ROT_ENC_A_OFF_TXT = 'rotEnc6_OFF.txt';
ROT_ENC_B_ON_TXT = 'rotEnc7_ON.txt';
ROT_ENC_B_OFF_TXT = 'rotEnc7_OFF.txt';
MIN_PULSE_THRESHOLD = 3;

BIN_SIZE_PSTH = 0.002; % sec = 2 ms
EDGES_PRE_PSTH = -PRE_TIME_RASTER-BIN_SIZE_PSTH:BIN_SIZE_PSTH:BIN_SIZE_PSTH;
EDGES_POST_PSTH = -BIN_SIZE_PSTH:BIN_SIZE_PSTH:POST_TIME_RASTER+BIN_SIZE_PSTH;

SMOOTH_TYPE_R = 'rlowess';
SMOOTH_TYPE_L = 'lowess';
SPIKE_SPAN = .3;

% contamination percent calculation from Llobet 2022
% Here, the refractory period (tr) is adjusted to take account of the data recording system s minimum possible 
% refactory period. E.g. if a system has a sampling rate of fs Hz the closest that two spikes from the same unit 
% can possibly be is 1/fs. Hence the refractory period is the expected biological threshold minus this minimum possible threshold.
MIN_ISI = 0.000033; % should be 1/fs % was 0.4 ms in Steinmetz's cortex-lab
REF_DURATION = 0.001; % 1 ms ( tc+tr in Llobet 2022 paper)
MIN_ISI_CS = 0.0015; % 1.5 ms
REF_DURATION_CS = 0.030; % 30 ms

if ispc % If the OS is Windows
    pathToParentRec = ['S:/Neuropixels/ephapticRecordings/'];
    pathToRecFolder = [pathToParentRec dateOfRecording '/'];
else
    %pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/uhd_recordings/'];
%     pathToParentRec = ['/mnt/DdriveL/sevgi/Neuropixels/ephapticRecordings/'];
    pathToParentRec = ['/mnt/IsilonPerm/Neuropixels/ephapticRecordings/'];
%     pathToParentRec = ['/mnt/DriveG/sevgi/Neuropixels/astn2Recording/'];
    
    pathToRecFolder = [pathToParentRec dateOfRecording '/'];
end
pathToUnitsDataFolder = [pathToRecFolder 'data/'];

if ~exist(pathToUnitsDataFolder)
    mkdir(pathToUnitsDataFolder);
end

if isempty(pathKS) % if it is not defined yet within one of the recordings
    pathKS = [pathToRecFolder KS_FOLDER]; % KS_OUT_stagg
end

% if isempty(pathDartSorted) % if it is not defined yet within one of the recordings
%     pathDartSorted = [pathToRecFolder DART_SORTED_FOLDER]; % KS_OUT_stagg
% end

pathTPrime = [pathToRecFolder 'TPrime_OUT/'];
pathNpyxFiltered = pathKS; %[pathToRecFolder 'NeuroPyxels_ForwardBackwardCAR/'];
pathCatGT = [pathToRecFolder CatGT_FOLDER];
%pathCatGT_loccar28 = [pathToRecFolder CatGT_FOLDER_loccar28];
% pathCatGT_filtered = [pathToRecFolder KS_FILTERED_FOLDER];

UNITS_AND_VARS_FILE_NAME_KS_SORTED = ['unitsAndVars_' dateOfRecording '.mat'];
% UNITS_AND_VARS_FILE_NAME_DART_SORTED = ['unitsAndVars_' dateOfRecording '_DartSorted.mat'];
% if DART_SORTED
%     UNITS_AND_VARS_FILE_NAME = UNITS_AND_VARS_FILE_NAME_DART_SORTED;
% else
    UNITS_AND_VARS_FILE_NAME = UNITS_AND_VARS_FILE_NAME_KS_SORTED;
% end

UNIT_CCG_PAIRS_FILE_NAME = ['unitCCGPairs_' dateOfRecording '.mat'];
UNITS_FILE_NAME = ['units_' dateOfRecording '.mat'];

pathToFigureFolder = [pathToRecFolder ANALYSES_OUTPUT_FOLDER];
if ~exist(pathToFigureFolder)
    mkdir(pathToFigureFolder);
end

pathToCurationHelperFolder = [pathToFigureFolder 'curationHelper/'];
if ~exist(pathToCurationHelperFolder)
    mkdir(pathToCurationHelperFolder);
end

pathToWaveFormWithOtherUnits = [pathToFigureFolder 'waveFormWithOtherUnits/'];
if ~exist(pathToWaveFormWithOtherUnits)
    mkdir(pathToWaveFormWithOtherUnits);
end

pathToRawVSFilteredWaveFormAlignedToLaser = [pathToFigureFolder 'rawVSFilteredWaveFormAlignedToLaser/'];
if ~exist(pathToRawVSFilteredWaveFormAlignedToLaser)
    mkdir(pathToRawVSFilteredWaveFormAlignedToLaser);
end

pathToGroupedWaveFormWithOtherUnits = [pathToFigureFolder 'groupedWaveFormWithOtherUnits/'];
if ~exist(pathToGroupedWaveFormWithOtherUnits)
    mkdir(pathToGroupedWaveFormWithOtherUnits);
end

pathToCCGs = [pathToFigureFolder 'CCGs/'];
if ~exist(pathToCCGs)
    mkdir(pathToCCGs);
end

pathToCCGWRasterPSTH = [pathToFigureFolder 'CCGwRasterPSTH/'];
if ~exist(pathToCCGWRasterPSTH)
    mkdir(pathToCCGWRasterPSTH);
end

pathToRasterPSTH = [pathToFigureFolder 'rasterPSTH/'];
if ~exist(pathToRasterPSTH)
    mkdir(pathToRasterPSTH);
end

pathToCollaboratorsFolder = [pathToFigureFolder 'toCollaborators/'];
if ~exist(pathToCollaboratorsFolder)
    mkdir(pathToCollaboratorsFolder);
end

pathToSynchronizedCCGsFolder = [pathToFigureFolder 'synchronizedCCGsFolder/'];
if ~exist(pathToSynchronizedCCGsFolder)
    mkdir(pathToSynchronizedCCGsFolder);
end

PAIR_TYPE_ACG = 0;
PAIR_TYPE_CS_SS = 1;
PAIR_TYPE_MF_SS = 2;
PAIR_TYPE_MF_GO = 3;
PAIR_TYPE_GO_SS = 4;
PAIR_TYPE_SS_MLI = 5;
PAIR_TYPE_SS_SS = 6;
PAIR_TYPE_MLI_MLI = 7;
PAIR_TYPE_GO_GO = 8;
PAIR_TYPE_SS_DCN = 9;

PAIR_TYPE_OTHER_SS = 10;
PAIR_TYPE_OTHER_CS = 11;
PAIR_TYPE_OTHER_MF = 12;
PAIR_TYPE_OTHER_GO = 13;
PAIR_TYPE_OTHER_MLI = 14;
PAIR_TYPE_OTHER_OTHER = 20;

PAIR_TYPE_MF_OTHER = 21;

PAIR_CS_SS_MAX_LAYER_DISTANCE = 1500; % (um) max layer distance between CS and SS
PAIR_SS_MLI_MAX_LAYER_DISTANCE = 300; % was 500 before, changed on 8/12/2025
PAIR_SS_SS_MAX_LAYER_DISTANCE = 500;
PAIR_MLI_MLI_MAX_LAYER_DISTANCE = 300; % was 800 before, changed on 8/12/2025
IDENTIFY_MLI2_MIN_SS_DISTANCE = 40; % (um) A criteria to distinguish MLI2s from other PC layer interneurons (i.e; Candelabrum cells) which they also do not inhibit PCs and may inhibit MLI1s so stay 40 um away from PC layer
IDENTIFY_MLI2_MAX_SS_DISTANCE = 125; % (um) Marie's criteria from paper with Wade

ALPHA_LIGHT = 0.1;

ACG = 'ACG';
SS_CS = 'SS_CS';
MF_SS = 'MF_SS';
MF_GO = 'MF_GO';
GO_SS = 'GO_SS';
SS_MLI = 'SS_MLI';
SS_DCN = 'SS_DCN';
SS_SS = 'SS_SS';
MLI_MLI = 'MLI_MLI';
GO_GO = 'GO_GO';
OTHER_SS = 'Other_SS';
OTHER_CS = 'Other_CS';
OTHER_MF = 'Other_MF';
OTHER_GO = 'Other_GO';
OTHER_MLI = 'Other_MLI';
OTHER_OTHER = 'Other_Other';
MF_OTHER = 'MF_Other';

X_MAX_ACG = 10; % ms
BIN_SIZE_ACG = 0.25; % ms
X_MAX_CCG = 20; %25; % ms
BIN_SIZE_CCG = .2; % ms Marie's bin size

X_MAX_CCG_SSCS = 50;
BIN_SIZE_CCG_SSCS = .5; % ms

REFRACTORY_RANGE = [-1 1]; % (ms)
REFRACTORY_RANGE_MF = [-0.5 .5]; % (ms)
MLI_SS_SUPPRESSION_RANGE = [0 4]; %[.5 4]; % (ms) Suppression by MLI should occur between 0.5 to 4 ms
MLI_MLI_SUPPRESSION_RANGE = [0.5 4]; % was [0 4] until 8/11/2025, changed cos 174_167 interaction selected as inhibition instead of synchronization between MLIs in 20250620 recording %[1 5]; % (ms) Suppression by MLI should occur between 0.5 to 4 ms
CS_SS_SUPPRESSION_RANGE = [0 20]; % (ms) Suppression by CS should occur between 0 to 5 ms
MLI_SS_BASELINE_RANGE = [-X_MAX_CCG -X_MAX_CCG/4];
MLI_MLI_BASELINE_RANGE = [-X_MAX_CCG -X_MAX_CCG/4];

%MLI_MLI_SYNCHRONIZATION_RANGE = [-5 5]; % (ms) Suppression by MLI should occur between 0.5 to 4 ms

REFRACTORY_VIOLATION_LIMIT = 0.5; % Changed on 8/18/2025 from 0.0665 to 0.5 together with Llobet formula; %  For all other cell types % 6 
REFRACTORY_VIOLATION_LIMIT_MF = 0.11; %  For MF % 10

CCG_DEVIATION_RANGE = 0.01;
CCG_DEVIATION_CRITERION = 8;

FILE_NAME_WAVEFORM = 'spikeWaveForm_Npyx_filtered_';
FILE_NAME_WAVEFORM_BASELINE = ['spikeWaveForm_Npyx_filtered_' BASELINE];
FILE_NAME_WAVEFORM_FIRST_DRUG = ['spikeWaveForm_Npyx_filtered_' FIRST_DRUG];
FILE_NAME_WAVEFORM_SECOND_DRUG = ['spikeWaveForm_Npyx_filtered_' SECOND_DRUG];
FILE_NAME_MULTI_WAVEFORM = 'spikeWaveFormMulti_CatGT_filtered_';
FILE_NAME_AMPLITUDE_HEAT_MAP = 'amplitudeHeatMap';

logger = log4m.getLogger([pathToFigureFolder 'neuralAnalysis.log']);
logger.setCommandWindowLevel(logger.ALL); 
logger.setLogLevel(logger.ALL);

READ_RAW_OR_FILTERED_SIGNAL = 0; % 1 Raw 0 Filtered

% NEURON_TYPE_MF = 'MF';
% NEURON_TYPE_SS = 'PC SS';
% NEURON_TYPE_CS = 'PC CS';
% NEURON_TYPE_DCS = 'PC DCS';
% NEURON_TYPE_BC_SC = 'BC or SC'; % MLI
% NEURON_TYPE_GoC = 'GoC';
% NEURON_TYPE_UBC = 'UBC';
% NEURON_TYPE_DCN = 'DCN';
% NEURON_TYPE_UNKNOWN = 'Unknown';
% 
% NEURON_TYPES = {NEURON_TYPE_MF, NEURON_TYPE_SS, NEURON_TYPE_CS, NEURON_TYPE_DCS, NEURON_TYPE_BC_SC, NEURON_TYPE_GoC, NEURON_TYPE_UBC, NEURON_TYPE_UNKNOWN};

NEURON_TYPE_MFB = 'MFB';
NEURON_TYPE_SS = 'PkC ss';
NEURON_TYPE_CS = 'PkC cs';
NEURON_TYPE_MLI = 'MLI';
NEURON_TYPE_GoC = 'GoC';
NEURON_TYPE_OTHER = ''; % Unknown
NEURON_TYPE_DCN = 'DCN';

NEURON_TYPE_MLI1 = 'MLI1';
NEURON_TYPE_MLI2 = 'MLI2';

NEURON_TYPES = {NEURON_TYPE_MFB, NEURON_TYPE_GoC, NEURON_TYPE_CS, NEURON_TYPE_MLI, NEURON_TYPE_SS, NEURON_TYPE_DCN, NEURON_TYPE_OTHER};


% COLOR_CODE_MF = [0 0 1]; % 0.7]; % Blue
% COLOR_CODE_SS = [1 0 0]; % Red
% COLOR_CODE_CS = [0 1 0]; % Green
% COLOR_CODE_DCS = [0.5 1 1]; % Cyan
% COLOR_CODE_BC_SC = [0.8500 0.3250 0.0980]; % Orange
% COLOR_CODE_GoC = [1 0 1]; % Magenta
% COLOR_CODE_UBC = [.9 .9 .9]; % Grey
% COLOR_CODE_UNKNOWN = [0 0 0]; % Black
% 
% COLOR_CODES = {COLOR_CODE_MF, COLOR_CODE_SS, COLOR_CODE_CS, COLOR_CODE_DCS, COLOR_CODE_BC_SC, COLOR_CODE_GoC, COLOR_CODE_UBC, COLOR_CODE_UNKNOWN};

COLOR_CODE_MF = [0 0 .9 0.7]; % Blue
COLOR_CODE_SS = [1 0.1 0 0.7]; % Red
COLOR_CODE_CS = [0 0 0 0.7]; % Black
COLOR_CODE_MLI = [0 .7 .3 0.7]; % Dark Green
COLOR_CODE_GoC = [1 0.1 1 0.7]; % Magenta
COLOR_CODE_UNKNOWN = [0.5 0.5 0.5 0.7]; % Grey
COLOR_CODE_DCN = [.3 .2 .5 .7];

COLOR_CODES = {COLOR_CODE_MF, COLOR_CODE_GoC, COLOR_CODE_CS, COLOR_CODE_MLI, COLOR_CODE_SS, COLOR_CODE_DCN, COLOR_CODE_UNKNOWN};

% ASTN-project-specific variables
PRE_TIME_RAW_DATA_TRACE = .1; %sec
POST_TIME_RAW_DATA_TRACE = .1; %sec

FLAG_SAVE_FIG = 1;

ANALYSIS_STEP_0 = 0; % Plot waveforms
ANALYSIS_STEP_10 = 10; % Plot waveforms with DRUG EFFECTS
ANALYSIS_STEP_1 = 1; % Plot colored spike time waveforms with other cells' spikes
ANALYSIS_STEP_11 = 11; % Plot grouped spike time waveforms with other cells' spikes
ANALYSIS_STEP_2 = 2; % Other type of CCG - Raster & PSTH wrt Master cell
ANALYSIS_STEP_21 = 21; % With and without MF of other type of CCG - Raster & PSTH wrt Master cell
ANALYSIS_STEP_22 = 22; % Regular Raster
ANALYSIS_STEP_3 = 3; % ACG
ANALYSIS_STEP_31 = 31; % Identify MLIs
ANALYSIS_STEP_4 = 4; % CCG
ANALYSIS_STEP_40 = 40; % CCG Stationary VS Running
ANALYSIS_STEP_5 = 5; % Raster & PSTH of Master-Slave cells aligned to the laser
ANALYSIS_STEP_6 = 6; % Plot raw traces aligned to the laser onset
ANALYSIS_STEP_7 = 7; % Plot raw traces aligned to the laser onset
ANALYSIS_STEP_8 = 8; % Plot amplitude distribution
ANALYSIS_STEP_9 = 9; % Plot amplitude heat maps

ANALYSIS_STEP_97 = 97; % Calculate refractoriness acc. to Llobet 2022 paper
ANALYSIS_STEP_98 = 98; % Write raw spike data into .mat for Wade
ANALYSIS_STEP_99 = 99; % Write CCG data into .mat for Wade
ANALYSIS_STEP_100 = 100; % Generate PDF report for all cells
ANALYSIS_STEP_101 = 101; % CCGs of SSs for Coincident vs non-coincident spiking MLIs

% ASTN Project specific analyses
ANALYSIS_STEP_41 = 41; % CCG (SS-CS pairs only for ASTN project)
ANALYSIS_STEP_42 = 42; % Plot raw traces aligned to the CS 
ANALYSIS_STEP_43 = 43; % Plot CV2 and FRs

% Run ANALYSIS_STEP_99 without any parameter to generate all combinations of CCGs OR SOME_UNITS_OF_INTEREST array that includes all possible MLIs and SSs that you wanna generate their CCG data
ARR_DO_ANALYSES = [40]; %[101]; % [3,31,4,97,98,99,101]; % Usual cycle should be [3, 31, 4], never run 31(identifyMLIs) before 3(ACG) cos it first needs to elimininate multi units if there's still any!
