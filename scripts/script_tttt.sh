# === tttt ===
# v4p5
salt fit --config /atlas/data19/huichil/salt/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_GN2v01WP85_v4p5/fold0.yaml --force > logs/tttt_all_4class_SR_GN2v01WP85_v4p5_fold0.txt 2>&1
salt fit --config /atlas/data19/huichil/salt/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_GN2v01WP85_v4p5/fold1.yaml --force > logs/tttt_all_4class_SR_GN2v01WP85_v4p5_fold1.txt 2>&1
salt fit --config /atlas/data19/huichil/salt/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_GN2v01WP85_v4p5/fold2.yaml --force > logs/tttt_all_4class_SR_GN2v01WP85_v4p5_fold2.txt 2>&1
salt fit --config /atlas/data19/huichil/salt/salt/configs/tttt_all_4class_SR/tttt_all_4class_SR_GN2v01WP85_v4p5/fold3.yaml --force > logs/tttt_all_4class_SR_GN2v01WP85_v4p5_fold3.txt 2>&1

# === ttZp ===
# v4p6: mass parameterized
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttZp_all_4class_SR/ttZp_allmass_4class_SR_GN2v01WP85_v4p6/fold0.yaml --force > logs/ttZp_allmass_4class_SR_GN2v01WP85_v4p6_fold0.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttZp_all_4class_SR/ttZp_allmass_4class_SR_GN2v01WP85_v4p6/fold1.yaml --force > logs/ttZp_allmass_4class_SR_GN2v01WP85_v4p6_fold1.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttZp_all_4class_SR/ttZp_allmass_4class_SR_GN2v01WP85_v4p6/fold2.yaml --force > logs/ttZp_allmass_4class_SR_GN2v01WP85_v4p6_fold2.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttZp_all_4class_SR/ttZp_allmass_4class_SR_GN2v01WP85_v4p6/fold3.yaml --force > logs/ttZp_allmass_4class_SR_GN2v01WP85_v4p6_fold3.txt 2>&1 &

# === ttH === 
# v4p6
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttH_all_4class_SR/ttH_allmass_4class_SR_GN2v01WP85_v4p6/fold0.yaml --force > logs/ttH_allmass_4class_SR_GN2v01WP85_v4p6_fold0.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttH_all_4class_SR/ttH_allmass_4class_SR_GN2v01WP85_v4p6/fold1.yaml --force > logs/ttH_allmass_4class_SR_GN2v01WP85_v4p6_fold1.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttH_all_4class_SR/ttH_allmass_4class_SR_GN2v01WP85_v4p6/fold2.yaml --force > logs/ttH_allmass_4class_SR_GN2v01WP85_v4p6_fold2.txt 2>&1 &
salt fit --config /atlas/data19/huichil/salt/salt/configs/ttH_all_4class_SR/ttH_allmass_4class_SR_GN2v01WP85_v4p6/fold3.yaml --force > logs/ttH_allmass_4class_SR_GN2v01WP85_v4p6_fold3.txt 2>&1 &
