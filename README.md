[![docs](https://img.shields.io/badge/info-documentation-informational)](https://ftag-salt.docs.cern.ch/)

# Salt

This is the home of Salt, a framework for training multi-model and multi-task models models in the style of GN2.

Documentation is available [here](https://ftag-salt.docs.cern.ch/).

# Transformer Workflow

## Steps
[1. Produce training ntuples with FastFrame](#Step1-Produce-training-ntuples-with-FastFrame)
[2. Convert root ntuples to h5 files](#2-Convert-root-ntuples-to-h5-files)
[3. Process h5 files to feed into the SALT framework](#3-Process-h5-files-to-feed-into-the-SALT-framework)
[4. Training and Evaluation](#4-Training)
[5. Inject the Transformer score back to ntuples](#5-Inject-the-Transformer-score-back-to-ntuples)

Example config files shown in the below instructions are for 4 class training (tttt, ttt, ttV, others).

## Step1: Produce training ntuples with FastFrame

In the Transformer training, we usually have input features like pt/eta/... of each object (electron, muon, jet). In the original root files from TopCPToolkit, the branch names are ```jet_pt```, ```mu_pt```, ...., but in the training we perfer to have a general variable like ```pt```. So at the FastFrame stage, I implemented some customized variables to concat the pt/eta/... of jet, muon, electron together, and also other useful variables that might be helpful in the training.

Ntuples with customized variables can be found here: 
```
/eos/user/h/hlin/sm4tops-fastframe/Run2/output/Run2_GN2v01_85_partweighted_ttH_v3/ntuples/
```
so this step is not needed if you run with the above files. But if you want to try other customized variables, you can follow similar method [here](https://gitlab.cern.ch/atlasphys-top/TopPlusX/ANA-TOPQ-2023-43/sm4tops-fastframe/-/blob/Add-MVA-Vars/SM4topsSSML/Root/SM4topsSSML.cc?ref_type=heads). 

Example:

1. Create the variable
```
auto concat_charge = [](const int& nJets, const std::vector<float>& mu_charge, const std::vector<float>& el_charge) {
    std::vector<float> padding_jet(nJets, 0.);
    return combine_vectors<float>(padding_jet, mu_charge, el_charge);};
```

2. Book the variable 
```
mainNode = MainFrame::systematicDefine(mainNode, "concat_charge_NOSYS", concat_charge, {"nJets", "mu_charge", "el_charge"});
```

3. Compile the code in FastFrame and produce ntuples
```
source setup.sh --build
cd fastframes
python3 python/FastFrames.py --config your-config-file.yml --step n
```
Example [config-file.yml](https://gitlab.cern.ch/atlasphys-top/TopPlusX/ANA-TOPQ-2023-43/sm4tops-fastframe/-/blob/Add-MVA-Vars/BSM4topsConfigs/FastFrame_Run2_AddTrainVars.yml?ref_type=heads).


## 2. Convert root ntuples to h5 files

Setup:
This framework share the same setup as SALT. So you have to clone SALT first and follow the setup in SALT:
[Building the framework](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/build_env.sh?ref_type=heads)
[Setup before running the framework everytime](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/setup.sh?ref_type=heads)
Note: in ```setup.sh```, the file ```flavours.yaml``` defines the names of the training categories.


After setting up the environment, navigate back to the dump-to-salt framework to convert root files to h5 files.
Example [config file](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/dumper-to-salt/-/blob/master/config/Test_SR_4class_GN2v01WP85_v1.yaml?ref_type=heads).
Example command (full [list](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/dumper-to-salt/-/blob/master/script/Test_SR_4class_GN2v01WP85_v1.sh?ref_type=heads) here): 
```
python dumper.py --config config/VTX_common/TopCPToolkit/Test_SR_4class_GN2v01WP85_v1.yaml --convert --convert_sample "tttt"
```

## 3. Process h5 files to feed into the SALT framework

Preparation of data that fits the input format in SALT can be done with the [Umami PreProcessing](https://github.com/umami-hep/umami-preprocessing) framework. Documentation can be found in their official repo above. 

Setup:
[Build the framework](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/build.sh?ref_type=heads)
[Setup before running the framework everytime](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/setup.sh?ref_type=heads) 

Example [config](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/upp/configs/tttt/tttt_SR_4class_GN2v01WP85_v4/fold0.yaml?ref_type=heads).
Command to run: [convert.sh](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/scripts/convert.sh?ref_type=heads)

### 1) One config for one fold
One config needed for each fold, in which the following lines should be modified accordingly:

```
train:
- [eventNumber, "%4!=", 1]
- [eventNumber, "%4!=", 0]
val:
- [eventNumber, "%4==", 1]
test:
- [eventNumber, "%4==", 0]
```

### 2) Adjust the number of training events

```
components:
  - region:
      <<: *inclusive
    sample:
      <<: *tttt
    flavours: [tttt]
    #num_jets: 100_000_000
    num_jets: 46_659
```

In the above code we need to specify the number of jets to be sampled from each category in the training split ```num_jets```. (You can also set ```num_jets_val``` and ```num_jets_test``` which are set to be ```num_jets*0.45``` by [default](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/upp/classes/components.py#L117).)

For now we just set ```num_jets``` to be the maximum number allowed. The way we use to know the maximum number allowed is quite awkward, so maybe can be improved there. Here's how we do it now:

1) Set ```num_jets``` to be 100_000_000 for each category, run ```convert.sh```, then it will tell you that 100_000_000 exceeds the maximum number allowed, and tell you the number that can be used.
2) Replace 100_000_000 by the allowed number, and run ```convert.sh``` again. Repeat this step until numbers of all categories are replaced. At the last time you run ```convert.sh```, the output files will be generated, and you can use them as the inputs to SALT.

## 4. Training

Setup:
[Building the framework](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/build_env.sh?ref_type=heads)
[Setup before running the framework everytime](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/setup.sh?ref_type=heads)
[Setup comet logger](https://gitlab.cern.ch/hlin/salt/-/blob/AuxiliaryTasks/docs/setup.md#comet)

One config file for each fold.

[Example Config 1 (default)](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_GN2v01WP85_v4p5/fold0.yaml?ref_type=heads) 
* Can be run with the input data coming from TopCPToolkit.
* Edge features and Auxiliary tasks are not used. 
    * edge features not used because they are not supported for the current ONNX export in SALT, but it's ok because they don't have much impact on the performance.
    * Auxiliary tasks are removed temporarily because the input variables are not available in TopCPToolkit now, but will be implemented later.

[Example Config 2](https://gitlab.cern.ch/hlin/salt/-/blob/AuxiliaryTasks/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_Legacy77_v3/fold0.yaml)
* Need to be run with previous AnalysisTop ntuples.
* Edge features and Auxiliary tasks included.

In the config file, the main classification task is this one:
```
name: jets_classification
                input_name: jets
                label: flavour_label
                loss:
                  class_path: torch.nn.CrossEntropyLoss
                  init_args: { weight: [2.14, 1.89, 1.0, 6.27] }
```
(the naming jets_classification and flavour_label are just the default names from SALT framework, so actually in here we mean classification between tttt/ttt/ttV/others.)

Put each class name in [class_names.py](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/salt/-/blob/main/salt/utils/class_names.py?ref_type=heads).

Adjust the ```weight: [2.14, 1.89, 1.0, 6.27]``` to have a balanced training for each class. The weigths can be seen from the ```class_dict.yaml``` in your output directory ```preprocess_foldX``` defined in the [UPP config](https://gitlab.cern.ch/atlas-phys/exot/hqt/ana-exot-2022-44/ftag-based-mva/umami-preprocessing/-/blob/master/upp/configs/tttt/tttt_SR_4class_GN2v01WP85_v4/fold0.yaml?ref_type=heads#L85). 

Command for training:
```salt fit --config path/to/your/config.yaml --force > path/to/log/file.txt 2>&1```

Command for evaluation:
```
salt test --config logs/tttt_all_4class_SR_GN2v01WP85_v4p2_fold0_20240624-T134206/config.yaml --data.test_file /Test_SR_2class_GN2v01WP85_v1/preprocess_fold0/pp_output_train.h5 --ckpt_path tttt_all_4class_SR_GN2v01WP85_v4p2_fold0_20240624-T134206/salt/089fb67113e243c3a45631900eb45dec/checkpoints/epoch=49-step=21000.ckpt 
```
Note: the config file in the evaluation is the one in the output folder, not the one used for the training.

Do the evaluation for each sample (train, test_tttt, test_ttt, test_ttV, test_others).

You can take a look at this [script](https://gitlab.cern.ch/hlin/alpha-mva/-/blob/b_01_conversion/share/plot_tttt_4class_test.py) for plotting the results, by changing your input [here](https://gitlab.cern.ch/hlin/alpha-mva/-/blob/b_01_conversion/share/plot_tttt_4class_test.py?ref_type=heads#L327).

## 5. Inject the Transformer score back to ntuples

This can be done in FastFrame stage:
Define the models in [SM4topsSSML](https://gitlab.cern.ch/atlasphys-top/TopPlusX/ANA-TOPQ-2023-43/sm4tops-fastframe/-/blob/onnx-dummy/SM4topsSSML/Root/SM4topsSSML.cc?ref_type=heads#L13), and write the score evaluation [here](https://gitlab.cern.ch/atlasphys-top/TopPlusX/ANA-TOPQ-2023-43/sm4tops-fastframe/-/blob/master/SM4topsSSML/Root/GN2TransformerEval.cc?ref_type=heads).
Then, the MVA variables can be added in the ntuple/histogram production.

# Run on hpcc

After install the salt, submit the training job and evulate by:
```
cd salt/job
sh submit.sh
sh run_salt_eval.sh
```