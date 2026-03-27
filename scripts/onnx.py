import os
import re
import subprocess
from pathlib import Path
import glob

def convert_to_onnx(task_base_name: str, output_task_name: str = "ttZp"):
    log_dir = Path("logs")
    onnx_dir = Path("onnx") / task_base_name
    onnx_dir.mkdir(parents=True, exist_ok=True)

    for fold in range(4):
        # Build regex for matching the fold directory
        fold_prefix = f"{task_base_name}_fold{fold}"  # Replaces the last digit of fold2 with 0-3
        fold_dirs = [d for d in log_dir.glob(f"{fold_prefix}_*") if d.is_dir()]

        print(fold_prefix,fold_dirs)

        if len(fold_dirs) != 1:
            print(f"Error: Expected one directory for fold {fold}, but found {len(fold_dirs)}")
            print(fold_dirs)
            exit

        fold_dir = fold_dirs[0]
        config_path = fold_dir / "config.yaml"

        # Find checkpoint file using regex
        ckpt_files = glob.glob(os.path.join(fold_dir, '**', 'epoch=*020-val_loss*.ckpt'), recursive=True)
        
        if len(ckpt_files) != 1:
            print(f"Error: Expected one checkpoint file in {fold_dir}, but found {len(ckpt_files)}")
            exit

        ckpt_file = ckpt_files[0]

        # Build and run the command
        to_onnx_cmd = [
            "to_onnx",
            "-c", str(config_path),
            "--ckpt_path", str(ckpt_file),
            "-task_name", "jets",
            "-o",
            "-n", output_task_name
        ]
        print("Running:", " ".join(to_onnx_cmd))
        subprocess.run(to_onnx_cmd, check=True)

        # Move the generated ONNX file
        onnx_files = glob.glob(os.path.join(fold_dir, '**', 'network.onnx'), recursive=True)

        generated_onnx = onnx_files[0]

        target_onnx = onnx_dir / f"{output_task_name}fold{fold}.onnx"
        print(f"Moving {generated_onnx} -> {target_onnx}")
        os.system("cp " + str(generated_onnx) + " " +str(target_onnx))

def run_salt_tests(task_base_name: str, data_dir: str):
    log_dir = Path("logs")
    test_file_base = data_dir
    test_files = [
        "pp_output_test_ttZp.h5",
        "pp_output_test_tZp.h5",
        "pp_output_test_tttt_ttt.h5",
        #"pp_output_test_tttt.h5",
        #"pp_output_test_ttt.h5",
        "pp_output_test_ttV.h5",
        #"pp_output_test_ttW.h5",
        "pp_output_test_otherbkg.h5",
        #"pp_output_train.h5"
    ]

    for fold in [0,1,2,3]:
        fold_prefix = f"{task_base_name}_fold{fold}"
        print(fold_prefix)
        fold_dirs = [d for d in log_dir.glob(f"{fold_prefix}_*") if d.is_dir()]

        if len(fold_dirs) != 1:
            print(f"Error: Expected one directory for fold {fold}, but found {len(fold_dirs)}")
            exit
        fold_dir = fold_dirs[0]
        config_path = fold_dir / "config.yaml"

        # Find checkpoint
        ckpt_dir = fold_dir / "ckpts"

        #ckpt_files = list(ckpt_dir.glob("epoch=020-val_loss=*.ckpt"))
        ckpt_files = glob.glob(os.path.join(fold_dir, '**', 'epoch=*020*loss*.ckpt'), recursive=True)
        print(ckpt_files)


        if len(ckpt_files) != 1:
            print(f"Error: Expected one checkpoint file in {ckpt_dir}, but found {len(ckpt_files)}")
            exit

        ckpt_path = ckpt_files[0]

        # Run salt test for each test file
        for file_name in test_files:
            test_file_path = f"{test_file_base}/preprocess_fold{fold}/{file_name}"
            cmd = [
                "salt", "test",
                "--config", str(config_path),
                "--data.test_file", test_file_path,
                "--ckpt_path", str(ckpt_path)
            ]
            print("Running:", " ".join(cmd))
            subprocess.run(cmd, check=True)


if __name__ == "__main__":
    run_salt_tests("tttt_SM_Run3_DNN_p7017_v2p2","/mnt/research/fourtop/rqian/Transformer_DNN_tttt/Run3_tttt_p7017_v2/")
    convert_to_onnx("tttt_SM_Run3_DNN_p7017_v2p2","tttt")