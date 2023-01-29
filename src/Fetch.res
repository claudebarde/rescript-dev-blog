module FetchResponse = {
    type t

    @get external status: t => int = "status"
    @send external to_json: t => promise<Js.Json.t> = "json"
}

@val external fetch: string => promise<FetchResponse.t> = "fetch"