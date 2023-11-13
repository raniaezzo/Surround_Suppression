function quickplot(const, expDes)

    % create figure of peformance
    
    surroundLevels = sort(unique(expDes.trialMat(:,4)));
    colorLevels = 1-linspace(0.5, 1, length(surroundLevels));
    legend_entries = []; legend_names = {};
    
    f1 = figure;
            
    for sl=1:length(surroundLevels)
        
        % pull out matrix for this surround level
        currSurrLevel = surroundLevels(sl);
        currIdx = expDes.trialMat(:,4)==currSurrLevel;
        trialMat_currSurr = expDes.trialMat(currIdx,:);
        respMat_currSurr = expDes.response(currIdx, :);
        
        levels = unique(trialMat_currSurr(:,2)); % unique target contrasts
        level_n = expDes.nb_repeat*numel(expDes.locations);
        meanRsp = nan(numel(levels),1);
        trialRsp = nan(level_n, numel(levels));

        for li=1:numel(levels)
            idx = trialMat_currSurr(:,2)==levels(li);
            meanRsp(li) = mean(respMat_currSurr(idx));
            trialRsp(:,li) = respMat_currSurr(idx);
        end

        % plot SEM
        sem = std(trialRsp)/sqrt(level_n);

        pl = plot(levels, meanRsp, 'o-', 'Color', repmat(colorLevels(sl),1,3), 'Linewidth', 1.5);
        pl.MarkerSize = 8; pl.MarkerFaceColor = repmat(colorLevels(sl),1,3); pl.MarkerEdgeColor = 'w';
        hold on
        errorbar(levels, meanRsp, sem, 'Color', repmat(colorLevels(sl),1,3), 'Linewidth', 1.5);
        hold on
        ident = refline([1 0]);
        ident.Color = 'r'; ident.LineStyle = '--'; ident.LineWidth = 1.5;
        ylabel('Perceived contrast')
        xlabel('Target contrast')
        ax = gca;
        ax.FontSize = 16;
        xlim([0 1]);
        ylim([0 1]);
        axis square
        titlestr = [const.subjID ' ' expDes.stimulus];
        title(titlestr)
        txt = [num2str(level_n) ' trials per point'];
        text(.6, 0.1, txt) 
        hold on
        legend_entries = [legend_entries, pl];
        legend_names{sl} = sprintf('surround%.2f', surroundLevels(sl));
    end
    
    legend(legend_entries, legend_names)
    filename = strcat(strrep(titlestr, ' ', '_'), '.pdf');
    saveas(gcf, fullfile(const.blockDir, filename));
    
end