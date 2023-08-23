function mask = create_cosRamp2(gratingtex, surroundmask, surroundGap, rampSize)

    [~,imsize] = size(gratingtex);
    
    filterparam_outer = (imsize-1) / 2;
    filterparam_inner = filterparam_outer-round(surroundGap);
    

    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    mask = surroundmask; %zeros(imsize,imsize);

    inner_radius = filterparam_inner - rampSize;
    outer_radius = filterparam_inner;

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
                mask(ii,jj) = mask(ii,jj); %1;
            end
        end
    end
    
end