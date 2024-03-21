BTAGNAME=(Legacy60 Legacy70 Legacy77 Legacy85 Alias60 Alias70 Alias77 Alias85)
nBTagsVar=(nBTags_GN2v00LegacyWP_60 nBTags_GN2v00LegacyWP_70 nBTags_GN2v00LegacyWP_77 nBTags_GN2v00LegacyWP_85 nBTags_GN2v00NewAliasWP_60 nBTags_GN2v00NewAliasWP_70 nBTags_GN2v00NewAliasWP_77 nBTags_GN2v00NewAliasWP_85)
# BTAGNAME=(Legacy77)
# nBTagsVar=(nBTags_GN2v00LegacyWP_77)

folder=GN2_ttHH_all_2class_SR_edge

for btagIdx in {0..7..1}
do
    subfolder=${folder}/GNT_ttHH_${BTAGNAME[$btagIdx]}_SR_2class_edge_v04_00_0001_v2
    mkdir -p salt/configs/$subfolder
    cp salt/configs/${folder}/template.yaml salt/configs/${subfolder}/template.yaml
    sed -i "s/BTAGNAME/${BTAGNAME[$btagIdx]}/g" salt/configs/${subfolder}/template.yaml
    sed -i "s/nBTagsVar/${nBTagsVar[$btagIdx]}/g" salt/configs/${subfolder}/template.yaml
    echo $subfolder
    source create_config_per_btag.sh $subfolder
done