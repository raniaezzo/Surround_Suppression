function mask = create_cosRamp(gratingtex, rampSize)

%     gratingtex = surroundmask;
%     const.stimCosEdge_deg = 1; %1.5;
%     const.stimCosEdge_pix = vaDeg2pix(const.stimCosEdge_deg, scr);
% 
%     rampSize = const.stimCosEdge_pix;

    [~,imsize] = size(gratingtex);
    
    filterparam = (imsize-1) / 2; %filterparam = stimSize;     %imsize = filterparam*2+1;
%     filterparam = round(const.surround2GapRadiusPix);
    

    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    mask = zeros(imsize,imsize);

    inner_radius = filterparam - rampSize;
    outer_radius = filterparam;

    cosX = linspace(-pi, 0, 1001);
    cosY = (cos(cosX)+1)/2;
    aa = r - inner_radius;
    test = aa(aa < outer_radius-inner_radius);
    test = test(test > inner_radius-inner_radius);
    maxR = max(test); minR = min(test);

    for ii = 1:imsize
        for jj = 1:imsize
            if r(ii,jj) < inner_radius
                mask(ii,jj) = 0;
            elseif r(ii,jj) < outer_radius
                dist = r(ii,jj)-inner_radius;
                pick = (dist - minR) / (maxR - minR) *1000;
                choose = round(pick);
                mask(ii,jj) = cosY(choose+1);
                %alpha(ii,jj) = (1-cosd(r(ii,jj)-inner_radius))/2;
            else
                mask(ii,jj) = 1;
            end
        end
    end
    
    mask = 1-mask;
    
end