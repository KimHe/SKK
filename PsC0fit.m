function PsC0fit


    gpEnable = true;

    fileName = uigetfile('*.dat');

    [~, folderName] = fileparts(fileName);

    mkdir(folderName);

    % load the measurement data in [Vol flowrate, reject]
    meas = load(fileName);

    cd(folderName);

    % specify an initial point
    x0 = [0.5, 0.1];

    % invoke minimization function
    % abCoeff is the vector of [a, b]
    [abCoeff, ~, exitflag] = fminsearch( @(coeff) LSR(coeff, meas), x0,...
        optimset('Display', 'iter', 'TolX', 1e-6) );

    if exitflag == 0
        warning('PCfit: Maximum number of function has been reached');
    end

    % store the parameters
    if exist('pcFit.dat', 'file') ~= 2
        f1 = fopen('pcFit.dat', 'a+');
        fprintf(f1, '#\t\t a\t\t\t\t b\t\t\t\t\t  R-square \n');
    end

    rSqu = rSquare(meas, abCoeff);

    rmp = [abCoeff(1), abCoeff(2), rSqu];
    save('pcFit.dat', 'rmp', '-ascii', '-append', '-tabs');

    gnuplot(gpEnable, abCoeff);

    fprintf('Coeff a is %4f and coeff b is %4f\n', abCoeff(1), abCoeff(2));

    cd('..');

end

function lss = LSR(coeff, meas)


    res = zeros(1, length(meas));

    for i = 1:length(meas)
        res(i) = meas(i, 2) - coeff(1) * (1 - exp( - coeff(2) * meas(i, 1)));
    end

    lss = res * res';

end

function rSqu = rSquare(meas, coeff)


    res = zeros(1, length(meas));
    rst = zeros(1, length(meas));

    for i = 1:length(meas)
        res(i) = meas(i, 2) - coeff(1) * (1 - exp( -coeff(2) * meas(i, 1)));
        rst(i) = meas(i, 2) - mean(meas(:,2));
    end

    SSR = res * res';
    SST = rst * rst';

    rSqu = 1 - SSR / SST;

end

function gnuplot(gpEnable, abCoeff)


    if gpEnable

        strGP = 'gnuplot -p pcFit.gp';
        strTeX = ' pdflatex -no-shell-escape -interaction=nonstopmode pcFit.tex';

        f2 = fopen('pcFit.gp', 'w');

        fprintf(f2, '#!/usr/bin/gnuplot -persist \n');
        fprintf(f2, 'load ''../gpHeader.gp'' \n');
        fprintf(f2, '@TeX \n');
        fprintf(f2, 'set output ''pcFit.tex'' \n');
        fprintf(f2, 'set xlabel ''$c_0 [\\si{\\gram\\per\\liter}]$'' \n');
        fprintf(f2, 'set ylabel ''$P_s$'' \n');
        fprintf(f2, 'set key nobox left \n');
        fprintf(f2, 'set grid \n');
        fprintf(f2, 'plot %4f*(1-exp(-%4f*x)) title ''sims'', ''../params.dat'' using 1:2 with points pt 12 title ''meas''\n', ...
            abCoeff(1), abCoeff(2));
        fprintf(f2, 'set output\n');
        fclose(f2);

        system(strGP);

    end

end
