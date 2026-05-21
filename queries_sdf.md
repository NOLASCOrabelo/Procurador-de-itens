# Queries SQL para Banco de Dados .sdf - Itens Gravados

## � QUERY DIAGNÓSTICO: Descobrir Estrutura das Tabelas

```sql
-- Ver todas as colunas da tabela Jobs
SELECT TOP 1 * FROM Jobs;

-- Ver todas as colunas da tabela JobResultFiles
SELECT TOP 1 * FROM JobResultFiles;

-- Ver todas as colunas da tabela JobTCSectors
SELECT TOP 1 * FROM JobTCSectors;
```

**Execute estas queries primeiro para descobrir quais colunas existem!**

---

## �📋 QUERY 1: Lista de Jobs com Datas de Início e Fim

```sql
SELECT 
    j.Id,
    j.Name,
    j.Created,
    j.Modified,
    jts.Started AS DataInicio,
    jts.StopTimecode AS DataFim,
    j.Status
FROM Jobs j
LEFT JOIN JobTCSectors jts ON jts.JobId = j.Id
ORDER BY jts.Started DESC;
```

**Descrição:** Lista todos os jobs com suas datas de criação, modificação, início e fim da gravação.

---

## 📋 QUERY 2: Arquivos Resultantes com Datas

```sql
SELECT 
    jrf.Id,
    jrf.FileName AS NomeArquivo,
    jrf.Created AS DataCriacao,
    jrf.Modified AS DataModificacao,
    jts.Started AS DataGravacaoInicio,
    jts.StopTimecode AS DataGravacaoFim,
    jrfl.Location AS Localizacao,
    jrfl.FileSize AS TamanhoArquivo
FROM JobResultFiles jrf
INNER JOIN JobTCSectors jts ON jts.Id = jrf.JobTCSectorId
LEFT JOIN JobResultFileLocations jrfl ON jrfl.JobResultFileId = jrf.Id
ORDER BY jts.Started DESC;
```

**Descrição:** Lista todos os arquivos resultantes com informações completas sobre quando foram gravados.

---

## 📋 QUERY 3: Resumo por Período de Gravação

```sql
SELECT 
    CONVERT(DATE, jts.Started) AS DataGravacao,
    COUNT(DISTINCT j.Id) AS TotalJobs,
    COUNT(DISTINCT jrf.Id) AS TotalArquivos,
    SUM(jrfl.FileSize) AS TamanhoTotal
FROM Jobs j
INNER JOIN JobTCSectors jts ON jts.JobId = j.Id
LEFT JOIN JobResultFiles jrf ON jrf.JobTCSectorId = jts.Id
LEFT JOIN JobResultFileLocations jrfl ON jrfl.JobResultFileId = jrf.Id
GROUP BY CONVERT(DATE, jts.Started)
ORDER BY DataGravacao DESC;
```

**Descrição:** Agrupa itens por data de gravação com estatísticas.

---

## 📋 QUERY 4: Itens Gravados em Período Específico

```sql
SELECT 
    j.Name AS NomeJob,
    jrf.FileName AS Arquivo,
    jts.Started AS InicioGravacao,
    jts.StopTimecode AS FimGravacao,
    DATEDIFF(MINUTE, jts.Started, jts.StopTimecode) AS DuracaoMinutos,
    jrfl.Location AS Caminho
FROM Jobs j
INNER JOIN JobTCSectors jts ON jts.JobId = j.Id
LEFT JOIN JobResultFiles jrf ON jrf.JobTCSectorId = jts.Id
LEFT JOIN JobResultFileLocations jrfl ON jrfl.JobResultFileId = jrf.Id
WHERE jts.Started BETWEEN '2019-01-01' AND '2019-12-31'
ORDER BY jts.Started DESC;
```

**Descrição:** Lista itens gravados em 2019 (ajuste as datas conforme necessário).

---

## 📋 QUERY 5: Lista Simples - Apenas Nome e Data

```sql
SELECT 
    jrf.FileName AS Arquivo,
    jts.Started AS DataGravacao
FROM JobResultFiles jrf
INNER JOIN JobTCSectors jts ON jts.Id = jrf.JobTCSectorId
WHERE jrf.FileName IS NOT NULL
ORDER BY jts.Started DESC;
```

**Descrição:** Lista mais simples com apenas nome do arquivo e data de gravação.

---

## 📋 QUERY 6: Todos os Itens Gravados (com arquivos) ⭐ **RECOMENDADO**

```sql
SELECT 
    j.Id AS JobId,
    jrf.FileName AS Arquivo,
    jts.Started AS DataGravacao,
    jts.StopTimecode AS DataFim,
    jrfl.Location AS Caminho,
    jrfl.FileSize AS Tamanho
FROM Jobs j
INNER JOIN JobTCSectors jts ON jts.JobId = j.Id
INNER JOIN JobResultFiles jrf ON jrf.JobTCSectorId = jts.Id
LEFT JOIN JobResultFileLocations jrfl ON jrfl.JobResultFileId = jrf.Id
WHERE jrf.FileName IS NOT NULL
ORDER BY jts.Started DESC;
```

**Descrição:** Lista todos os jobs que têm arquivos resultantes (itens que foram gravados com sucesso).

**Nota:** Removido campo `Name` pois não existe na tabela Jobs.

---

## 📋 QUERY 7: Apenas Nomes de Arquivos Gravados

```sql
SELECT DISTINCT
    jrf.FileName AS Arquivo
FROM JobResultFiles jrf
WHERE jrf.FileName IS NOT NULL
ORDER BY jrf.FileName;
```

**Descrição:** Lista simples apenas com nomes dos arquivos gravados (sem duplicatas).

---

## 📋 QUERY 8: Contagem de Itens Gravados por Data

```sql
SELECT 
    CAST(jts.Started AS DATE) AS DataGravacao,
    COUNT(DISTINCT j.Id) AS TotalJobs,
    COUNT(DISTINCT jrf.Id) AS TotalArquivos
FROM Jobs j
INNER JOIN JobTCSectors jts ON jts.JobId = j.Id
INNER JOIN JobResultFiles jrf ON jrf.JobTCSectorId = jts.Id
WHERE jrf.FileName IS NOT NULL
GROUP BY CAST(jts.Started AS DATE)
ORDER BY DataGravacao DESC;
```

**Descrição:** Agrupa itens gravados por data com contagem.

---

## 📋 QUERY 9: Itens Gravados com Duração

```sql
SELECT 
    j.Id AS JobId,
    jrf.FileName AS Arquivo,
    jts.Started AS Inicio,
    jts.StopTimecode AS Fim,
    DATEDIFF(MINUTE, jts.Started, jts.StopTimecode) AS DuracaoMinutos
FROM Jobs j
INNER JOIN JobTCSectors jts ON jts.JobId = j.Id
INNER JOIN JobResultFiles jrf ON jrf.JobTCSectorId = jts.Id
WHERE jrf.FileName IS NOT NULL
ORDER BY jts.Started DESC;
```

**Descrição:** Lista itens gravados com cálculo de duração da gravação.

---

## 📋 QUERY 10: Exportar Lista de Arquivos Gravados (CSV)

```sql
SELECT 
    jrf.FileName
FROM JobResultFiles jrf
WHERE jrf.FileName IS NOT NULL
ORDER BY jrf.FileName;
```

**Descrição:** Lista limpa para exportar como CSV (apenas nomes de arquivos gravados).

---

## 🔧 Como Usar Essas Queries:

### Opção 1: SQL Server Management Studio
1. Abra o SQL Server Management Studio
2. Conecte ao arquivo .sdf
3. Cole uma das queries acima
4. Execute com F5

### Opção 2: Visual Studio
1. Server Explorer → Add Connection
2. Data Source: Microsoft SQL Server Compact
3. Database file name: [caminho do .sdf]
4. New Query e cole a query

### Opção 3: Ferramentas de Terceiros
- **SQL Server Compact Toolbox** (extensão do Visual Studio)
- **LINQPad** (suporta SQL CE)
- **CompactView**

---

## ⚠️ Troubleshooting - Erros Comuns:

### Erro: "The column name is not valid"

**Causa:** O campo `Status` não existe ou tem nome diferente.

**Solução:** Use as queries 6-10 que NÃO dependem do campo Status. Elas identificam itens gravados pela presença de arquivos resultantes.

### Verificar estrutura da tabela Jobs:

```sql
-- SQL Server Compact não suporta INFORMATION_SCHEMA
-- Use esta query alternativa:
SELECT * FROM Jobs WHERE 1=0;
```

Isso mostra todas as colunas disponíveis sem retornar dados.

### Alternativa: Descobrir colunas disponíveis

No LINQPad ou ferramentas visuais, você pode ver a estrutura da tabela diretamente.

---

## 📝 Notas:

- Ajuste os nomes das colunas se necessário (podem variar)
- As datas podem estar em diferentes formatos dependendo do banco
- Teste primeiro com a Query 5 (mais simples) para validar a estrutura
- Modifique os filtros de WHERE conforme sua necessidade

---

## ❓ Campos Identificados:

### Jobs
- Id, Name, Created, Modified, Status

### JobTCSectors  
- JobId, Started, StopTimecode

### JobResultFiles
- FileName, JobTCSectorId, Created, Modified

### JobResultFileLocations
- Location, FileSize, JobResultFileId
