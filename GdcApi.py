'''
提供 GDC Manifest 文件，批量下载 GDC 文件。

脚本在 Python 3.7 环境测试通过。
要求 Python 已安装以下模块：
 - argparse
 - requests
 - json
'''

import argparse
import pathlib
import requests
import json
import re

parser = argparse.ArgumentParser(description="根据 Manifest 用 GDC Api 下载 TCGA 数据。", add_help=True)
parser.add_argument("-m", "--manifest", dest="MNF", help="Manifest 文件路径")
parser.add_argument("-o", "--outdir", dest="OTD", help="下载到目录")
argvs = parser.parse_args()
in_path = pathlib.Path(argvs.MNF).resolve()
out_dir = pathlib.Path(argvs.OTD).resolve()
print(f'输入 Manifest: {in_path}')

data_endpt = 'https://api.gdc.cancer.gov/data'
file_id = []
with open(in_path, 'r') as f:
    f.readline()
    for line in f:
        items = line.strip().split('\t')
        name = items[0]
        file_id.append(name)

file_num = len(file_id)
print(f'下载文件数：{file_num}')

params = {"ids": file_id}

response = requests.post(data_endpt, data=json.dumps(params),
                         headers={"Content-Type": "application/json"})
response_head_cd = response.headers["Content-Disposition"]
file_name = re.findall("filename=(.+)", response_head_cd)[0]
out_path = out_dir / file_name
print(f'输出文件路径：{out_path}')

with open(out_path, 'wb') as output_file:
    output_file.write(response.content)

print('完成')
