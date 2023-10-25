function my_letter_detection_task(scr, const, color, trialLetterString)

x_mid = scr.windCenter_px(1);
y_mid = scr.windCenter_px(2);
text = cellstr(trialLetterString);

Screen('Preference', 'TextAntiAliasing',1);
Screen('TextSize',const.window, const.text_size);
Screen ('TextFont', const.window, const.text_font);

bound = Screen('TextBounds',const.window,text{1,:});

Screen('DrawText',const.window,text{1,:},x_mid-bound(3)/2,y_mid, color);
