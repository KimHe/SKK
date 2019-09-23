function SKK


    gpEnable = true;

    % load the measurement data in [flux, reject]
    meas = load('data.dat');

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
    if exist('output.dat', 'file') ~= 2
        f1 = fopen('output.dat', 'a+');
        fprintf(f1, '#\t a\t b\t sigma\t Ps \n');
    end

    rmp = [abCoeff(1), abCoeff(2), reflectVal, permeatVal, rSqu];
    save('output.dat', 'rmp', '-ascii', '-append', '-tabs');

    gnuplot(gpEnable, abCoeff);

    fprintf('Coeff a is %4f and coeff b is %4f\n', abCoeff(1), abCoeff(2));
    fprintf('Relection coeff is %4f and permeate coeff is %4f\n', reflectVal, permeatVal);

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

        strGP = 'gnuplot -p skk.gp';
        strTeX = ' pdflatex -no-shell-escape -interaction=nonstopmode skk.tex';

        f2 = fopen('skk.gp', 'w');

        fprintf(f2, '#!/usr/bin/gnuplot -persist \n');
        fprintf(f2, 'load ''gpHeader.gp'' \n');
        fprintf(f2, '@TeX \n');
        fprintf(f2, 'set output ''skk.tex'' \n');
        fprintf(f2, 'set xlabel ''$J_v$'' \n');
        fprintf(f2, 'set ylabel ''$\\frac{R_{\\text{obs}}}{1 - R_{\\text{obs}}}$'' \n');
        fprintf(f2, 'set key nobox left \n');
        fprintf(f2, 'set grid \n');
        fprintf(f2, 'plot %4f*(1-exp(-%4f*x)) title ''sims'', ''data.dat'' using 1:2 with points title ''meas''\n', abCoeff(1), abCoeff(2));
        fprintf(f2, 'set output\n');
        fclose(f2);

        system(strGP);

    end

end
