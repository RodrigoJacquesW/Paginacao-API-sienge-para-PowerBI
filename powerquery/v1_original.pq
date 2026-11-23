// First version (kept for comparison; see README for the issues).

// Function GetAPIData
(Offset as number) as table =>
let
    Fonte = Json.Document(Web.Contents(
        "https://api.sienge.com.br/{SeuDomínio}/public/api/v1/building-projects/{NúmeroDoProjeto}/sheets/2/tasks?offset=0&limit=200",
        [Query=[offset=Text.From(Offset), limit="200"]]
    )),
    Dados = Fonte[results],
    Tabela = Table.FromRecords(Dados)
in
    Tabela

// Query OffsetList
// = List.Generate(() => 0, each _ < 1600, each _ + 200)

// Custom column
// = try GetAPIData([Offset]) otherwise null
