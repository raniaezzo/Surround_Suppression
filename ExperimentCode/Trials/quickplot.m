function quickplot(const, expDes)

    % create figure of peformance

    levels = unique(expDes.trialMat(:,2));
    level_n = expDes.nb_repeat*numel(expDes.locations);
    meanRsp = nan(numel(levels),1);
    trialRsp = nan(level_n, numel(levels));

    for li=1:numel(levels)
        idx = expDes.trialMat(:,2)==levels(li);
        meanRsp(li) = mean(expDes.response(idx));
        trialRsp(:,li) = expDes.response(idx);
    end

    % plot SEM
    sem = std(trialRsp)/sqrt(level_n);

    f1 = figure;
    pl = plot(levels, meanRsp, 'o-k', 'Linewidth', 1.5);
    pl.MarkerSize = 8; pl.MarkerFaceColor = 'k'; pl.MarkerEdgeColor = 'w';
    hold on
    errorbar(levels, meanRsp, sem, 'k', 'Linewidth', 1.5);
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
    txt = [num2str(level_n) ' trials per contrast'];
    text(.6, 0.1, txt) 
    
    filename = strcat(strrep(titlestr, ' ', '_'), '.pdf');
    saveas(gcf, fullfile(const.blockDir, filename));
    
end