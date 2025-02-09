


clear all

cd('C:\Documents and Settings\sima\Desktop\codeprojectPR') % set matlab path to installation path\codeprojectPR\


%% Load and preprocess data and labels. Save to .mat files


%part-1
clc
clear all
close all
load sigEEG;% loading data
 % Bandpass filter
    s(:,1) = bandpass_filter(s(:,1), [0.3 HDR.SampleRate/2]);
    s(:,2:3) = bandpass_filter(s(:,2:3), [0.3 HDR.SampleRate/2]);
    s(:,4) = bandpass_filter(s(:,4), [10 HDR.SampleRate/2]);
    
    % Downsample by 2
    s = s(1:2:end,:);
    HDR.SampleRate = HDR.SampleRate/2;
    
    % Replace NaN and Inf with 0
    s(isnan(s)) = 0;
    s(isinf(s)) = 0;
    
    % Convert to single
    s = single(s);
    %segmatation biunraul signal
BIN_pz = Akhtarimed1(:,3);
NOIES_pz= Akhtarinoise2(:,3);
rest_bin = BIN_pz(1: 48000);
stim_bin = BIN_pz(48001:168000);
stim_noise =NOIES_pz(48001:168000);
recovery_bin =BIN_pz (168001:216000);
 
% SEG_BIN
sample_rate = 1000;
sample_length = 120; % number of seconds
step = floor( sample_rate * sample_length );
[r] = size( stim_bin );
steps = floor( r / step ); 
for n = 1:steps
    seg= stim_bin( ((n-1) * step + 1 ) : ( n * step ) , : );
end
%SEG_NOIES
sample_rate = 1000;
sample_length = 120; % number of seconds
step = floor( sample_rate * sample_length );
[r] = size(  stim_noise);
steps = floor( r / step ); 
for n = 1:steps
    segN= stim_noise( ((n-1) * step + 1 ) : ( n * step ) , : );
end

% part-2

% spectrogram of channel pz
[S10,F,T] = spectrogram(data(:,10),chebwin(128,100),0,Fs);
S10=abs(S10);
h7=figure;
mesh(T,F,S10);
xlabel('Time (sec)','FontSize',14);
ylabel('Frequency (Hz)','FontSize',14);
zlabel('S10','FontSize',14);
h8=figure;
contour(T,F,S10);
xlabel('Time (sec)');
ylabel('Frequency (Hz)');
% % % title('channel PZ');

%part 3
%feature extraction 1
%load filtr

Hd1 = alfa;
Hd2 = beta;
Hd3 = teta;
Hd4= delta;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%                           feature extraction                          %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%feature extraction 2

% feature extraction of signal binural
for i=1:120
    DATA1=filter(Hd1.sosMatrix,data_bi(i,:));
    alfaFea(i) = DATA1*out'/1000;
    
    DATA2=filter(Hd2.sosMatrix,data_bi(i,:));
    betaFea(i)= DATA2*DATA2'/1000;
    
    DATA3=filter(Hd3.sosMatrix,data_bi(i,:));
    tetaFea(i)= DATA3*DATA3'/1000;
    
    DATA4=filter(Hd4.sosMatrix,data_bi(i,:));
    deltaFea(i)= DATA4*DATA4'/1000;
    
    %feature extraction time & statistics
   
    DATAmean(i)= mean(seg(i,:));
    DATAvar(i)= var(seg(i,:));
    DATAskew(i) = skewness(seg(i,:));
    DATAkur(i)= kurtosis(seg(i,:));
    
end  
 var_bin= [DATA1',DATA2',DATA3',DATA4',DATAmean',DATAvar'...
    ,DATAskew',DATAkur'];
% feature extraction  of signal noies
    for i=1:120
    DATA1=filter(Hd1.sosMatrix,data_noies(i,:));
    alfaFEA(i) = out*out'/1000;
    
    DATA2=filter(Hd2.sosMatrix,data_noies(i,:));
    betaFEA(i)= out*out'/1000;
    
    DATA3=filter(Hd3.sosMatrix,data_noies(i,:));
    tetaFEA(i)= out*out'/1000;
    
    DATA4=filter(Hd4.sosMatrix,data_noies(i,:));
        deltaFEA(i)= out*out'/1000;
    
    %feature extraction time & statistics of signal noise
   
    DATAmean(i)= mean(segN(i,:));
    DATAvar(i)= var(segN(i,:));
    DATAskew= skewness(segN(i,:));
    DATAkur= kurtosis(segN(i,:));
    end  
    
 var_noise= [DATA1',DATA2',DATA3',DATA4',DATAmean',DATAvar'...
    ,DATAskew',DATAkur'];

    %feature extraction power reltive
    
    
for i=1:120
   var_bin(i,1:6)=var_bin(i,1:6)/sum(var_bin(i,1:6));
    var_noise(i,1:6)=v_no(i,1:6)/sum(var_no(i,1:6));
end
    
var_fin= [var_bi;var_no];
Lab1 = ones(120+120,1);
Label(121:end) = 2;
%isolate data
TRAIN = DATA(1:200,:);
lab_train = Label(1:200);
TEST = DATA(200:end,:);
lab_test = Label(240:end);


%NORMALIZE_SIGNS - normalization algorithm for HMM
 hmm_normalize_signs(signs, normalize_level_coef, max_values, min_values)

%  hmm_normalize_signs(signs, normalize_level_coef, max_values, min_values),


% inicialize
[number_signs, number_segments] = size(signs);
if (length(max_values) == 0),
    max_values = max(signs);
end;
if (length(min_values) == 0),
    min_values = min(signs);
end;

% find max value
signs = signs - repmat(min_values(:), 1, number_segments);
signs = signs ./ repmat(max_values(:) - min_values(:), 1, number_segments);
signs = signs .* (normalize_level_coef - 1);
signs = floor(signs) + 1;

% cutting (prevence only)
for (i = 1 : number_signs),
    [u, v] = find(signs(i, :) > normalize_level_coef);
    signs(i, v) = normalize_level_coef;
    [u, v] = find(signs(i, :) < 1);
    signs(i, v) = 1;
end;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%                         CLASSIFIER USING HMM                          %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%% modeling hmm
%  hmm_model(signs_trained, expert_matrix_trained, signs_test)


% inicialize
number_state = max(expert_matrix_trained);

%  transition and emission matrices
max_value = max(lab_train);
seq = lab_train./max_value;
seq = 1 + floor(seq * 99);
[transition_matrix, emission_matrix] = hmmestimate(seq, expert_matrix_trained);

% zero's
for (i = 1 : number_state),
    [u, v] = find(emission_matrix(i, :) == 0);
    emission_matrix(i, v) = 0.0001;
    emission_matrix(i, :) = emission_matrix(i, :)./sum(emission_matrix(i, :));
end;

% quantization
seq = lab_test./max_value;
[u, v] = find(seq > 1); seq(v) = 1;
[u, v] = find(seq < 0); seq(v) = 0;
seq = 1 + floor(seq * 99);

% viterbi algorithm
expert_matrix_markov =  hmmviterbi(seq, transition_matrix, emission_matrix);


%HMM_MODEL - file for hmm_em_algorithm.m
%
%  hmm_model(X,model),


[dim, num_data] = size(X);

p = repmat(model.Py(:),1,num_data);

for i=1:dim,
  p = p.*model.Pxcy{i}(X(i,:),:)';
end

p = sum(p,1);

return;


%%train hmm
 hmm_em_algorithm(lab_train, expert_matrix_trained, em_maxy),
%HMM_EM_ALGORITHM - EM algorithm
%
%  hmm_em_algorithm(signs_trained, expert_matrix_trained, em_maxy),


% inicialize
number_state = max(lab_train);
[number_signs, number_segments_trained] = size(lab_train);

fprintf(['[hmm_em_algorithm]: model creating.. ']);

% divide signal by states
                       [u, v1] = find(lab_train == 1);
                       [u, v2] = find(lab_train == 2);
if (number_state > 2), [u, v3] = find(lab_train== 3); end;
if (number_state > 3), [u, v4] = find(lab_train == 4); end;
if (number_state > 4), [u, v5] = find(lab_train == 5); end;
if (number_state > 5), [u, v6] = find(lab_train == 6); end;

% EM algorithm
model_3 = []; model_4 = []; model_5 = []; model_6 = []; 
options.maxx = max(max(lab_train));
options.maxy = em_maxy;
options.tmax = 100;
options.verb = 0;
options.eps_alpha = 0.001;
options.eps_logL = 0.001;
                       model_1 = hmm_em(lab_train(:, v1), options);
                       model_2 = hmm_em(lab_train(:, v2), options);
if (number_state > 2), model_3 = hmm_em(lab_train(:, v3), options); end;
if (number_state > 3), model_4 = hmm_em(lab_train(:, v4), options); end;
if (number_state > 4), model_5 = hmm_em(lab_train(:, v5), options); end;
if (number_state > 5), model_6 = hmm_em(lab_train(:, v6), options); end;

fprintf(['ok\n']);

 hmm_em(X, options)
%hmm_em - EM algorithm for conditionally independent model
%
% hmm_em(X, options)
%
% options: input parameters definition


% inicialize
[dim,num_data] = size(X);
if nargin < 2, options = []; end
if ~isfield(options,'maxy'), options.maxy = 2; end
if ~isfield(options,'maxx'), options.maxx = maxx; end
if ~isfield(options,'tmax'), options.tmax = inf; end
if ~isfield(options,'eps_logL'), options.eps_logL = 0; end
if ~isfield(options,'eps_alpha'), options.eps_alpha = 0; end
if ~isfield(options,'verb'), options.verb = 0; end

% Initial model
for i=1:dim,
  Pxcy{i} = rand(options.maxx,options.maxy);
  Pxcy{i} = Pxcy{i}./(ones(options.maxx,1)*sum(Pxcy{i},1));
end

Py = rand(options.maxy,1);
Py = Py/sum(Py);
Alpha = inf*ones(options.maxy,num_data);
logL = -inf;

exitflag = 0; t = 0;
while exitflag == 0 && t < options.tmax,
  t = t + 1;
  
  % E-step
  alpha-new = repmat(Py(:),1,num_data);
  for i=1:dim,
    alpha-new = alpha-new.*Pxcy{i}(X(i,:),:)';
  end
  newLogL = sum(log(sum(alpha-new,1)));
  alpha-new = alpha-new./(ones(options.maxy,1)*sum(alpha-new,1));

  % updates
  delta_alpha = sum(sum((Alpha-alpha-new).^2));
  delta_logL = newLogL - logL(end);
  logL = [logL newLogL];
  Alpha = alpha-new;
  
  if options.verb,
    fprintf('%d: logL=%f, delta_logL=%f, delta_alpha=%f\n', ...
      t, logL(end), delta_logL, delta_alpha);
  end
  
  % Stopping conditions  
  if delta_alpha <= options.eps_alpha, exitflag = 2; continue; end
  if delta_logL <= options.eps_logL, exitflag = 1; continue; end
  
  % M-step
  for i=1:dim,
    for x=1:options.maxx,
      inx = find(X(i,:)==x);
      if length(inx) > 0,
         Pxcy{i}(x,:) = sum(Alpha(:,inx),2)';
      else
        Pxcy{i}(x,:) = zeros(1,options.maxy);
      end
    end
    Pxcy{i} = Pxcy{i}./(ones(options.maxx,1)*sum(Pxcy{i},1));
  end
  
  Py = sum(Alpha,2);
  Py = Py/sum(Py);
  
end

model.Pxcy = Pxcy;
model.Py = Py;
model.t = t;
model.logL = logL;
model.exitflag = exitflag;
model.fun = 'pdfcim';

return;
%EOF
  hmm_emission_probability(lab_test, model_1, model_2, model_3, model_4, model_5, model_6),
%HMM_EMMISION_PROBABILITY - emission probability computing
%
%  hmm_emission_probability(signs_tested, model_1, model_2, model_3, model_4, model_5, model_6),
%

%% inicialize
[1, 200] = size(signs_tested);

%% compute individual probabilities
fprintf(['[hmm_emission_probability]: emission probability computing.. ']);
p1 = []; p2 = []; p3 = []; p4 = []; p5 = []; p6 = [];
if (length(model_1) ~= 0)  p1 = hmm_model(lab_test, model_1); end;
if (length(model_2) ~= 0)  p2 = hmm_model(lab_test, model_2); end;
if (length(model_3) ~= 0), p3 = hmm_model(lab_test, model_3); end;
if (length(model_4) ~= 0), p4 = hmm_model(lab_test, model_4); end;
if (length(model_5) ~= 0), p5 = hmm_model(lab_test, model_5); end;
if (length(model_6) ~= 0), p6 = hmm_model(lab_test, model_6); end;

emission_matrix = [p1; p2; p3; p4; p5; p6];

% % find zero's
% for (i = 1 : size(emission_matrix, 1)),
%     [u, v] = find(emission_matrix(i, :) == 0);
%     emission_matrix(i, v) = 1e-50;
%     emission_matrix(i, :) = emission_matrix(i, :)./sum(emission_matrix(i,:)); % normalize
% end;

fprintf(['ok\n']);
 hmm_viterbi_algorithm(prior_state, transition_matrix, emission_matrix)
%HMM_VITERBI_ALGORITHM - viterbi algorithm for HMM
%
%  hmm_viterbi_algorithm(prior_state, transition_matrix, emission_matrix)


% inicialize
[number_state, number_y] = size(emission_matrix);
probably_matrix = zeros(number_state, number_y);
path_matrix = zeros(number_state, number_y);
expert_matrix = zeros(1, number_y);

% use prior
probably_matrix(:, 1) = prior_state(:).*emission_matrix(:, 1);

% build graph
fprintf(['[hmm_viterbi_algorithm]: graph building.. ']);
for (m = 2 : number_y),
    for (n = 1 : number_state),
        [u, v] = max(probably_matrix(:, m - 1) + transition_matrix(:, n) .* emission_matrix(n, m));
        probably_matrix(n, m) = u;
        path_matrix(n, m) = v;
    end;
end;
fprintf(['ok\n']);

% find best path through graph
fprintf(['[hmm_viterbi_algorithm]: best path through graph finding.. ']);
[u, v] = max(probably_matrix(:, number_y));
expert_matrix(number_y) = v;
for (i = 1 : number_y - 1),
    v = path_matrix(v, number_y - i + 1);
    expert_matrix(number_y - i) = v;
end;
fprintf(['ok\n']);

if nargin==2
    verbose=true;
end
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%                                                                       %
%                            RESULAT                                    %
%                                                                       %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

est = lab_test(est(:));
true = lab_train(true(:));
acc=sum(est==true)/rows(true);
[cfmat,btemp] =dismat(true,est);

    disp([btemp diag(dismat)./sum(dismat,2)];
    disp('Accuracy of classifier binaural EEG signal from noise is:');
     disp(acc);

    
end