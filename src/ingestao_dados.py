import os
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from sqlalchemy import create_engine
from azure.storage.blob import BlobServiceClient

# 1. Carregar as variáveis do arquivo .env
load_dotenv()

AZURE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
CONTAINER_NAME = "lending-club-raw"
BLOB_NAME = "accepted_2007_to_2018Q4.csv"

DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")

# 2. Criar a conexão com o banco de dados PostgreSQL usando SQLAlchemy
db_url = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(db_url)

# 3. Mapear as 17 colunas que foram criadas na tabela fato_loan SQL
COLUNAS_SELECIONADAS = [
    'id', 'loan_amnt', 'funded_amnt', 'term', 'int_rate', 'installment',
    'grade', 'sub_grade', 'emp_title', 'emp_length', 'home_ownership',
    'annual_inc', 'verification_status', 'issue_d', 'loan_status',
    'purpose', 'addr_state'
]

def rodar_pipeline():
    print(f"[{datetime.now()}] Iniciando o Pipeline de Ingestão...")
    
    try:
        # 4. Conectar no Azure Blob Storage e abrir o canal do arquivo
        blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONNECTION_STRING)
        blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=BLOB_NAME)
        
        print(f"[{datetime.now()}] Abrindo conexão de streaming com o Azure Blob Storage...")
        # Baixa o arquivo como um stream (sem carregar na memória)
        blob_stream = blob_client.download_blob()
        
        # 5. Ler o arquivo em blocos (Chunks) de 50.000 linhas usando o Pandas
        tamanho_bloco = 50000
        contador_blocos = 1
        
        # Passar o stream direto para o read_csv com chunksize
        reader = pd.read_csv(blob_stream, usecols=COLUNAS_SELECIONADAS, chunksize=tamanho_bloco, low_memory=False)
        
        for bloco in reader:
            print(f"[{datetime.now()}] Processando o bloco {contador_blocos} ({tamanho_bloco} linhas)...")
            
            # Limpeza rápida: Remove linhas que não possuem ID válido (como linhas vazias no fim do arquivo)
            bloco = bloco.dropna(subset=['id'])
            
            # 6. Inserir o bloco direto na tabela fato_loans do PostgreSQL
            # 'append' garante que ele vai adicionando os blocos um abaixo do outro
            bloco.to_sql(name='fato_loans', con=engine, if_exists='append', index=False)
            
            print(f"[{datetime.now()}] Bloco {contador_blocos} inserido com sucesso no PostgreSQL.")
            contador_blocos += 1
            
        print(f"[{datetime.now()}] Pipeline concluído! Todos os dados estão no PostgreSQL local.")
        
    except Exception as e:
        print(f"[{datetime.now()}] ERRO FATAL NO PIPELINE: {e}")

if __name__ == "__main__":
    rodar_pipeline()