-- extractbb-lua
-- https://github.com/gucci-on-fleek/extractbb
-- SPDX-License-Identifier: MPL-2.0+
-- SPDX-FileCopyrightText: 2024--2025 Max Chernoff

-- Initialization
module = "extractbb"
local version = "1.1.0" --%%version
local date = "2024--2025-02-11" --%%dashdate

local orig_targets = target_list
target_list = {}

-- Tagging
target_list.tag = orig_targets.tag
tagfiles = { "source/*.*", "docs/**/*.*", "README.md", "build.lua" }

function update_tag(name, content, version, date)
    if not version then
        print("No version provided. Exiting")
        os.exit(1)
    end

    if name:match("%.pdf$") then
        return content
    end

    content = content:gsub(
        "(%d%.%d%.%d)([^\n]*)%%%%version",
        version .. "%2%%%%version"
    ):gsub(
        "(%d%d%d%d%-%d%d%-%d%d)([^\n]*)%%%%dashdate",
        date .. "%2%%%%dashdate"
    ):gsub(
        "(%d%d%d%d/%d%d/%d%d)([^\n]*)%%%%slashdate",
        date:gsub("-", "/") .. "%2%%%%slashdate"
    )

    -- Argh!
    os.execute("chmod a+x source/extractbb.lua")

    return content
end

-- Bundle
target_list.bundle = {}
target_list.bundle.desc = "Creates the package zipfiles"

function target_list.bundle.func()
    local newzip = require "l3build-zip"
    local name = module .. "-" .. version
    local tdszipname = name .. ".tds.zip"
    local ctanzipname = name .. ".ctan.zip"

    local tdszip = newzip("./" .. tdszipname)
    local ctanzip = newzip("./" .. ctanzipname)

    for _, path in ipairs(tree("texmf", "**/*.*")) do
        tdszip:add(
            path.cwd, -- outer
            path.src:sub(3), -- inner
            path.src:match("pdf") -- binary
        )
        ctanzip:add(
            path.cwd, -- outer
            module .. "/" .. basename(path.src), -- inner
            path.src:match("pdf") -- binary
        )
    end

    tdszip:close()

    -- CTAN doesn't want this as per email from Petra and Karl
    -- ctanzip:add("./" .. tdszipname, tdszipname, true)
    ctanzip:close()

    local release_notes = io.open("release.title", "w")
    release_notes:write(version .. " " .. date .. "\n")
    release_notes:close()

    return 0
end

-- Documentation
target_list.doc = {}
target_list.doc.desc = "Builds the documentation"

function target_list.doc.func()
    local code = run(
        maindir .. "/documentation",
        "groff -Tpdf -man extractbb.1 > extractbb.man1.pdf"
    )

    if code ~= 0 then
        error("Failure!")
    end

    return 0
end

-- We use some questionable characters in the test files, so we need to override
-- the builtin functions
function ren(dir, source, dest)
    dir = dir .. "/"
    return os.rename(dir .. source, dir .. dest)
end

function normalize_path(path)
    out = ""
    for str in path:gmatch("([^ ]+)") do
        if str == ">" then
            out = out .. str
        else
            out = out .. "'" .. str .. "' "
        end
    end
    return out
end

-- Tests
target_list.check = orig_targets.check
target_list.save = orig_targets.save

os_diffexe = "git diff --no-index -w --word-diff --text"

testfiledir = "./tests/"
tdsdirs = { ["./texmf"] = "." }
maxprintline = 10000

test_types = {}
test_order = {}

local function add_type(extension)
    test_types[extension] = {
        test = "." .. extension,
        generated = "",
        reference = ".bbox-reference",
        expectation = "." .. extension,
    }
    table.insert(test_order, extension)
end

add_type("jpg")
add_type("pdf")
add_type("png")

function runtest(name, engine, _, ext, _, is_expectation)
    local in_file = testfiledir .. name .. ext
    local out_file = testdir .. "/" .. name .. "." .. engine

    local extractbb_flags
    if engine:match("ebb") then
        extractbb_flags = " -m -O "
    elseif engine:match("xbb") then
        extractbb_flags = " -x -O "
    else
        error("Failure!")
    end

    local script_path = "./texmf/scripts/extractbb/extractbb.lua"

    if engine:match("wine") then
        script_path = 'wine64 "$(type -p texlua.exe)" ' .. script_path
    end

    os.env["SOURCE_DATE_EPOCH"] = "1000000"
    os.env["TZ"] = "UTC"
    os.env["TEXINPUTS"] = "./texmf//"
    os.env["LUAINPUTS"] = "./texmf//"
    os.env["LC_CTYPE"] = "C.utf8"
    os.env["LC_COLLATE"] = "C.utf8"
    os.env["LC_NUMERIC"] = "C.utf8"

    local code = os.spawn(
        {
            "sh", "-c",
            script_path .. extractbb_flags .. "'" .. in_file .. "'" ..
            " > '" .. out_file .. "'",
        },
        os.env
    )

    -- Post-process
    local file = io.open(out_file, "r")
    local contents = file:read("*a")
    file:close()
    file = io.open(out_file, "w")
    file:write((contents
        :gsub("%%%%Creator:[^\n]*", "%%Creator: [redacted]")
        :gsub("(%d+%.%d%d%d%d%d%d)", function (value)
            return string.format("%.4fX", tonumber(value))
        end)
    ))
    file:close()

    if code ~= 0 then
        error("Failure!")
    end
end

specialformats = { extractbb = {
    ebb = {
        binary = "ebb"
    },
    xbb = {
        binary = "xbb"
    },
    wine_ebb = {
        binary = "wine_ebb"
    },
    wine_xbb = {
        binary = "wine_xbb"
    },
}}

checkengines = { "ebb", "xbb", "wine_ebb", "wine_xbb" }
checkformat = "extractbb"
forcecheckruns = false
