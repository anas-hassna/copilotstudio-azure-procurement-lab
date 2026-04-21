# Skill: Procurement RAG - AI Search + Copilot Studio

## Description

Demonstrate how to integrate Copilot Studio with Azure AI Search for agentic RAG (Retrieval-Augmented Generation) over procurement documents. The setup indexes PDF documents from SharePoint into AI Search with vector embeddings and semantic ranking, then connects to a Copilot Studio agent that helps buyers search, analyze, and compare procurement data through natural language.

**Use when:** the user wants to build a RAG pipeline over SharePoint documents with AI Search, connect AI Search to Copilot Studio as a knowledge source, demonstrate agentic RAG capabilities, or set up document search with chunking and vector embeddings.

**Do NOT use for:** VNet integration (see asset 1), general Azure networking, or non-RAG AI scenarios.

---

## What This Demonstrates

1. **SharePoint as document source** - PDFs organized by category, uploaded via Graph API
2. **AI Search indexing pipeline** - SharePoint indexer with built-in skillset (text splitting + OpenAI embeddings), no custom code
3. **Vector + semantic search** - Hybrid retrieval combining keyword, vector, and semantic ranking
4. **Copilot Studio integration** - AI Search as a knowledge source for a conversational agent
5. **Agentic RAG** - The agent can reason over search results, compare candidates, and provide structured answers

## Architecture

```
SharePoint Online (Document Library)
    |  24 PDFs in 8 category folders
    v
Azure AI Search
    |  SharePoint indexer -> text split -> OpenAI embeddings
    |  Index: vector + semantic + filterable metadata
    v
Copilot Studio Agent
    |  Knowledge source: AI Search
    |  Topics for structured queries (filters, comparisons)
    v
End Users (Procurement Buyers)
```

## Sample Documents

The `docs/` folder contains 30 generated PDF procurement documents across 8 categories:

| Category | Documents | Examples |
|---|---|---|
| BIOMEDICAL | 4 | Medical imaging, sterilization, patient monitors, endoscopy |
| DISPOSITIFS-MEDICAUX | 4 | Surgical gloves, wound dressings, single-use devices, sutures |
| EQUIPEMENTS-GENERAUX | 4 | Hospital furniture, wheelchairs, surgical clothing, hospital beds |
| HOTELLERIE | 3 | Catering, laundry, cleaning services |
| INFORMATIQUE | 4 | Network infrastructure, EHR system, cybersecurity SOC, telemedicine |
| LABORATOIRES | 4 | Lab reagents, hematology analyzers, microbiology, molecular biology PCR |
| MEDICAMENTS | 4 | Pharmaceutical framework, medical gases, nutrition, antiseptics |
| TRANSPORTS-VEHICULES | 4 | SMUR ambulances, shuttle services, vehicle fleet, emergency transport |

Each document contains realistic tender data: lots, candidates, scoring criteria, prices, and attribution decisions. All data is fictional (Contoso GHT hospital group).

## Infrastructure

Deployed via Terraform (`infra/`):
- Azure AI Search (basic SKU) with system-assigned managed identity
- Azure OpenAI with text-embedding-ada-002 deployment
- Entra ID App Registration for SharePoint indexer authentication

## Scripts

| Script | Purpose |
|---|---|
| `setup.ps1` | Orchestrator - runs all steps in order |
| `01-create-sharepoint-site.ps1` | Creates SharePoint site + category folders via Graph API |
| `02-upload-documents.ps1` | Uploads PDFs to SharePoint with metadata via Graph API |
| `03-configure-ai-search.ps1` | Creates AI Search index, data source, skillset, and indexer |
| `04-test-use-cases.ps1` | Tests RAG pipeline with sample queries against AI Search + GPT |
| `05-run-indexer.ps1` | Runs (or resets and reruns) the AI Search indexer for new documents |

## Key Integration Points

### AI Search as Copilot Studio Knowledge Source
- Copilot Studio natively supports Azure AI Search as a knowledge source
- Configure: Knowledge -> Add knowledge -> Azure AI Search -> provide endpoint + API key
- The agent uses semantic search to find relevant document chunks

### Filtered Queries via Power Automate
- For structured queries (filter by category, year, amount), use a Power Automate flow
- The flow calls the AI Search REST API with `$filter` expressions
- Results are returned to Copilot Studio as structured data

### Agentic RAG Scenarios
The agent should handle these types of questions:
- "Do we have an existing contract for surgical gloves?" (document search)
- "Compare the candidates for the IT infrastructure tender" (multi-doc reasoning)
- "What are the maintenance SLAs in the biomedical contracts?" (specific extraction)
- "Which tenders expire in 2025?" (filtered search by date)
- "Why was MedTech Solutions selected over BioEquip?" (comparative analysis)

## Important Notes for AI Agents

1. **Documents are in French** - All procurement documents use French terminology
2. **SharePoint indexer is in preview** - The SharePoint Online indexer for AI Search is a preview feature
3. **Admin consent required** - The App Registration needs admin consent for Sites.Read.All and Files.Read.All permissions before the indexer can access SharePoint
4. **Chunking is essential** - PDFs are split into 2000-char chunks with 200-char overlap for effective RAG retrieval
5. **Semantic configuration** - The index uses a semantic configuration named "default" with chunk as content field and title as title field
6. **Embedding model** - text-embedding-ada-002 (1536 dimensions) for vector search
