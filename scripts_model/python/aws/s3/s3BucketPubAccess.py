import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("ENABLE BUCKET PUBLIC ACCESS")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket de nome {bucket_name}")
    s3 = boto3.client('s3', region_name=region)
    buckets = s3.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    if bucket_name in bucket_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a configuração de bloqueio de acesso público do bucket de nome {bucket_name} está desativada")
        try:
            public_access_block = s3.get_public_access_block(Bucket=bucket_name)
            block_public_acls = public_access_block['PublicAccessBlockConfiguration']['BlockPublicAcls']
            ignore_public_acls = public_access_block['PublicAccessBlockConfiguration']['IgnorePublicAcls']
            restrict_public_buckets = public_access_block['PublicAccessBlockConfiguration']['RestrictPublicBuckets']
            
            if not block_public_acls and not ignore_public_acls and not restrict_public_buckets:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Já está desativada a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                print(public_access_block['PublicAccessBlockConfiguration'])
            else:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                print(public_access_block['PublicAccessBlockConfiguration'])
                
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Desativando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                s3.put_public_access_block(
                    Bucket=bucket_name,
                    PublicAccessBlockConfiguration={
                        'BlockPublicAcls': False,
                        'IgnorePublicAcls': False,
                        'BlockPublicPolicy': True,
                        'RestrictPublicBuckets': False
                    }
                )
                
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                public_access_block = s3.get_public_access_block(Bucket=bucket_name)
                print(public_access_block['PublicAccessBlockConfiguration'])
        except s3.exceptions.ClientError as e:
            print(f"Erro ao acessar a configuração de bloqueio de acesso público: {e}")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("DISABLE BUCKET PUBLIC ACCESS")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
bucket_name = "bucket-test1-ph"
region = "us-east-1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").strip().lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe o bucket de nome {bucket_name}")
    s3 = boto3.client('s3', region_name=region)
    buckets = s3.list_buckets()
    bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
    if bucket_name in bucket_names:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se a configuração de bloqueio de acesso público do bucket de nome {bucket_name} está desativada")
        try:
            public_access_block = s3.get_public_access_block(Bucket=bucket_name)
            block_public_acls = public_access_block['PublicAccessBlockConfiguration']['BlockPublicAcls']
            ignore_public_acls = public_access_block['PublicAccessBlockConfiguration']['IgnorePublicAcls']
            restrict_public_buckets = public_access_block['PublicAccessBlockConfiguration']['RestrictPublicBuckets']
            
            if not block_public_acls and not ignore_public_acls and not restrict_public_buckets:
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                print(public_access_block['PublicAccessBlockConfiguration'])
                
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Ativando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                s3.put_public_access_block(
                    Bucket=bucket_name,
                    PublicAccessBlockConfiguration={
                        'BlockPublicAcls': True,
                        'IgnorePublicAcls': True,
                        'BlockPublicPolicy': True,
                        'RestrictPublicBuckets': True
                    }
                )
                
                print("-----//-----//-----//-----//-----//-----//-----")
                print(f"Listando a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
                public_access_block = s3.get_public_access_block(Bucket=bucket_name)
                print(public_access_block['PublicAccessBlockConfiguration'])
            else:
                print(f"Não está desativada a configuração de bloqueio de acesso público do bucket de nome {bucket_name}")
        except s3.exceptions.ClientError as e:
            print(f"Erro ao acessar a configuração de bloqueio de acesso público: {e}")
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")