function mask = create_cosRamp(gratingtex, distance_fromRadius, rampSize)

    [~,imsize] = size(gratingtex);
    
    filterparam = ((imsize-1) / 2) - round(distance_fromRadius);
    
    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    if round(distance_fromRadius) == 0
        mask = zeros(imsize,imsize); %
    else 
        mask = gratingtex;
    end

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
            else
                if round(distance_fromRadius) == 0
                    mask(ii,jj) = 1; %%
                else
                    mask(ii,jj) = mask(ii,jj); %%
                end
            end
        end
    end
    
    if round(distance_fromRadius) ~= 0 % changed (reversed)
        mask = 1-mask; %%
    end
    
end