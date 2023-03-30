%% Read in all exported MWM files

fileList = dir('/Users/hsm/Downloads/exported_files_032322/');


file_dir = {fileList.folder};
file_name = {fileList.name};

%full_sheet = cell2table(cell(1,1));
 
full_sheet = readtable(strcat(file_dir{4},'/',file_name{4}));
full_sheet = full_sheet(1,:);

% start from 4 bc disregarding . .. .ds_store
% Important to check whether you have .ds_store or not. If not start from 3

for i = 4:length(fileList)
    file_path = strcat(file_dir{i},'/',file_name{i});
    file_temp = readtable(file_path);
    new_vars = strrep(file_temp.Properties.VariableNames,'_m_s_','');
    new_vars = strrep(new_vars,'_m_','');
    new_vars = strrep(new_vars,'_s_','');
    file_temp = renamevars(file_temp,1:width(file_temp),new_vars);

    full_sheet = outerjoin(full_sheet,file_temp, 'MergeKeys',true);
end
 
full_sheet = outerjoin(full_sheet,file_temp, 'MergeKeys',true);

full_sheet.Animal = strrep(full_sheet.Animal,'-','_');
full_sheet.Animal = strtrim(full_sheet.Animal);

full_sheet(1,:) = [];

%% read 3 different mice information sheets
mastersheet_1 = readtable('/Users/hsm/Downloads/Mastersheet_Experiments2021.xlsx','Sheet','18ABB11_readable02.22.22_BJ_Cor');
mastersheet_2 = readtable('/Users/hsm/Downloads/qial_animals_with_age2.csv');
mastersheet_3 = readtable('/Users/hsm/Downloads/Mastersheet_Experiments2021.xlsx','Sheet','All_Cohorts_V2');

mastersheet_1.BadeaID = strtrim(mastersheet_1.BadeaID);
mastersheet_1.BadeaID = (strrep(mastersheet_1.BadeaID,'-','_'));

master_animal_id = mastersheet_1.BadeaID;
master_age = mastersheet_1.Age_Months;

mastersheet_2.BadeaID = strtrim(mastersheet_2.BadeaID);
mastersheet_2.BadeaID = (strrep(mastersheet_2.BadeaID,'-','_'));

mastersheet_3.Animal_ID = strtrim(mastersheet_3.Animal_ID);
mastersheet_3.Animal_ID = (strrep(mastersheet_3.Animal_ID,'-','_'));

%% Fill in missing info from first sheet

Age_mastersheet = cell(height(full_sheet),1);
Sex_mastersheet = cell(height(full_sheet),1);
Genotype_mastersheet = cell(height(full_sheet),1);
Diet_mastersheet = cell(height(full_sheet),1);
%Age_months_mastersheet = nan(height(full_sheet),1);
Age_handling_mastersheet = cell(height(full_sheet),1);

%T = table('Size',[height(full_sheet) 3],'VariableTypes',{'string'});

merged_sheet = addvars(full_sheet,Age_mastersheet,Sex_mastersheet, ...
    Genotype_mastersheet,Diet_mastersheet, ...
    Age_handling_mastersheet,'After', 'Genotype');


for j = 1:height(merged_sheet)
    animal_ind_tmp = find(strcmp(merged_sheet.Animal(j),mastersheet_1.BadeaID));
    if isempty(animal_ind_tmp) == 0
        merged_sheet.Age_mastersheet{j} = mastersheet_1.Age_Months(animal_ind_tmp);
        merged_sheet.Sex_mastersheet{j} = mastersheet_1.Sex(animal_ind_tmp);
        merged_sheet.Genotype_mastersheet{j} = mastersheet_1.Genotype(animal_ind_tmp);
        merged_sheet.Diet_mastersheet{j} = mastersheet_1.Diet(animal_ind_tmp);
        merged_sheet.Age_handling_mastersheet{j} = mastersheet_1.Age_Handling(animal_ind_tmp);

        %mastersheet_1.BadeaID(animal_ind_tmp);
    end
end


%% Fill in missing info into the merged sheet from second sheet
for i = 1:height(merged_sheet)
    if all(isnan(merged_sheet.Age_mastersheet{i})) || isempty(merged_sheet.Age_mastersheet{i}) ==1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_2.BadeaID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Age_mastersheet{i} = mastersheet_2.Age_Months(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Sex_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_2.BadeaID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Sex_mastersheet{i} = mastersheet_2.Sex(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Genotype_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_2.BadeaID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Genotype_mastersheet{i} = mastersheet_2.Genotype(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Diet_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_2.BadeaID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Diet_mastersheet{i} = mastersheet_2.Diet(animal_ind_tmp);
        end
    end

    if all(isnan(merged_sheet.Age_handling_mastersheet{i}))  || isempty(merged_sheet.Age_handling_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_2.BadeaID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Age_handling_mastersheet{i} = mastersheet_2.Age_Handling(animal_ind_tmp);
        end
    end
end


%% Fill in missing info from third sheet

for i = 1:height(merged_sheet)
    if all(isnan(merged_sheet.Age_mastersheet{i})) || isempty(merged_sheet.Age_mastersheet{i}) ==1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_3.Animal_ID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Age_mastersheet{i} = mastersheet_3.Age_months_(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Sex_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_3.Animal_ID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Sex_mastersheet{i} = mastersheet_3.Sex(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Genotype_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_3.Animal_ID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Genotype_mastersheet{i} = mastersheet_3.Genotype(animal_ind_tmp);
        end
    end

    if isempty(merged_sheet.Diet_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_3.Animal_ID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Diet_mastersheet{i} = mastersheet_3.Diet(animal_ind_tmp);
        end
    end

    if all(isnan(merged_sheet.Age_handling_mastersheet{i}))  || isempty(merged_sheet.Age_handling_mastersheet{i}) == 1
        animal_ind_tmp = find(strcmp(merged_sheet.Animal{i},mastersheet_3.Animal_ID));
        if isempty(animal_ind_tmp) == 0
            merged_sheet.Age_handling_mastersheet{i} = mastersheet_3.Age_at_Handling(animal_ind_tmp);
        end
    end
end

% nomenclature fix

for i = 1:height(merged_sheet)
    if char(merged_sheet.Sex_mastersheet{i}) == 'F'
        char(merged_sheet.Sex_mastersheet{i})
        merged_sheet.Sex_mastersheet{i} = 'female';
        char(merged_sheet.Sex_mastersheet{i})
    end
end

% delete trailing blanks

merged_sheet.Sex_mastersheet = strtrim(merged_sheet.Sex_mastersheet);
merged_sheet.Genotype_mastersheet = strtrim(merged_sheet.Genotype_mastersheet);
merged_sheet.Diet_mastersheet = strtrim(merged_sheet.Diet_mastersheet);



% save the merged sheet

%writetable(merged_sheet, '/Users/hsm/Downloads/merged_MWM_4.csv')




