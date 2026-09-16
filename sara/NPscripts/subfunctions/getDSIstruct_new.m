% Input is avg_resp_dir, nCells x nDir x nMaskPhase x (1: grating, 2:
% plaid) x (1: mean resp, 2: std)

function [DSIstruct] = getDSIstruct_new(avg_resp_dir)
    
    nCells  = size(avg_resp_dir,1);
    nDir    = size(avg_resp_dir,2);

    angs = 0:30:330;

    for iCell = 1:nCells
        % Pref null DSI
            resp = squeeze(avg_resp_dir(iCell,:,1,1,1));
            [minVal, ~] = min(resp);
            if minVal < 0
                resp_Norm = resp-minVal;
            else
                resp_Norm = resp;
            end

            resp_Old = resp;
            resp_Old(resp_Old < 0) = 0;


            [max_val, max_ind] = max(resp_Norm);
            null_ind            = max_ind+(nDir./2);
    
            if null_ind > nDir
                null_ind = null_ind - nDir;
            end
    
            min_val     = resp_Norm(null_ind);
            DSI(iCell)          = (max_val-min_val)./(max_val+min_val);
            DSI_maxInd(iCell)   = max_ind; 

            gratResp(iCell,:)       = resp;
            gratResp_old(iCell,:)   = resp_Old;
            gratResp_norm(iCell,:)  = resp_Norm;

        % Global DSI & Global OSI
            resp = resp_Norm;
            
            g_dsi(iCell) = sqrt(sum(sin(1*angs*pi/180).*resp).^2 + sum(cos(1*angs*pi/180).*resp).^2)/sum(resp);
            g_osi(iCell) = sqrt(sum(sin(2*angs*pi/180).*resp).^2 + sum(cos(2*angs*pi/180).*resp).^2)/sum(resp);
            
            xm_dsi = (sum(resp.*cos(deg2rad(1*angs)))/sum(resp)); %mean of the response, x
            ym_dsi = (sum(resp.*sin(deg2rad(1*angs)))/sum(resp)); %mean of the response, y
            xm_osi = (sum(resp.*cos(deg2rad(2*angs)))/sum(resp));
            ym_osi = (sum(resp.*sin(deg2rad(2*angs)))/sum(resp));
            
            ang_dsi(iCell) = mod(rad2deg(atan2(ym_dsi, xm_dsi)), 360); %preferred direction, in degrees
            ang_osi(iCell) = mod(rad2deg(atan2(ym_osi, xm_osi))/2, 180);
            ang_osi(iCell) = ang_osi(iCell)/2;

    end

    DSIstruct.DSI           = DSI;  % DSI value, ranging 0 to 1
    DSIstruct.DS_ind        = find(DSI>0.5);    % index of cells meeting criteria DSI>0.5
    DSIstruct.prefDir       = DSI_maxInd;   % index of preferred direction, ranging 1 through nDir
    DSIstruct.gDSI          = g_dsi;    %global DSI value, from 0 to 1
    DSIstruct.gDSI_prefDir  = ang_dsi;  %preferred direction, calculated from gDSI
    DSIstruct.gOSI          = g_osi;    %global DSI value, from 0 to 1
    DSIstruct.gOSI_prefDir  = ang_osi;  %preferred direction, calculated from gDSI

    DSIstruct.resp           = gratResp; 
    DSIstruct.respOld        = gratResp_old; 
    DSIstruct.respNorm       = gratResp_norm; 

end