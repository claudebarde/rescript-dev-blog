module Window = {
    type t = Dom.window
    type location = { href: string }

    module Navigator = {
        type t

        module Clipboard = {
            type t

            // @send external read_text: Navigator.t => promise<string> = "readText"
            @send external write_text: (t, string) => promise<unit> = "writeText"
        }

        @get external clipboard: t => Clipboard.t = "clipboard"
    }
    
    @val external window: t = "window"
    @get external location: t => location = "location"
    @get external href: location => string = "href"
    @get external navigator: t => Navigator.t = "navigator"
}

module Dom_element = {
    type t = Dom.element
    type bounding_client_rect = {
        x: float,
        y: float,
        width: float,
        height: float
    }

    @get external text_content: t => string = "textContent"
    @get external id: t => string = "id"
    @get external scroll_top: t => int = "scrollTop"
    @get external offset_height: t => int = "offsetHeight"
    @get external offset_width: t => int = "offsetWidth"
    @get external client_height: t => int = "clientHeight"
    @get external client_width: t => int = "clientWidth"
    @get external height: t => int = "height"
    @get external width: t => int = "width"
    @send external get_bounding_client_rect: t => bounding_client_rect = "getBoundingClientRect"
    @send external set_attribute: (t, string, string) => unit = "setAttribute"
    @send external get_attribute: (t, string) => Js.Nullable.t<string> = "getAttribute"
}
@val external document: Dom.document = "document"
@send external query_selector: ('a, string) => Js.Nullable.t<Dom_element.t> = "querySelector"
@send external query_selector_all: ('a, string) => Js.Array2.array_like<Dom_element.t> = "querySelectorAll"
@send external closest: (Dom_element.t, string) => Js.Nullable.t<Dom_element.t> = "closest"
@val external set_interval: (unit => unit, int) => float = "setInterval"
@val external clear_interval: float => unit = "clearInterval"
@val external set_timeout: (unit => unit, int) => float = "setTimeout"

module IntersectionObserver = {
    type t
    type observer_options = {
        root: option<Dom.element>,
        rootMargin: string,
        threshold: float
    }
    type entry = {
        isIntersecting: bool,
        isVisible: bool,
        target: Dom.element,
        time: float
    }
    type callback = (array<entry>, t) => unit

    @new external new: (callback, observer_options) => t = "IntersectionObserver"
    @send external observe: (t, Dom.element) => unit = "observe"
}