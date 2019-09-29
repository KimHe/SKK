function SKK


    gpEnable = true;

    repeatRun = 'Yes';

    while strcmp(repeatRun, 'Yes') == 1

        [fileName, pathName] = uigetfile('*.dat');

        [~, folderName] = fileparts(fileName);

        mkdir(folderName);

        % load the measurement data in [Vol flowrate, reject]
        meas = load(fileName);

        cd(folderName);

        meas = preProcess(meas);

        % specify an initial point
        x0 = [20, 1];

        % invoke minimization function
        % abCoeff is the vector of [a, b]
        [abCoeff, ~, exitflag] = fminsearch( @(coeff) LSR(coeff, meas), x0,...
            optimset('Display', 'iter', 'TolX', 1e-6));

        if exitflag == 0
            warning('SKK: Maximum number of function has been reached');
        end

        % calculate the reflect and permeate coefficients
        reflectVal = abCoeff(1) / (1 + abCoeff(1));
        permeatVal = (1 - reflectVal) / abCoeff(2);

        rSqu = rSquare(meas, abCoeff);

        % store the parameters
        if exist('params.dat', 'file') ~= 2
            f1 = fopen('params.dat', 'a+');
            fprintf(f1, '#\t\t a\t\t\t\t b\t\t\t\t\t sigma \t\t\t Ps [L/m^2/h] \t\t\t R-square \n');
        end

        rmp = [abCoeff(1), abCoeff(2), reflectVal, permeatVal, rSqu];
        save('params.dat', 'rmp', '-ascii', '-append', '-tabs');

        gnuplot(gpEnable, abCoeff);

        fprintf('Coeff a is %4f and coeff b is %4f\n', abCoeff(1), abCoeff(2));
        fprintf('Relection coeff is %4f and permeate coeff is %4f\n', reflectVal, permeatVal);

        %str = sprintf('cp ../Makefile .');
        system('cp ../Makefile .');

        cd('..');

        repeatRun = questdlg('Do you want to run repeatedly?', 'Log', 'Yes', 'No', 'Yes');

    end

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

function tmp = preProcess(meas)

    crosArea = 0.38; % m^2
    tmp = zeros(length(meas), 2);
    tmp(:, 2) = meas(:,2) ./ ( ones(length(meas), 1) - meas(:,2) );
    tmp(:, 1) = meas(:,1) .* 60 ./ 1e3 ./ crosArea; % mL/s --> [L/m^2/h]

    f = fopen('JR.dat', 'w');
    fprintf(f, '#\t\t Jv [L/m^2/h] \t\t\t R/(1-R) \n');
    fclose(f);
    save('JR.dat', 'tmp', '-ascii', '-append', '-tabs', '-double');

end

function gnuplot(gpEnable, abCoeff)


    if gpEnable

        strGP = 'gnuplot -p skk.gp';
        strTeX = 'pdflatex skk.tex';

        f2 = fopen('skk.gp', 'w');

        fprintf(f2, '#!/usr/bin/gnuplot -persist \n');
        fprintf(f2, 'load ''../gpHeader.gp'' \n');
        fprintf(f2, '@TeX \n');
        fprintf(f2, 'set output ''skk.tex'' \n');
        fprintf(f2, 'set xlabel ''$J_v [\\si{\\liter\\per\\square\\metre\\per\\hour}]$'' \n');
        fprintf(f2, 'set ylabel ''$\\frac{R_{\\text{obs}}}{1 - R_{\\text{obs}}}$'' \n');
        fprintf(f2, 'set key nobox left \n');
        fprintf(f2, 'set grid \n');
        fprintf(f2, 'plot %4f*(1-exp(-%4f*x)) title ''sims'', ''JR.dat'' using 1:2 with points pt 12 title ''meas''\n', ...
            abCoeff(1), abCoeff(2));
        fprintf(f2, 'set output\n');
        fclose(f2);

        system(strGP);

    end

end
