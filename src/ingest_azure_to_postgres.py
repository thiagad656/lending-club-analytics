import os
import pandas as pd
from datetime import datetime
from dotenv import load_dotenv
from sqlalchemy import create_engine
from azure.storage.blob import BlobServiceClient

# 1. Carregar as variáveis de ambiente do arquivo .env
# english version: 1. Load environment variables from the .env file
load_dotenv()

# Credenciais e parâmetros de acesso ao Azure Blob Storage
# english version: Credentials and access parameters for Azure Blob Storage
AZURE_CONNECTION_STRING = os.getenv("AZURE_STORAGE_CONNECTION_STRING")
CONTAINER_NAME = "lending-club-raw"
BLOB_NAME = "accepted_2007_to_2018Q4.csv"

# Credenciais para conexão com o banco de dados PostgreSQL
# english version: Credentials for connecting to the PostgreSQL database
DB_HOST = os.getenv("DB_HOST")
DB_PORT = os.getenv("DB_PORT")
DB_NAME = os.getenv("DB_NAME")
DB_USER = os.getenv("DB_USER")
DB_PASS = os.getenv("DB_PASS")

# 2. Criar a URI de conexão e a engine do PostgreSQL via SQLAlchemy
# english version: 2. Create the connection URI and PostgreSQL engine via SQLAlchemy
db_url = f"postgresql://{DB_USER}:{DB_PASS}@{DB_HOST}:{DB_PORT}/{DB_NAME}"
engine = create_engine(db_url)

# 3. Mapear as 17 colunas essenciais selecionadas para a tabela fato_loans
# english version: 3. Map the 17 essential columns selected for the fato_loans table
COLUNAS_SELECIONADAS = [
    'id', 'loan_amnt', 'funded_amnt', 'term', 'int_rate', 'installment',
    'grade', 'sub_grade', 'emp_title', 'emp_length', 'home_ownership',
    'annual_inc', 'verification_status', 'issue_d', 'loan_status',
    'purpose', 'addr_state'
]

def rodar_pipeline():
    # Log de início da execução do pipeline
    # english version: Pipeline execution start log
    print(f"[{datetime.now()}] Iniciando o Pipeline de Ingestão...")
    
    try:
        # 4. Conectar ao Azure Blob Storage e abrir o canal do arquivo (stream)
        # english version: 4. Connect to Azure Blob Storage and open the file stream
        blob_service_client = BlobServiceClient.from_connection_string(AZURE_CONNECTION_STRING)
        blob_client = blob_service_client.get_blob_client(container=CONTAINER_NAME, blob=BLOB_NAME)
        
        print(f"[{datetime.now()}] Abrindo conexão de streaming com o Azure Blob Storage...")
        
        # Baixar o arquivo como um stream em memória (sem salvar no disco local)
        # english version: Download the file as an in-memory stream (without saving to local disk)
        blob_stream = blob_client.download_blob()
        
        # 5. Configurar a leitura em blocos (Chunks) para otimização do uso de memória RAM
        # english version: 5. Configure chunked reading for RAM memory optimization
        tamanho_bloco = 50000
        contador_blocos = 1
        
        # Passar o stream direto para o read_csv com seleção de colunas e tamanho do bloco
        # english version: Pass the stream directly to read_csv with column selection and chunk size
        reader = pd.read_csv(
            blob_stream, 
            usecols=COLUNAS_SELECIONADAS, 
            chunksize=tamanho_bloco, 
            low_memory=False
        )
        
        # Processar sequencialmente cada bloco de dados carregado da nuvem
        # english version: Sequentially process each data chunk loaded from the cloud
        for bloco in reader:
            print(f"[{datetime.now()}] Processando o bloco {contador_blocos} ({tamanho_bloco} linhas)...")
            
            # Limpeza rápida: remover registros sem ID válido (evita linhas vazias de fim de arquivo)
            # english version: Quick cleanup: remove records without a valid ID (prevents EOF empty lines)
            bloco = bloco.dropna(subset=['id'])
            
            # 6. Inserir o bloco diretamente na tabela fato_loans do PostgreSQL
            # english version: 6. Insert chunk directly into the PostgreSQL fato_loans table
            # O modo 'append' garante a adição sequencial dos blocos
            # english version: The 'append' mode ensures sequential addition of chunks
            bloco.to_sql(name='fato_loans', con=engine, if_exists='append', index=False)
            
            print(f"[{datetime.now()}] Bloco {contador_blocos} inserido com sucesso no PostgreSQL.")
            contador_blocos += 1
            
        print(f"[{datetime.now()}] Pipeline concluído! Todos os dados estão no PostgreSQL local.")
        
    except Exception as e:
        # Captura e exibe qualquer erro crítico que interrompa o pipeline
        # english version: Capture and display any critical error interrupting the pipeline
        print(f"[{datetime.now()}] ERRO FATAL NO PIPELINE: {e}")

# Ponto de entrada do script para execução direta
# english version: Script entry point for direct execution
if __name__ == "__main__":
    rodar_pipeline()