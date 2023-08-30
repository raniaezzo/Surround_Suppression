function [mask, filterparam] = create_cosRamp(gratingtex, distance_fromRadius, rampSize, initializeMask, flag, filterparam)

    % optional argument

     if ~exist('flag','var') || isempty(flag)
          flag = 'inner2outer'; % 'reverse'
     end
     
     [~,imsize] = size(gratingtex);
     
     if ~exist('filterparam','var') || isempty(filterparam)
        filterparam = ((imsize-1) / 2) - round(distance_fromRadius);
     end

    [xN, yN] = meshgrid(-imsize/2+0.5:imsize/2-0.5, -imsize/2+0.5:imsize/2-0.5);
    [~, r] = cart2pol(xN,yN);

    if initializeMask
        mask = zeros(imsize,imsize); %
    else 
        mask = gratingtex;
    end

    inner_radius = filterparam - rampSize;
    outer_radius = filterparam;

    cosX = linspace(-pi, 0, 1001); cosY = (cos(cosX)+1)/2;
    
    aa = r - inner_radius;
    test = aa(aa < outer_radius-inner_radius);
    test = test(test > inner_radius-inner_radius);
    maxR = max(test); minR = min(test);
    
    for ii = 1:imsize
        for jj = 1:imsize
            if r(ii,jj) < inner_radius
                if initializeMask
                    mask(ii,jj) = 0; % this will make anything on the inside transparent
                else
                    mask(ii,jj) = mask(ii,jj); %%
                end
            elseif r(ii,jj) < outer_radius
                dist = r(ii,jj)-inner_radius;
                pick = (dist - minR) / (maxR - minR) *1000;
                choose = round(pick);
                if strcmp(flag, 'inner2outer') 
                    try
                        mask(ii,jj) = cosY(choose+1);
                    catch
                        mask(ii,jj) = cosY(end);
                    end
                elseif strcmp(flag, 'outer2inner')
                    mask(ii,jj) = 1-cosY(choose+1);
                end
            else
                if initializeMask
                    mask(ii,jj) = 1; %% % this will make anything on the outside opaque
                else
                    mask(ii,jj) = mask(ii,jj); %%
                end
            end
        end
    end
    
end