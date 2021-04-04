function balayage(parametreChoisi)
    % Simulations
    % reference: mathworks.com/help/simulink/ug/optimize-estimate-and-sweep-block-parameter-values.html
    
    % Dictionnaire clé-valeur des valeurs à balayer
    % (nom_parametre, [valeurs à simuler])
    %
    % Note: f_echant doit être un diviseur de 500 * 22 Hz
    parametres = containers.Map( ...
        ["dac_commande_resolution", "adc_entrees_resolution", "f_echant", "N_bobine", "B_bobine"], ...
        {   
            [4, 8, 10, 12, 16], ...
            [8, 10, 12, 14], ...
            [11, 22, 44, 88], ...
            [1, 10, 66, 100, 200], ...
            [0.02, 0.05, 0.1128, 0.2], ...
        } ...
    );

    valeursParametre = parametres(parametreChoisi);
    for i = 1:length(valeursParametre)
        entreeSimulation(i) = Simulink.SimulationInput("main");
        entreeSimulation(i) = setVariable(entreeSimulation(i), parametreChoisi, valeursParametre(i), "Workspace", "main");
    end

    sortiesSimulations = sim(entreeSimulation);

    % Affichage
    justesses = [];
    T_stabilisations = [];
    precisions = [];
    for i = 1:length(valeursParametre)
        justesses(i) = sortiesSimulations(i).justesse;
        T_stabilisations(i) = sortiesSimulations(i).T_stabilisation;
        precisions(i) = sortiesSimulations(i).precision;
    end
    subplot(3,1,1);
    plot(valeursParametre, justesses, "o-");
    title("Justesse en fonction de " + parametreChoisi, "Interpreter", "none");
    xlabel(parametreChoisi, "Interpreter", "none");
    ylabel("Justesse", "Interpreter", "none");

    subplot(3,1,2);
    plot(valeursParametre, T_stabilisations, "o-");
    title("Temps de stabilisation en fonction de " + parametreChoisi, "Interpreter", "none");
    xlabel(parametreChoisi, "Interpreter", "none");
    ylabel("Temps de stabilisation [s]", "Interpreter", "none");

    subplot(3,1,3);
    plot(valeursParametre, precisions, "o-");
    title("Précision en fonction de " + parametreChoisi, "Interpreter", "none");
    xlabel(parametreChoisi, "Interpreter", "none");
    ylabel("Précision [g]", "Interpreter", "none");

end
