using Oxygen
using HTTP
using Mustache
using JSON

struct Subscriber
    name::String
    email::String
end

# Render HTML from file
function renderHTML(htmlFile::String, cssFile::String, context::Dict = Dict(); status = 200, headers = ["Content-Type" => "text/html; charset=utf-8"]) :: HTTP.Response
    isContextEmpty = isempty(context)

    # Read HTML file
    io = open(htmlFile, "r") do file
        read(file, String)
    end
    template = isContextEmpty ? io |> String : String(Mustache.render(io, context))

    # Read CSS file
    css = ""
    if !isempty(cssFile)
        css_io = open(cssFile, "r") do file
            read(file, String)
        end
        css = "<style>$css_io</style>"
    end

    # Combine HTML and CSS
    template = "<html><head>$css</head><body>$template</body></html>"

    return HTTP.Response(status, headers, body = template)
end

# Creating Home Page Route
@get "/hello" function(req::HTTP.Request)
    return "Hello World!"
end

# Serialize Dict to JSON
@get "/json" function(req::HTTP.Request)
    return Dict("name" => "Brandon")
end

# Render HTML with context
@get "/" function(reg::HTTP.Request)
    context = Dict("name" => "Brandon")
    return renderHTML("index.html", "style.css", context)
end

# Receiving query params
@get "/query" function(req::HTTP.Request)
    return queryparams(req)
end

# Receiving form data
@get "/form" function(req::HTTP.Request)
    formData = queryparams(req)
    name = get(formData, "name", 0)
    context = Dict("name" => name)
    return renderHTML("form.html", "style.css", context)
end

# Path params
@get "/add/{num1}/{num2}" function(req::HTTP.Request, num1::Float64, num2::Float64)
    return num1 + num2
end

@get "/multiply/{num1}/{num2}" function(req::HTTP.Request, num1::Float64, num2::Float64)
    return num1 * num2
end

api = router("/api", tags=["api endpoint"])

@get api("/add/{num1}/{num2}") function(req::HTTP.Request, num1::Float64, num2::Float64)
    return num1 + num2
end

@get api("/multiply/{num1}/{num2}") function(req::HTTP.Request, num1::Float64, num2::Float64)
    return num1 * num2
end

serve(port=8443)