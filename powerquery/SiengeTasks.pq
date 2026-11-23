// Sienge API -> Power BI: all tasks of a building project's schedule, paginated by offset.
//
// Parameters (create them in Power Query: Home > Manage Parameters):
//   SiengeSubdomain  text    your company's subdomain, e.g. "mycompany"
//   ProjectId        number  building project id
//   SheetId          number  schedule sheet id
//
// Credentials: Data source settings > api.sienge.com.br > Basic (API user and password).
// Never put the user or password in the query.
let
    BaseUrl  = "https://api.sienge.com.br",   // static: required for scheduled refresh in the Power BI Service
    Path     = SiengeSubdomain & "/public/api/v1/building-projects/" & Text.From(ProjectId)
               & "/sheets/" & Text.From(SheetId) & "/tasks",
    PageSize = 200,

    // One page. offset/limit are passed ONLY in Query (not also in the URL).
    GetPage = (offset as number) as list =>
        let
            Response = Json.Document(
                Web.Contents(BaseUrl, [
                    RelativePath = Path,
                    Query = [offset = Text.From(offset), limit = Text.From(PageSize)]
                ])
            )
        in
            Response[results],

    // Keep requesting while the last page came full; stop at the first short page.
    // No fixed upper bound, and no try/otherwise: an authentication or API error
    // stops the refresh instead of silently returning fewer rows.
    Pages = List.Generate(
        () => [offset = 0, rows = GetPage(0)],
        each List.Count([rows]) > 0,
        each [
            offset = [offset] + PageSize,
            rows   = if List.Count([rows]) < PageSize then {} else GetPage([offset] + PageSize)
        ],
        each [rows]
    ),

    Rows  = List.Combine(Pages),
    Tasks = Table.FromRecords(Rows, null, MissingField.UseNull)
in
    Tasks
