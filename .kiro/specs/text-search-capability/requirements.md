# Requirements Document

## Introduction

Este documento especifica os requisitos para expandir a funcionalidade do script PowerShell `procurar_itens.ps1` de busca exclusiva por números para busca por qualquer texto (strings arbitrárias) nos títulos de arquivos e pastas. A modificação preservará a performance e usabilidade do script existente enquanto adiciona flexibilidade para buscar palavras, frases e caracteres especiais.

## Glossary

- **Script**: O arquivo PowerShell `procurar_itens.ps1` que realiza buscas em sistema de arquivos
- **Search_Term**: Uma string de texto fornecida pelo usuário para buscar nos títulos de arquivos/pastas
- **Title**: O nome de um arquivo ou pasta sem a extensão (obtido via `GetFileNameWithoutExtension`)
- **User**: A pessoa que executa o script e fornece os termos de busca
- **Search_Path**: O caminho do diretório ou disco onde a busca será realizada
- **Progress_Indicator**: Mensagem exibida a cada 2000 itens processados para mostrar que o script está ativo
- **Match**: Ocorrência de um Search_Term dentro de um Title

## Requirements

### Requirement 1: Accept Text Input

**User Story:** Como usuário, eu quero fornecer qualquer texto como termo de busca, para que eu possa procurar por palavras, frases ou caracteres especiais nos títulos de arquivos e pastas.

#### Acceptance Criteria

1. WHEN the User provides input, THE Script SHALL accept any non-empty string as valid Search_Term
2. THE Script SHALL support Search_Terms containing letters, numbers, spaces, and special characters
3. WHEN the User provides multiple Search_Terms separated by comma or space, THE Script SHALL parse each term correctly
4. WHEN the User provides an empty or whitespace-only input, THE Script SHALL display an error message and exit
5. THE Script SHALL preserve leading and trailing spaces within quoted Search_Terms

### Requirement 2: Remove Number-Only Validation

**User Story:** Como usuário, eu quero que o script não rejeite entradas não-numéricas, para que eu possa buscar por texto livremente.

#### Acceptance Criteria

1. THE Script SHALL remove the regex validation `^\d+$` that restricts input to numbers only
2. THE Script SHALL not display the error message "Nenhum número válido foi identificado" for non-numeric input
3. WHEN the User provides text input, THE Script SHALL process it without validation errors

### Requirement 3: Search for Text in Titles

**User Story:** Como usuário, eu quero que o script encontre meus termos de busca nos títulos de arquivos e pastas, para que eu possa localizar itens por qualquer parte do nome.

#### Acceptance Criteria

1. FOR EACH Search_Term, THE Script SHALL check if the Search_Term is contained within each Title
2. THE Script SHALL use case-insensitive matching when comparing Search_Terms to Titles
3. THE Script SHALL continue to ignore file extensions during the search (using `GetFileNameWithoutExtension`)
4. WHEN a Match is found, THE Script SHALL record the full file path associated with that Search_Term
5. THE Script SHALL avoid recording duplicate paths for the same Search_Term

### Requirement 4: Maintain Performance Characteristics

**User Story:** Como usuário, eu quero que o script mantenha a mesma performance rápida, para que eu possa buscar em grandes volumes de dados eficientemente.

#### Acceptance Criteria

1. THE Script SHALL continue using `cmd.exe /c "dir /s /b"` for file system traversal
2. THE Script SHALL display Progress_Indicator messages every 2000 items processed
3. THE Script SHALL handle errors gracefully without stopping the search process
4. THE Script SHALL process both files and folders in a single traversal

### Requirement 5: Display Results in Real-Time

**User Story:** Como usuário, eu quero ver os resultados conforme são encontrados, para que eu possa acompanhar o progresso da busca.

#### Acceptance Criteria

1. WHEN a Match is found, THE Script SHALL immediately display a success message with the Search_Term
2. WHEN a Match is found, THE Script SHALL immediately display the full file path
3. THE Script SHALL use green color for success messages to maintain visual consistency
4. THE Script SHALL display each Match only once per Search_Term

### Requirement 6: Provide Summary Report

**User Story:** Como usuário, eu quero ver um resumo final dos resultados, para que eu possa entender rapidamente quais termos foram encontrados e quantas vezes.

#### Acceptance Criteria

1. WHEN the search completes, THE Script SHALL display the total number of items scanned
2. FOR EACH Search_Term, THE Script SHALL display the count of Matches found
3. WHEN a Search_Term has Matches, THE Script SHALL display a success message in green
4. WHEN a Search_Term has no Matches, THE Script SHALL display a not-found message in red
5. THE Script SHALL display the summary after all items have been processed

### Requirement 7: Update User Interface Messages

**User Story:** Como usuário, eu quero que as mensagens do script reflitam a nova funcionalidade de busca por texto, para que eu entenda claramente o que o script faz.

#### Acceptance Criteria

1. THE Script SHALL update the title message from "Procurador de Itens por Número no Título" to reflect text search capability
2. THE Script SHALL update the input prompt from "Digite os números" to request text terms
3. THE Script SHALL update all references from "número" to "termo" or equivalent in user-facing messages
4. THE Script SHALL maintain the same color scheme for different message types (Cyan for info, Yellow for warnings, Green for success, Red for errors)

### Requirement 8: Handle Special Characters Safely

**User Story:** Como usuário, eu quero buscar por termos contendo caracteres especiais, para que eu possa encontrar arquivos com nomes complexos.

#### Acceptance Criteria

1. WHEN a Search_Term contains regex special characters (e.g., `.`, `*`, `[`, `]`), THE Script SHALL treat them as literal characters
2. THE Script SHALL not interpret Search_Terms as regular expressions
3. THE Script SHALL use string containment matching (e.g., `.Contains()`) rather than pattern matching
4. WHEN a Search_Term contains characters invalid for file paths, THE Script SHALL still process the search without errors
