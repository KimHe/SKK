function predict

    % R/(1-R) = a ( 1- exp(-b Jv))
    a = ;
    b = ;

    flux = load('fluxPred.dat');

    for i = 1:length(flux)
        rejectDim(i) = a * ( 1- exp( -b * flux(i)));
        reject(i) = rejectDim(i) / ( 1 + rejectDim(i) );
    end

    fprintf('The value of rejection rate is %4f \n', reject);
    save('reject.dat', 'reject', '-ascii', '-append', '-tabs', '-double');
    
end
