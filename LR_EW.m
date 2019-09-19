%% Loading data
% SST anomalies
sst_anom=NaN(360,180,828);
for i=1950:2018
    data_here=['sst_anom_' num2str(i)];
    load(data_here);
    sst_anom(:,:,(1:12)+(i-1950)*12)=sst_here;
end

dif_sst=cat(3,diff(sst_anom(:,:,1:2),1,3),diff(sst_anom,1,3));
dif_used=dif_sst(:,:,85:816);

sst_anom=sst_anom(:,:,85:816);

% Extreme Warming index
ew_index=NaN(360,180,828);
for i=1950:2018
    data_here=['ew_' num2str(i)];
    load(data_here);
    ew_index(:,:,(1:12)+(i-1950)*12)=ew_here;
end
ew_index=ew_index(:,:,85:816);


% Climate Modes
load('pdo_line');%1950 - 2017
pdo_line=pdo_line(85:end,:);
load('sam_line');%1957 - 2018
sam_line=sam_line(1:732,:);
load('npgo_line');%1950 - 2018
npgo_line=npgo_line(85:816,:);
load('enso_line');%1950 - 2018
enso_line=enso_line(85:816,:);
load('amo_line');%1950 - 2018
amo_line=amo_line(85:816,:);

%% Fitting the Model
x=parpool(2);
x.IdleTimeout=6000;

coef_t_fixed=NaN(360,180,2);
coef_enso_fixed=NaN(360,180,2);
coef_amo_fixed=NaN(360,180,2);
coef_pdo_fixed=NaN(360,180,2);
coef_npgo_fixed=NaN(360,180,2);
coef_sam_fixed=NaN(360,180,2);

parfor i=1:360;
    tic
    coef_t_fixed_here=NaN(180,2);
    coef_enso_fixed_here=NaN(180,2);
    coef_amo_fixed_here=NaN(180,2);
    coef_pdo_fixed_here=NaN(180,2);
    coef_npgo_fixed_here=NaN(180,2);
    coef_sam_fixed_here=NaN(180,2);
    for j=1:180;
        fixed_here=squeeze(ew_index(i,j,:));
        
        if nansum(isnan(fixed_here))==0 && nansum(fixed_here==0)~=length(fixed_here)
            
            data_used=[squeeze(dif_used(i,j,:)) enso_line(:,end) amo_line(:,end) pdo_line(:,end) npgo_line(:,end) sam_line(:,end)];
            
           fixed_bin=(double(fixed_here~=0));
           fixed_bin_cell=cell(length(fixed_bin),1);
           fixed_bin_cell(fixed_bin==0)={'Normal'};
           fixed_bin_cell(fixed_bin~=0)={'Hot'};
           fixed_bin_cell=categorical(fixed_bin_cell);
           
           
           [B_fixed,dev_fixed,stats_fixed] = mnrfit(data_used,fixed_bin_cell);
           
           coef_t_fixed_here(j,1)=B_fixed(2);
           coef_t_fixed_here(j,2)=stats_fixed.p(2);
           coef_enso_fixed_here(j,1)=B_fixed(3);
           coef_enso_fixed_here(j,2)=stats_fixed.p(3);
           coef_amo_fixed_here(j,1)=B_fixed(4);
           coef_amo_fixed_here(j,2)=stats_fixed.p(4);
           coef_pdo_fixed_here(j,1)=B_fixed(5);
           coef_pdo_fixed_here(j,2)=stats_fixed.p(5);
           coef_npgo_fixed_here(j,1)=B_fixed(6);
           coef_npgo_fixed_here(j,2)=stats_fixed.p(6);
           coef_sam_fixed_here(j,1)=B_fixed(7);
           coef_sam_fixed_here(j,2)=stats_fixed.p(7);
           
        end
    end
    
    coef_t_fixed(i,:,:)=coef_t_fixed_here;
    coef_enso_fixed(i,:,:)=coef_enso_fixed_here;
    coef_amo_fixed(i,:,:)=coef_amo_fixed_here;
    coef_pdo_fixed(i,:,:)=coef_pdo_fixed_here;
    coef_npgo_fixed(i,:,:)=coef_npgo_fixed_here;
    coef_sam_fixed(i,:,:)=coef_sam_fixed_here;
    
    toc
end