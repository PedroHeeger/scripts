import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("BUCKET CREATION")

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
        print(f"Já existe o bucket de nome {bucket_name}")
        print(bucket_name)
    else:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os buckets na região {region}")
        for bucket in bucket_names:
            print(bucket)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Criando o bucket de nome {bucket_name}")
        if region == 'us-east-1':
            s3.create_bucket(Bucket=bucket_name)
        else:
            s3.create_bucket(Bucket=bucket_name, CreateBucketConfiguration={'LocationConstraint': region})

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando o bucket de nome {bucket_name}")
        bucket_names = [bucket['Name'] for bucket in s3.list_buckets()['Buckets']]
        print(bucket_name)
else:
    print("Código não executado")




import boto3

print("***********************************************")
print("SERVIÇO: AMAZON S3")
print("BUCKET EXCLUSION")

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
        print(f"Listando todos os buckets na região {region}")
        for bucket in bucket_names:
            print(bucket)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Verificando se há objetos no bucket de nome {bucket_name} e removendo caso haja")
        objects = s3.list_object_versions(Bucket=bucket_name)
        for version in objects.get('Versions', []):
            key = version['Key']
            version_id = version['VersionId']
            s3.delete_object(Bucket=bucket_name, Key=key, VersionId=version_id)
        
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo o bucket de nome {bucket_name}")
        s3.delete_bucket(Bucket=bucket_name)

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todos os buckets na região {region}")
        buckets = s3.list_buckets()
        bucket_names = [bucket['Name'] for bucket in buckets['Buckets']]
        for bucket in bucket_names:
            print(bucket)
    else:
        print(f"Não existe o bucket de nome {bucket_name}")
else:
    print("Código não executado")