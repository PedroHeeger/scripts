#!/usr/bin/env python3

import boto3
import time

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("MODIFY BUCKET PUBLIC ACCESS")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"
block_public_acls = True          # Impede que qualquer nova ACL pública seja aplicada a objetos no bucket. Qualquer ACL pública existente funciona.
ignore_public_acls = True         # Faz com que o bucket ignore todas as ACLs públicas existentes, independentemente de quando foram criadas. Mas permite a criação delas.
block_public_policy = True        # Impede que novas políticas públicas (Bucket Policies) sejam aplicadas ao bucket. As existentes continuarão funcionando.
restrict_public_buckets = True    # Restringe completamente o acesso público ao bucket, tanto por ACLs quanto por Bucket Policies, tanto novas como existentes.

# block_public_acls = False
# ignore_public_acls = False
# block_public_policy = True
# restrict_public_buckets = False

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ")
if resposta.lower() == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket {bucket_name}")
    s3_client = boto3.client('s3', region_name=region)
    buckets = s3_client.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    
    if bucket_name in bucket_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print("Definindo a query das configurações de bloqueio de acesso público")
        public_access_block = s3_client.get_public_access_block(Bucket=bucket_name)
        
        # Verifica se as configurações estão conforme definidas
        settings_ok = (
            public_access_block.get('PublicAccessBlockConfiguration', {}).get('BlockPublicAcls') == block_public_acls and
            public_access_block.get('PublicAccessBlockConfiguration', {}).get('IgnorePublicAcls') == ignore_public_acls and
            public_access_block.get('PublicAccessBlockConfiguration', {}).get('BlockPublicPolicy') == block_public_policy and
            public_access_block.get('PublicAccessBlockConfiguration', {}).get('RestrictPublicBuckets') == restrict_public_buckets
        )
        
        if settings_ok:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"As configurações de bloqueio de acesso público do bucket {bucket_name} estão conforme definição nas variáveis")
            print(public_access_block['PublicAccessBlockConfiguration'])
        else:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a configuração de bloqueio de acesso público do bucket {bucket_name}")
            print(public_access_block['PublicAccessBlockConfiguration'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Alterando as configurações de bloqueio de acesso público do bucket {bucket_name}")
            s3_client.put_public_access_block(
                Bucket=bucket_name,
                PublicAccessBlockConfiguration={
                    'BlockPublicAcls': block_public_acls,
                    'IgnorePublicAcls': ignore_public_acls,
                    'BlockPublicPolicy': block_public_policy,
                    'RestrictPublicBuckets': restrict_public_buckets
                }
            )
        
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando a configuração de bloqueio de acesso público do bucket {bucket_name}")
            updated_public_access_block = s3_client.get_public_access_block(Bucket=bucket_name)
            print(updated_public_access_block['PublicAccessBlockConfiguration'])
    else:
        print(f"Não existe o bucket {bucket_name}")
else:
    print("Código não executado")