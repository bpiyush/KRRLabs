# creates conda environment for hw2
# installs python packages required

conda create -y -n krr-py3.9
conda activate krr-py3.9
conda install -y python=3.9
conda install ipykernel
pip install clingo
pip install python-sat
pip install jupyterlab

echo ":::: Created conda environment for hw2 ::::"