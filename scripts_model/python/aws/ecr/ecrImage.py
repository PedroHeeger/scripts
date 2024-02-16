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
    ecr_client = boto3.client('ecr')

    try:
        response = ecr_client.describe_images(
            repositoryName=repository_name,
            query=f"imageDetails[?imageTags && contains(imageTags, '{image_tag}')].imageTags"
        )

        image_tags = response['imageDetails'][0]['imageTags']

        if image_tags and len(image_tags) > 1:
            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as imagens do repositório {repository_name}")
            response = ecr_client.describe_images(repositoryName=repository_name)
            print(response['imageDetails'][0]['imageTags'])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Removendo a imagem de tag {image_tag} do repositório {repository_name}")
            ecr_client.batch_delete_image(repositoryName=repository_name, imageIds=[{'imageTag': image_tag}])

            print("-----//-----//-----//-----//-----//-----//-----")
            print(f"Listando todas as imagens do repositório {repository_name}")
            all_images_after_delete = ecr_client.describe_images(repositoryName=repository_name)['imageDetails']
            all_tags_after_delete = [tag for image in all_images_after_delete for tag in image.get('imageTags', [])]
            print("\n".join(all_tags_after_delete))
        else:
            print(f"Não existe a imagem de tag {image_tag} do repositório {repository_name}")
    except ecr_client.exceptions.RepositoryNotFoundException:
        print(f"Repositório {repository_name} não encontrado.")
else:
    print("Código não executado")