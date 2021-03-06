clear;
load('Klungf.mat'); %数据导入
load('Klungz.mat');
load('Zlungf.mat');
load('Zlungz.mat');

Klungf=mapminmax(Klungf,0,1);%数据归一化
Klungz=mapminmax(Klungz,0,1);
Zlungf=mapminmax(Zlungf,0,1);
Zlungz=mapminmax(Zlungz,0,1);

aux_set=[Zlungf;Zlungz];%肿瘤医院肺部CT数据作为辅助训练数据
aux_Zlungf_label=zeros(size(Zlungf,1),1); %负样本标签为0
aux_Zlungz_label=ones(size(Zlungz,1),1);%正样本标签为1
aux_train_set=aux_set;
aux_train_set_label=[aux_Zlungf_label;aux_Zlungz_label];  %辅助训练数据标签


[aux_m aux_n]=size(aux_train_set);%辅助训练数据的样本大小


base_set=[Klungf;Klungz];  %所有源训练数据
base_set_Klungf_label=zeros(size(Klungf,1),1);
base_set_Klungz_label=ones(size(Klungz,1),1);
base_set_label=[base_set_Klungf_label;base_set_Klungz_label];

[Klungf_m Klungf_n]=size(Klungf);
[Klungz_m Klungz_n]=size(Klungz);

TrainA = aux_train_set;
LabelA = aux_train_set_label;

[TrainSPost,LabelSPost,TestPostData,TestPostLabel] = GetTrainTestData(Klungf,base_set_Klungf_label,0.07)
[TrainSNegat,LabelSNegat,TestNegatData,TestNegatLabel] = GetTrainTestData(Klungz,base_set_Klungz_label,0.09)

TrainS = [TrainSPost;TrainSNegat]
LabelS = [LabelSPost;,LabelSNegat]
Test = [TestPostData;TestNegatData]
TestLabel = [TestPostLabel;TestNegatLabel]

%迁移算法
ResultLabel = TrAdaBoost(TrainS,TrainA,LabelS,LabelA,Test,10);
erT = ErrorRate(ResultLabel,TestLabel)

Post = sum(TestLabel);
Negat = size(TestLabel,1) - Post;
ResultPostT = 0;
ResultNegatT = 0;
for i=1:size(Test,1)
    if(ResultLabel(i)==1 && ResultLabel(i) == TestLabel(i))
        ResultPostT = ResultPostT +1;
    end
    if( ResultLabel(i)==0 && ResultLabel(i) == TestLabel(i) )
        ResultNegatT = ResultNegatT + 1;
    end
end
%非迁移算
ResultLabel = WeightedKNN(TrainS,LabelS,Test,5);
er = ErrorRate(ResultLabel,TestLabel)

ResultPost = 0;
ResultNegat = 0;
for i=1:size(Test,1)
    if(ResultLabel(i)==1 && ResultLabel(i) == TestLabel(i))
        ResultPost = ResultPost +1;
    end
    if( ResultLabel(i)==0 && ResultLabel(i) == TestLabel(i) )
        ResultNegat = ResultNegat + 1;
    end
end

