#!/usr/bin/env python

import boto3

print("***********************************************")
print("SERVIÇO: AWS ECR")
print("IMAGE EXCLUSION")

print("-----//-----//-----//-----//-----//-----//-----")
print("Definindo variáveis")
repository_name = "repository_test1"
image_tag = "v1"

print("-----//-----//-----//-----//-----//-----//-----")
resposta = input("Deseja executar o código? (y/n) ").lower()
if resposta == 'y':
    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Criando um cliente para o serviço ECR")
    client = boto3.client('ecr')

    print("-----//-----//-----//-----//-----//-----//-----")
    print(f"Verificando se existe a imagem de tag {image_tag} do repositório {repository_name}")
    images = client.describe_images(repositoryName=repository_name, filter={'tagStatus': 'TAGGED'})
    filtered_images = [image['imageTags'] for image in images['imageDetails'] if image_tag in image.get('imageTags', [])]

    if filtered_images:
        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as imagens do repositório {repository_name}")
        all_images = client.describe_images(repositoryName=repository_name)['imageDetails']
        all_tags = [tag for image in all_images for tag in image.get('imageTags', [])]
        print("\n".join(all_tags))

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Removendo a imagem de tag {image_tag} do repositório {repository_name}")
        response = client.batch_delete_image(repositoryName=repository_name, imageIds=[{'imageTag': image_tag}])

        print("-----//-----//-----//-----//-----//-----//-----")
        print(f"Listando todas as imagens do repositório {repository_name}")
        all_images_after_delete = client.describe_images(repositoryName=repository_name)['imageDetails']
        all_tags_after_delete = [tag for image in all_images_after_delete for tag in image.get('imageTags', [])]
        print("\n".join(all_tags_after_delete))
    else:
        print(f"Não existe a imagem de tag {image_tag} do repositório {repository_name}")
else:
    print("Código não executado")