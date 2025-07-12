#!/usr/bin/env python3

import os
import subprocess
import sys
import time

def main():
    # cd into infrastructure directory, if not already there
    if os.path.basename(os.getcwd()) != "infrastructure":
        print("Changing directory to infrastructure")
        try:
            os.chdir("infrastructure")
        except Exception as e:
            print(f"Failed to change directory: {e}")
            sys.exit(1)
    else:
        print("Already in infrastructure directory")

    print("Creating infrastructure")
    plan_cmd = ["tofu", "plan", "-out=../outputs/terraform/tfplan", "-var-file=terraform.tfvars"]
    apply_cmd = ["tofu", "apply", "-auto-approve", "-var-file=terraform.tfvars"]

    plan_proc = subprocess.run(plan_cmd)
    if plan_proc.returncode != 0:
        print("Failed to plan infrastructure")
        sys.exit(1)

    apply_proc = subprocess.run(apply_cmd)
    if apply_proc.returncode == 0:
        print("Infrastructure created successfully")
        print("Quick sleep while instances spin up")
        time.sleep(120)
        print("Ansible provisioning")
        ansible_cmd = [
            "ansible-playbook",
            "-i", "kargo/inventory/inventory",
            "-u", "ubuntu",
            "-b",
            "kargo/cluster.yml"
        ]
        env = os.environ.copy()
        env["ANSIBLE_HOST_KEY_CHECKING"] = "False"
        subprocess.run(ansible_cmd, env=env)
    else:
        print("Failed to create infrastructure")
        print("Please check the output above for errors.")
        sys.exit(1)

main()
