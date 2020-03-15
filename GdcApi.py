'''
提供 GDC Menifest 文件，批量下载 GDC 文件。

脚本在 Python 3.7 环境测试通过。
要求 Python 已安装以下模块：
 - requests
 - json
'''

import sys
import pathlib
import requests
import json
import re

print('python GdcApi.py Menifest.txt OutputDir')
print('-'*50)
print('')

argvs = sys.argv
in_path = pathlib.Path(argvs[1])
out_dir = pathlib.Path(argvs[2])
print(f'输入Menifest: {in_path}')

data_endpt = 'https://api.gdc.cancer.gov/data'
file_id = []
with open(in_path, 'r') as f:
    f.readline()
    for line in f:
        items = line.strip().split('\t')
        name = items[0]
        file_id.append(name)

file_num = len(file_id)
print(f'文件总数目：{file_num}')

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
